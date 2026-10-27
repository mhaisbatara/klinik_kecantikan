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
      } else {
        const paket = await DB("mst_paket_layanan")
          .where("kode_paket_layanan", kode_layanan)
          .first();
        if (paket && paket.kode_ruangan) {
          targetRuangan = paket.kode_ruangan;
        }
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
        .whereNotIn("status", ["batal", "dibatalkan", "tidak_hadir"])
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
    kode_metode_pembayaran: Joi.string().allow("", null).optional().label("Kode Metode Pembayaran"),
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

    // 0. Cek apakah pasien masih memiliki transaksi booking pending (menunggu upload bukti DP)
    const activePending = await DB("trx_booking")
      .where("no_rm", noRm)
      .where("status", "menunggu")
      .where("dp_nominal", ">", 0)
      .where((qb) => {
        qb.whereNull("bukti_dp").orWhere("bukti_dp", "");
      })
      .where("tanggal_booking", ">=", todayYmd)
      .orderBy("id", "desc")
      .first();

    if (activePending) {
      return sendError(
        res,
        `Anda masih memiliki transaksi booking pending (${activePending.kode_booking}) yang belum menyelesaikan upload bukti DP. Silakan selesaikan transaksi tersebut atau batalkan terlebih dahulu.`,
        400,
        activePending
      );
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
      .whereNotIn("status", ["batal", "dibatalkan", "tidak_hadir"])
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
          jenis: "layanan",
          is_claim_packet: value.is_claim_packet,
          kode_detail_kepemilikan_paket_layanan: value.kode_detail_kepemilikan_paket_layanan,
        });
      } else {
        const pkt = await DB("mst_paket_layanan")
          .where("kode_paket_layanan", value.kode_layanan)
          .first();
        if (pkt) {
          bookingItems.push({
            kode_layanan: pkt.kode_paket_layanan,
            nama_layanan: pkt.nama,
            harga: pkt.harga_paket,
            durasi_menit: 60,
            jenis: "paket",
            is_paket: true,
          });
        }
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
        : bookingItems.reduce(
            (sum, item) => sum + (Number(item.harga ?? item.harga_paket) || 0),
            0
          );
      const dpNominal = isClaim ? 0 : Math.round(totalNominal * 0.2); // Klaim paket bebas DP (DP Rp0)
      const dpStatus = isClaim ? "lunas" : (dpNominal === 0 ? "lunas" : "belum_bayar");

      const isButuhKonsul = (value.butuh_konsul === true || value.butuh_konsul === 1 || value.butuh_konsul === "1" || value.butuh_konsul === "true") ? 1 : 0;
      const firstItem = bookingItems[0] || {};
      const isPaket = value.jenis_layanan === "paket" ||
        bookingItems.some((it) => it.jenis === "paket" || it.is_paket === true || it.is_paket_layanan === true);

      const bookingRecord = {
        kode_cabang: value.kode_cabang || user.kode_cabang || "CBG-001",
        kode_booking: cKodeBooking,
        no_rm: noRm,
        kode_ruangan: jadwal.kode_ruangan || null,
        kode_layanan: firstItem.kode_layanan || firstItem.kode_paket_layanan || value.kode_layanan || null,
        jenis_layanan: isClaim ? "klaim_paket" : (isPaket ? "paket" : (value.jenis_layanan || "layanan")),
        kode_jadwal: value.kode_jadwal,
        tanggal_booking: value.tanggal_booking,
        jam_booking: value.jam_booking,
        total_biaya: totalNominal,
        butuh_konsul: isButuhKonsul,
        status: dpNominal > 0 ? "menunggu" : "dikonfirmasi", // Jika ada DP, statusnya menunggu konfirmasi kasir. Jika bebas DP, dikonfirmasi
        dp_nominal: dpNominal,
        dp_status: dpNominal > 0 ? "belum_bayar" : "bebas_dp",
        metode_pembayaran_dp: value.metode_pembayaran_dp || "transfer",
        kode_metode_pembayaran: value.kode_metode_pembayaran || null,
        bukti_dp: buktiDpUrl,
        catatan_pasien: value.catatan_pasien || null,
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
          const itemIsPaket = item.jenis === "paket" || item.is_paket === true || item.is_paket_layanan === true;
          const isItemClaim = isClaim || Boolean(item.is_claim_packet || item.kode_detail_kepemilikan_paket_layanan);
          return {
            kode_detail_booking: `DBKG-${datePart}-${String(nextNum).padStart(4, "0")}-${String(idx + 1).padStart(2, "0")}`,
            kode_booking: cKodeBooking,
            jenis_layanan: isItemClaim ? "klaim_paket" : (itemIsPaket ? "paket" : (item.jenis_layanan || "layanan")),
            jenis_item: isItemClaim ? "klaim_paket" : (itemIsPaket ? "paket" : (item.jenis_item || "layanan_baru")),
            kode_layanan: item.kode_layanan || item.kode_paket_layanan,
            nama_layanan: item.nama_layanan || item.nama || item.nama_paket,
            harga: isItemClaim ? 0 : (item.harga ?? item.harga_paket ?? 0),
            durasi_menit: item.durasi_menit || (itemIsPaket ? 60 : 30),
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
            kodeMetodePembayaran: bookingRecord.kode_metode_pembayaran,
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
        status: dpNominal > 0 ? "menunggu" : "dikonfirmasi",
        dp_status: dpNominal > 0 ? "belum_bayar" : "bebas_dp",
        metode_pembayaran_dp: value.metode_pembayaran_dp || "transfer",
        kode_metode_pembayaran: value.kode_metode_pembayaran || null,
        bukti_dp: buktiDpUrl,
        butuh_konsul: isButuhKonsul,
        kode_cabang: bookingRecord.kode_cabang,
        items: bookingItems,
      };
    });

    return sendSuccess(
      res,
      dpNominal > 0
        ? "Reservasi booking berhasil dibuat! Silakan menunggu konfirmasi pembayaran DP oleh kasir."
        : "Reservasi booking berhasil dibuat dan terkonfirmasi!",
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
      "b.jenis_layanan",
      "b.kode_layanan",
      "b.tanggal_booking",
      "b.jam_booking",
      "b.total_biaya",
      "b.status",
      "b.dp_status",
      "b.dp_nominal",
      "b.total_biaya",
      "b.alasan_bebas_dp",
      "b.metode_pembayaran_dp",
      "b.kode_metode_pembayaran",
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
    for (const b of bookings) {
      b.nama_cabang = cleanNamaCabang(b.nama_cabang);
      if (hasDetail) {
        b.items = await DB("trx_detail_booking")
          .where("kode_booking", b.kode_booking)
          .select("kode_layanan", "nama_layanan", "harga", "durasi_menit");
      } else {
        b.items = [];
      }

      // Fallback jika detail booking belum ada
      if ((!b.items || b.items.length === 0) && b.kode_layanan) {
        if (b.jenis_layanan === "paket") {
          const pkt = await DB("mst_paket_layanan")
            .where("kode_paket_layanan", b.kode_layanan)
            .first();
          if (pkt) {
            b.items = [
              {
                kode_layanan: pkt.kode_paket_layanan,
                nama_layanan: pkt.nama,
                harga: pkt.harga_paket,
                durasi_menit: 60,
              },
            ];
          }
        } else {
          const lay = await DB("mst_layanan")
            .where("kode_layanan", b.kode_layanan)
            .first();
          if (lay) {
            b.items = [
              {
                kode_layanan: lay.kode_layanan,
                nama_layanan: lay.nama || lay.nama_layanan,
                harga: lay.harga,
                durasi_menit: lay.durasi_menit || 30,
              },
            ];
          }
        }
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
 * GET /api/v1/booking/pending
 * Cek apakah pasien yang sedang login memiliki booking pending (menunggu upload bukti DP)
 */
router.get("/pending", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const noRm = user.no_rm;

  if (!noRm) {
    return sendSuccess(res, "Tidak ada data rekam medis", null);
  }

  try {
    const todayYmd = formatDateSystem(new Date(), "yyyy-MM-dd");

    const pendingBooking = await DB("trx_booking as b")
      .leftJoin("mst_jadwal_karyawan as j", "b.kode_jadwal", "j.kode_jadwal")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_cabang as c", DB.raw("b.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .where("b.no_rm", noRm)
      .where("b.status", "menunggu")
      .where("b.dp_nominal", ">", 0)
      .where((qb) => {
        qb.whereNull("b.bukti_dp").orWhere("b.bukti_dp", "");
      })
      .where("b.tanggal_booking", ">=", todayYmd)
      .orderBy("b.id", "desc")
      .select(
        "b.*",
        "k.nama as nama_dokter",
        "r.nama_ruangan",
        "c.nama_cabang"
      )
      .first();

    if (!pendingBooking) {
      return sendSuccess(res, "Tidak ada transaksi booking pending", null);
    }

    const hasDetail = await DB.schema.hasTable("trx_detail_booking");
    pendingBooking.items = hasDetail
      ? await DB("trx_detail_booking")
          .where("kode_booking", pendingBooking.kode_booking)
          .select("kode_layanan", "nama_layanan", "harga", "durasi_menit")
      : [];

    return sendSuccess(res, "Transaksi booking pending ditemukan", pendingBooking);
  } catch (err) {
    console.error("Pending Booking Error:", err);
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
 * POST /api/v1/booking/:kode/upload-bukti-dp
 * Upload Bukti Pembayaran DP untuk Transaksi Pending (Langkah 3)
 */
router.post("/:kode/upload-bukti-dp", authenticateMobile, upload.single("bukti_dp"), async (req, res) => {
  const { kode } = req.params;
  const user = req.auth;
  const noRm = user.no_rm;
  const { metode_pembayaran_dp, kode_metode_pembayaran } = req.body || {};

  try {
    const booking = await DB("trx_booking")
      .where("kode_booking", kode)
      .first();

    if (!booking) {
      return sendError(res, "Data booking tidak ditemukan", 404);
    }

    if (noRm && booking.no_rm !== noRm) {
      return sendError(res, "Anda tidak berhak mengakses transaksi ini", 403);
    }

    if (["batal", "dibatalkan", "selesai"].includes(booking.status)) {
      return sendError(res, `Booking tidak dapat diproses karena status: ${booking.status}`, 400);
    }

    let buktiDpUrl = booking.bukti_dp;
    if (req.file) {
      buktiDpUrl = `/uploads/${req.file.filename}`;
    }

    if (!buktiDpUrl) {
      return sendError(res, "File foto/screenshot bukti pembayaran DP wajib diunggah", 422);
    }

    const updatePayload = {
      bukti_dp: buktiDpUrl,
      updated_at: formatDateSystem(),
      updated_by: user.username || "mobile_app",
    };

    if (metode_pembayaran_dp) {
      updatePayload.metode_pembayaran_dp = metode_pembayaran_dp;
    }
    if (kode_metode_pembayaran) {
      updatePayload.kode_metode_pembayaran = kode_metode_pembayaran;
    }

    await DB("trx_booking")
      .where("kode_booking", kode)
      .update(updatePayload);

    // Sync juga ke draf transaksi kasir jika ada
    try {
      await syncBookingToKasirDraft(DB, {
        kodeBooking: booking.kode_booking,
        noRm: booking.no_rm,
        kodeCabang: booking.kode_cabang,
        dpNominal: Number(booking.dp_nominal) || 0,
        metodePembayaranDp: updatePayload.metode_pembayaran_dp || booking.metode_pembayaran_dp,
        kodeMetodePembayaran: updatePayload.kode_metode_pembayaran || booking.kode_metode_pembayaran,
        username: user.username || "mobile_app",
        tz: process.env.APP_TZ || "Asia/Jakarta",
      });
    } catch (syncErr) {
      console.warn(`[UPLOAD_BUKTI_DP] Gagal sinkronisasi draf kasir:`, syncErr.message);
    }

    return sendSuccess(res, "Bukti pembayaran DP berhasil diunggah! Mohon menunggu konfirmasi kasir.", {
      kode_booking: kode,
      bukti_dp: buktiDpUrl,
      status: booking.status,
    });
  } catch (err) {
    console.error("Upload Bukti DP Error:", err);
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/booking/:kode/cancel
 * Pasien Membatalkan Janji Temu Booking (DILINDUNGI KEAMANAN IDOR & KONSEKUENSI DP)
 */
router.post("/:kode/cancel", authenticateMobile, async (req, res) => {
  const { kode } = req.params;
  const user = req.auth;
  const { alasan_batal } = req.body || {};
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
      await cancelKasirDraftByBooking(DB, kode, user?.username || "mobile_app");
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
