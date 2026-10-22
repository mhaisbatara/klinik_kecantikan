import express from "express";
import Joi from "joi";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { status } from "../../../utils/general.js";
import { formatDateSystem } from "../../../utils/date_tools.js";
import { authenticateMobile } from "../../../middleware/auth_middleware.js";
import { upload } from "../../../middleware/upload_middleware.js";
import { syncBookingToKasirDraft, cancelKasirDraftByBooking } from "../../../services/kasir_sync_service.js";

const router = express.Router();

const HARI_MAP = ["minggu", "senin", "selasa", "rabu", "kamis", "jumat", "sabtu"];

/**
 * GET /api/v1/booking/slots
 * Cek Ketersediaan Slot Jadwal & Kuota Booking Dokter/Ruangan pada Tanggal Tertentu
 */
router.get("/slots", async (req, res) => {
  const { tanggal_booking, kode_ruangan, kode_layanan, kode_cabang } = req.query;

  if (!tanggal_booking) {
    return sendError(res, "Parameter tanggal_booking wajib diisi (YYYY-MM-DD)", 422);
  }

  try {
    const cleanDateStr = String(tanggal_booking).slice(0, 10);
    const [year, month, day] = cleanDateStr.split("-").map(Number);
    const dateObj = new Date(year, month - 1, day);
    const dayName = HARI_MAP[dateObj.getDay()];

    // 1. Tentukan ruangan jika ada kode_layanan
    let targetRuangan = kode_ruangan || null;
    if (!targetRuangan && kode_layanan) {
      const layanan = await DB("mst_layanan")
        .where("kode_layanan", kode_layanan)
        .first();
      if (layanan && layanan.kode_ruangan) {
        targetRuangan = layanan.kode_ruangan;
      }
    }

    // 2. Query Jadwal Karyawan/Dokter pada hari tersebut
    const jadwalQuery = DB("mst_jadwal_karyawan as j")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .where("j.hari", dayName)
      .where("j.status", "aktif")
      .modify((qb) => {
        if (targetRuangan) {
          qb.where("j.kode_ruangan", targetRuangan);
        }
        if (kode_cabang) {
          qb.where("j.kode_cabang", kode_cabang);
        }
      });

    const jadwals = await jadwalQuery.select(
      "j.id",
      "j.kode_jadwal",
      "j.hari",
      "j.jam_mulai",
      "j.jam_selesai",
      "j.kuota",
      "j.no_sip",
      "j.kode_ruangan",
      "k.nama as nama_dokter",
      "k.nama as nama_karyawan",
      "r.nama_ruangan"
    );

    // 3. Hitung jumlah booking yang sudah terisi pada tanggal tersebut
    const slots = [];
    for (const j of jadwals) {
      const bookedRows = await DB("trx_booking")
        .where("kode_jadwal", j.kode_jadwal)
        .where("tanggal_booking", cleanDateStr)
        .whereNotIn("status", ["batal", "tidak_hadir"])
        .select("jam_booking");

      const totalBooked = bookedRows.length;
      const kuota = parseInt(j.kuota || 10, 10);
      const sisaKuota = Math.max(0, kuota - totalBooked);
      const bookedTimes = bookedRows
        .map((b) => (b.jam_booking || "").slice(0, 5))
        .filter(Boolean);

      slots.push({
        ...j,
        total_terisi: totalBooked,
        sisa_kuota: sisaKuota,
        is_penuh: sisaKuota <= 0,
        booked_times: bookedTimes,
      });
    }

    return sendSuccess(res, `Slot booking hari ${dayName} (${cleanDateStr}) berhasil dimuat`, {
      tanggal_booking: cleanDateStr,
      hari: dayName,
      available_slots: slots,
    });
  } catch (err) {
    console.error("Booking Slots Error:", err);
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/booking/create
 * Membuat Transaksi Booking Reservasi Appointment dari Aplikasi Mobile Pasien
 */
router.post("/create", authenticateMobile, upload.single("bukti_dp"), async (req, res) => {
  let body = { ...(req.body || {}) };
  const user = req.auth;

  // Handle items jika dikirimkan sebagai string JSON dari multipart form-data
  if (typeof body.items === "string") {
    try {
      body.items = JSON.parse(body.items);
    } catch (_) {
      body.items = [];
    }
  }

  // Handle upload bukti DP
  let buktiDpUrl = null;
  if (req.file) {
    buktiDpUrl = `/uploads/${req.file.filename}`;
  } else if (body.bukti_dp) {
    buktiDpUrl = body.bukti_dp;
  }

  // Pasien yang login: ambil no_rm dari auth atau dari request body
  const noRm = user.no_rm || body.no_rm;
  if (!noRm) {
    return sendError(
      res,
      "Akun Anda belum memiliki Nomor Rekam Medis (RM). Silakan hubungi admin klinik.",
      422
    );
  }

  const schema = Joi.object({
    kode_jadwal: Joi.string().required().label("Jadwal Dokter/Petugas"),
    tanggal_booking: Joi.string().required().label("Tanggal Booking"),
    jam_booking: Joi.string().required().label("Jam Booking (HH:mm)"),
    kode_layanan: Joi.string().allow("", null).label("Kode Layanan"),
    is_claim_packet: Joi.boolean().optional(),
    kode_detail_kepemilikan_paket_layanan: Joi.string().allow("", null).optional(),
    items: Joi.array()
      .items(
        Joi.object({
          kode_layanan: Joi.string().required(),
          nama_layanan: Joi.string().optional(),
          harga: Joi.number().optional(),
          durasi_menit: Joi.number().optional(),
          is_claim_packet: Joi.boolean().optional(),
          kode_detail_kepemilikan_paket_layanan: Joi.string().allow("", null).optional(),
        })
      )
      .optional(),
    catatan_pasien: Joi.string().allow("", null).label("Keluhan / Catatan"),
    metode_pembayaran_dp: Joi.string().allow("", null).default("transfer").label("Metode DP"),
    kode_cabang: Joi.string().allow("", null).default("CBG-001"),
    bukti_dp: Joi.string().allow("", null).optional().label("Bukti DP"),
    butuh_konsul: Joi.any().optional().label("Butuh Konsul"),
  });

  const { error, value } = schema.validate(body);
  if (error) {
    return sendError(res, error.details[0].message, 422);
  }

  try {
    const todayYmd = formatDateSystem(new Date(), "yyyy-MM-dd");
    if (value.tanggal_booking < todayYmd) {
      return sendError(res, "Tanggal booking tidak boleh di masa lalu", 422);
    }

    // 1. Verifikasi Pasien
    const pasien = await DB("mst_pasien").where("no_rm", noRm).first();
    if (!pasien) {
      return sendError(res, `Pasien dengan No RM ${noRm} tidak ditemukan`, 404);
    }

    // 2. Verifikasi Jadwal
    const jadwal = await DB("mst_jadwal_karyawan as j")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .where("j.kode_jadwal", value.kode_jadwal)
      .select("j.*", "k.nama as nama_karyawan", "k.nama as nama_dokter", "r.nama_ruangan")
      .first();

    if (!jadwal) {
      return sendError(res, "Slot jadwal tidak valid atau tidak ditemukan", 404);
    }

    // 3. Cek Kuota
    const bookedCount = await DB("trx_booking")
      .where("kode_jadwal", value.kode_jadwal)
      .where("tanggal_booking", value.tanggal_booking)
      .whereNotIn("status", ["batal", "tidak_hadir"])
      .count("id as total")
      .first();

    const totalBooked = parseInt(bookedCount?.total || 0, 10);
    const kuota = parseInt(jadwal.kuota || 10, 10);
    if (totalBooked >= kuota) {
      return sendError(
        res,
        "Mohon maaf, kuota booking untuk jadwal dokter pada tanggal ini sudah penuh.",
        400
      );
    }

    // 4. Kumpulkan items layanan
    let bookingItems = value.items || [];
    if (bookingItems.length === 0 && value.kode_layanan) {
      const lay = await DB("mst_layanan")
        .where("kode_layanan", value.kode_layanan)
        .first();
      if (lay) {
        bookingItems.push({
          kode_layanan: lay.kode_layanan,
          nama_layanan: lay.nama || lay.nama_layanan,
          harga: lay.harga,
          durasi_menit: lay.durasi_menit || 30,
          is_claim_packet: value.is_claim_packet,
          kode_detail_kepemilikan_paket_layanan: value.kode_detail_kepemilikan_paket_layanan,
        });
      }
    }

    let createdBooking = null;

    // 5. Transaksi Database
    await DB.transaction(async (trx) => {
      // Generate Kode Booking (BKG-YYYYMMDD-XXXX)
      const datePart = value.tanggal_booking.replace(/-/g, "");
      const lastBooking = await trx("trx_booking")
        .where("kode_booking", "like", `BKG-${datePart}-%`)
        .orderBy("id", "desc")
        .first();

      let nextNum = 1;
      if (lastBooking && lastBooking.kode_booking) {
        const parts = lastBooking.kode_booking.split("-");
        const n = parseInt(parts[2], 10);
        if (!isNaN(n)) nextNum = n + 1;
      }
      const cKodeBooking = `BKG-${datePart}-${String(nextNum).padStart(4, "0")}`;

      const isClaim = Boolean(
        value.is_claim_packet ||
        bookingItems.some((it) => it.is_claim_packet || it.kode_detail_kepemilikan_paket_layanan)
      );

      const totalNominal = isClaim
        ? 0
        : bookingItems.reduce((sum, item) => sum + (Number(item.harga) || 0), 0);
      const dpNominal = isClaim ? 0 : Math.round(totalNominal * 0.2); // Klaim paket bebas DP (DP Rp0)
      const dpStatus = isClaim ? "lunas" : (dpNominal === 0 ? "lunas" : "belum_bayar");

      const isButuhKonsul = (value.butuh_konsul === true || value.butuh_konsul === 1 || value.butuh_konsul === "1" || value.butuh_konsul === "true") ? 1 : 0;
      const firstItem = bookingItems[0] || {};
      const bookingRecord = {
        kode_cabang: value.kode_cabang || user.kode_cabang || "CBG-001",
        kode_booking: cKodeBooking,
        no_rm: noRm,
        kode_ruangan: jadwal.kode_ruangan || null,
        kode_layanan: firstItem.kode_layanan || value.kode_layanan || null,
        jenis_layanan: isClaim ? "klaim_paket" : "layanan",
        kode_jadwal: value.kode_jadwal,
        tanggal_booking: value.tanggal_booking,
        jam_booking: value.jam_booking,
        total_biaya: totalNominal,
        butuh_konsul: isButuhKonsul,
        status: "dikonfirmasi", // langsung muncul di web Daftar Booking sebagai Dikonfirmasi
        dp_nominal: dpNominal,
        dp_status: dpStatus,
        metode_pembayaran_dp: isClaim ? "klaim_paket" : (value.metode_pembayaran_dp || "transfer"),
        bukti_dp: isClaim ? null : buktiDpUrl,
        catatan_pasien: isClaim
          ? (value.catatan_pasien ? `[Klaim Sisa Sesi Paket] ${value.catatan_pasien}` : "[Klaim Sisa Sesi Paket]")
          : value.catatan_pasien || null,
        sumber: "mobile",
        tz: process.env.APP_TZ || "Asia/Jakarta",
        created_by: user.username || "mobile_app",
        created_at: formatDateSystem(),
      };

      if (isClaim) {
        bookingRecord.alasan_bebas_dp = "Klaim Paket (Kepemilikan Aktif)";
      }

      await trx("trx_booking").insert(bookingRecord);

      // Insert detail booking items jika tabel ada
      const hasDetailTable = await trx.schema.hasTable("trx_detail_booking");
      if (hasDetailTable && bookingItems.length > 0) {
        const detailsToInsert = bookingItems.map((item, idx) => {
          const isItemClaim = isClaim || Boolean(item.is_claim_packet || item.kode_detail_kepemilikan_paket_layanan);
          return {
            kode_detail_booking: `DBKG-${datePart}-${String(nextNum).padStart(4, "0")}-${String(idx + 1).padStart(2, "0")}`,
            kode_booking: cKodeBooking,
            jenis_layanan: isItemClaim ? "klaim_paket" : "layanan",
            jenis_item: isItemClaim ? "klaim_paket" : "layanan_baru",
            kode_layanan: item.kode_layanan,
            nama_layanan: item.nama_layanan,
            harga: isItemClaim ? 0 : (item.harga || 0),
            durasi_menit: item.durasi_menit || 30,
            kode_detail_kepemilikan_paket_layanan:
              item.kode_detail_kepemilikan_paket_layanan ||
              value.kode_detail_kepemilikan_paket_layanan ||
              null,
            tz: process.env.APP_TZ || "Asia/Jakarta",
            created_by: user.username || "mobile_app",
            created_at: formatDateSystem(),
          };
        });
        await trx("trx_detail_booking").insert(detailsToInsert);
      }

      // Integrasi Kasir: Buat draf kasir jika ada DP berbayar
      if (dpNominal > 0) {
        try {
          await syncBookingToKasirDraft(trx, {
            kodeBooking: cKodeBooking,
            noRm: noRm,
            kodeCabang: bookingRecord.kode_cabang,
            dpNominal: dpNominal,
            metodePembayaranDp: bookingRecord.metode_pembayaran_dp,
            username: user.username || "mobile_app",
            tz: process.env.APP_TZ || "Asia/Jakarta",
          });
        } catch (syncErr) {
          console.error(`[BOOKING_MOBILE] Gagal sinkronisasi draf kasir untuk ${cKodeBooking}:`, syncErr.message);
        }
      }

      createdBooking = {
        kode_booking: cKodeBooking,
        tanggal_booking: value.tanggal_booking,
        jam_booking: value.jam_booking,
        nama_pasien: pasien.nama,
        no_rm: noRm,
        nama_dokter: jadwal.nama_karyawan,
        nama_ruangan: jadwal.nama_ruangan,
        total_estimasi: totalNominal,
        dp_nominal: dpNominal,
        status: "dikonfirmasi",
        dp_status: "belum_bayar",
        metode_pembayaran_dp: value.metode_pembayaran_dp || "transfer",
        bukti_dp: buktiDpUrl,
        butuh_konsul: isButuhKonsul,
        kode_cabang: bookingRecord.kode_cabang,
        items: bookingItems,
      };
    });

    return sendSuccess(
      res,
      "Reservasi booking berhasil dibuat! Silakan lakukan konfirmasi DP.",
      createdBooking,
      201
    );
  } catch (err) {
    console.error("Create Booking Error:", err);
    return sendError(res, err.message, 500);
  }
});

/**
 * Helper membersihkan nama cabang
 */
function cleanNamaCabang(nama) {
  if (!nama) return "Cabang Utama";
  return nama.replace(/^Klinik\s+/i, "").trim();
}

/**
 * GET /api/v1/booking/history
 * Riwayat & Daftar Booking Pasien yang Sedang Login (dengan Paginasi & Filter)
 */
router.get("/history", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const noRm = user.no_rm;

  if (!noRm) {
    return sendSuccess(res, "Riwayat booking pasien", {
      items: [],
      total: 0,
      page: 1,
      limit: 15,
      hasMore: false,
    });
  }

  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.max(1, Math.min(50, parseInt(req.query.limit) || 15));
    const offset = (page - 1) * limit;
    const { status_filter } = req.query;

    const baseQuery = DB("trx_booking as b")
      .where("b.no_rm", noRm)
      .modify((qb) => {
        if (status_filter && status_filter !== "semua") {
          if (status_filter === "aktif") {
            qb.whereIn("b.status", ["menunggu_konfirmasi", "dikonfirmasi"]);
          } else if (status_filter === "batal" || status_filter === "dibatalkan") {
            qb.whereIn("b.status", ["batal", "dibatalkan"]);
          } else {
            qb.where("b.status", status_filter);
          }
        }
      });

    // Hitung total data
    const totalResult = await baseQuery.clone().count("b.id as total").first();
    const total = parseInt(totalResult?.total || 0);

    // Sorting: Mendatang/aktif urut dari terdekat (ASC), riwayat/selesai dari terbaru (DESC)
    const isMendatang = status_filter === "aktif";

    const query = baseQuery
      .clone()
      .leftJoin("mst_jadwal_karyawan as j", "b.kode_jadwal", "j.kode_jadwal")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_cabang as c", DB.raw("b.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .orderBy("b.tanggal_booking", isMendatang ? "asc" : "desc")
      .orderBy("b.jam_booking", isMendatang ? "asc" : "desc")
      .orderBy("b.id", isMendatang ? "asc" : "desc")
      .offset(offset)
      .limit(limit);

    const bookings = await query.select(
      "b.id",
      "b.kode_booking",
      "b.tanggal_booking",
      "b.jam_booking",
      "b.status",
      "b.dp_status",
      "b.dp_nominal",
      "b.total_biaya",
      "b.alasan_bebas_dp",
      "b.metode_pembayaran_dp",
      "b.bukti_dp",
      "b.catatan_pasien",
      "b.sumber",
      "b.kode_cabang",
      "k.nama as nama_dokter",
      "r.nama_ruangan",
      "c.nama_cabang",
      "b.created_at",
      "b.updated_at"
    );

    // Ambil detail items untuk setiap booking
    const hasDetail = await DB.schema.hasTable("trx_detail_booking");
    if (hasDetail) {
      for (const b of bookings) {
        b.nama_cabang = cleanNamaCabang(b.nama_cabang);
        b.items = await DB("trx_detail_booking")
          .where("kode_booking", b.kode_booking)
          .select("kode_layanan", "nama_layanan", "harga", "durasi_menit");
      }
    } else {
      for (const b of bookings) {
        b.nama_cabang = cleanNamaCabang(b.nama_cabang);
        b.items = [];
      }
    }

    const hasMore = offset + bookings.length < total;

    return sendSuccess(res, "Riwayat booking berhasil dimuat", {
      items: bookings,
      total,
      page,
      limit,
      hasMore,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/booking/:kode
 * Detail Booking Reservasi Pasien (DILINDUNGI KEAMANAN IDOR)
 */
router.get("/:kode", authenticateMobile, async (req, res) => {
  try {
    const { kode } = req.params;
    const user = req.auth;
    const isSuperAdmin = (user.role || "").toLowerCase() === "superadmin";

    const query = DB("trx_booking as b")
      .leftJoin("mst_pasien as p", "b.no_rm", "p.no_rm")
      .leftJoin("mst_jadwal_karyawan as j", "b.kode_jadwal", "j.kode_jadwal")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_cabang as c", DB.raw("b.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .where(function () {
        this.where("b.kode_booking", kode).orWhere("b.id", kode);
      });

    // 🔒 WAJIB KEAMANAN IDOR: Cegah Pasien A melihat data reservasi Pasien B
    if (!isSuperAdmin) {
      query.andWhere("b.no_rm", user.no_rm);
    }

    const booking = await query
      .select(
        "b.*",
        "p.nama as nama_pasien",
        "p.no_hp as no_hp_pasien",
        "k.nama as nama_dokter",
        "r.nama_ruangan",
        "c.nama_cabang"
      )
      .first();

    if (!booking) {
      return sendError(res, "Data booking tidak ditemukan atau akses tidak diizinkan", 404);
    }

    booking.nama_cabang = cleanNamaCabang(booking.nama_cabang);

    // Ambil items detail
    const hasDetail = await DB.schema.hasTable("trx_detail_booking");
    booking.items = hasDetail
      ? await DB("trx_detail_booking")
          .where("kode_booking", booking.kode_booking)
          .select("*")
      : [];

    return sendSuccess(res, "Detail booking berhasil dimuat", booking);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/booking/:kode/cancel
 * Pasien Membatalkan Janji Temu Booking (DILINDUNGI KEAMANAN IDOR & KONSEKUENSI DP)
 */
router.post("/:kode/cancel", authenticateMobile, async (req, res) => {
  const { kode } = req.params;
  const { alasan_batal } = req.body || {};
  const user = req.auth;
  const isSuperAdmin = (user.role || "").toLowerCase() === "superadmin";

  try {
    const query = DB("trx_booking").where("kode_booking", kode);
    // 🔒 WAJIB KEAMANAN IDOR: Pasien hanya bisa membatalkan miliknya sendiri
    if (!isSuperAdmin) {
      query.andWhere("no_rm", user.no_rm);
    }
    const booking = await query.first();

    if (!booking) {
      return sendError(res, "Data booking tidak ditemukan atau akses tidak diizinkan", 404);
    }

    if (["selesai", "batal", "dibatalkan", "tidak_hadir"].includes(booking.status)) {
      return sendError(
        res,
        `Booking tidak dapat dibatalkan karena status saat ini: ${booking.status}`,
        400
      );
    }

    // Jika sudah bayar DP, catat dp_status menjadi 'hangus' sesuai data riil klinik
    const newDpStatus =
      booking.dp_status === "sudah_bayar" || booking.dp_status === "lunas"
        ? "hangus"
        : booking.dp_status;

    const catatanBaru = [
      booking.catatan_pasien,
      `[DIBATALKAN PASIEN ${formatDateSystem()}] Alasan: ${alasan_batal || "Dibatalkan oleh pelanggan"}`,
    ]
      .filter(Boolean)
      .join("\n");

    await DB("trx_booking")
      .where("kode_booking", kode)
      .update({
        status: "dibatalkan",
        dp_status: newDpStatus,
        catatan_pasien: catatanBaru,
        updated_at: formatDateSystem(),
        updated_by: user.username || "mobile_app",
      });

    // Batalkan juga draf kasir jika ada
    try {
      await cancelKasirDraftByBooking(DB, kode, user.username || "mobile_app");
    } catch (cancelErr) {
      console.warn(`[BOOKING_MOBILE] Gagal membatalkan draf kasir untuk ${kode}:`, cancelErr.message);
    }

    return sendSuccess(res, "Reservasi booking berhasil dibatalkan", {
      kode_booking: kode,
      status: "dibatalkan",
      dp_status: newDpStatus,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
