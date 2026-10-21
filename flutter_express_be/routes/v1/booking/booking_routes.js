import express from "express";
import Joi from "joi";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { status } from "../../../utils/general.js";
import { formatDateSystem } from "../../../utils/date_tools.js";
import { authenticateMobile } from "../../../middleware/auth_middleware.js";
import { upload } from "../../../middleware/upload_middleware.js";

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
    items: Joi.array()
      .items(
        Joi.object({
          kode_layanan: Joi.string().required(),
          nama_layanan: Joi.string().optional(),
          harga: Joi.number().optional(),
          durasi_menit: Joi.number().optional(),
        })
      )
      .optional(),
    catatan_pasien: Joi.string().allow("", null).label("Keluhan / Catatan"),
    metode_pembayaran_dp: Joi.string().allow("", null).default("transfer").label("Metode DP"),
    kode_cabang: Joi.string().allow("", null).default("CBG-001"),
    bukti_dp: Joi.string().allow("", null).optional().label("Bukti DP"),
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

      const totalNominal = bookingItems.reduce(
        (sum, item) => sum + (Number(item.harga) || 0),
        0
      );
      const dpNominal = Math.round(totalNominal * 0.2); // DP 20%

      const firstItem = bookingItems[0] || {};
      const bookingRecord = {
        kode_cabang: value.kode_cabang || user.kode_cabang || "CBG-001",
        kode_booking: cKodeBooking,
        no_rm: noRm,
        kode_ruangan: jadwal.kode_ruangan || null,
        kode_layanan: firstItem.kode_layanan || value.kode_layanan || null,
        jenis_layanan: "layanan",
        kode_jadwal: value.kode_jadwal,
        tanggal_booking: value.tanggal_booking,
        jam_booking: value.jam_booking,
        total_biaya: totalNominal,
        status: "dikonfirmasi", // langsung muncul di web Daftar Booking sebagai Dikonfirmasi
        dp_nominal: dpNominal,
        dp_status: "belum_bayar",
        metode_pembayaran_dp: value.metode_pembayaran_dp || "transfer",
        bukti_dp: buktiDpUrl,
        catatan_pasien: value.catatan_pasien || null,
        sumber: "mobile",
        tz: process.env.APP_TZ || "Asia/Jakarta",
        created_by: user.username || "mobile_app",
        created_at: formatDateSystem(),
      };

      await trx("trx_booking").insert(bookingRecord);

      // Insert detail booking items jika tabel ada
      const hasDetailTable = await trx.schema.hasTable("trx_detail_booking");
      if (hasDetailTable && bookingItems.length > 0) {
        const detailsToInsert = bookingItems.map((item, idx) => ({
          kode_detail_booking: `DBKG-${datePart}-${String(nextNum).padStart(4, "0")}-${String(idx + 1).padStart(2, "0")}`,
          kode_booking: cKodeBooking,
          jenis_layanan: "layanan",
          jenis_item: "layanan_baru",
          kode_layanan: item.kode_layanan,
          nama_layanan: item.nama_layanan,
          harga: item.harga || 0,
          durasi_menit: item.durasi_menit || 30,
          tz: process.env.APP_TZ || "Asia/Jakarta",
          created_by: user.username || "mobile_app",
          created_at: formatDateSystem(),
        }));
        await trx("trx_detail_booking").insert(detailsToInsert);
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
 * GET /api/v1/booking/history
 * Riwayat & Daftar Booking Pasien yang Sedang Login
 */
router.get("/history", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const noRm = user.no_rm;

  if (!noRm) {
    return sendSuccess(res, "Riwayat booking pasien", []);
  }

  try {
    const { status_filter } = req.query;

    const query = DB("trx_booking as b")
      .leftJoin("mst_jadwal_karyawan as j", "b.kode_jadwal", "j.kode_jadwal")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_cabang as c", DB.raw("b.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .where("b.no_rm", noRm)
      .modify((qb) => {
        if (status_filter) {
          qb.where("b.status", status_filter);
        }
      })
      .orderBy("b.tanggal_booking", "desc")
      .orderBy("b.jam_booking", "desc");

    const bookings = await query.select(
      "b.id",
      "b.kode_booking",
      "b.tanggal_booking",
      "b.jam_booking",
      "b.status",
      "b.dp_status",
      "b.dp_nominal",
      "b.metode_pembayaran_dp",
      "b.bukti_dp",
      "b.catatan_pasien",
      "b.sumber",
      "k.nama as nama_dokter",
      "r.nama_ruangan",
      "c.nama_cabang",
      "b.created_at"
    );

    // Ambil detail items untuk setiap booking
    const hasDetail = await DB.schema.hasTable("trx_detail_booking");
    if (hasDetail) {
      for (const b of bookings) {
        b.items = await DB("trx_detail_booking")
          .where("kode_booking", b.kode_booking)
          .select("kode_layanan", "nama_layanan", "harga", "durasi_menit");
      }
    }

    return sendSuccess(res, "Riwayat booking berhasil dimuat", bookings);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/booking/:kode
 * Detail Booking Reservasi Pasien
 */
router.get("/:kode", authenticateMobile, async (req, res) => {
  try {
    const { kode } = req.params;

    const booking = await DB("trx_booking as b")
      .leftJoin("mst_pasien as p", "b.no_rm", "p.no_rm")
      .leftJoin("mst_jadwal_karyawan as j", "b.kode_jadwal", "j.kode_jadwal")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_cabang as c", DB.raw("b.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .where("b.kode_booking", kode)
      .orWhere("b.id", kode)
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
      return sendError(res, "Data booking tidak ditemukan", 404);
    }

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
 * Pasien Membatalkan Janji Temu Booking
 */
router.post("/:kode/cancel", authenticateMobile, async (req, res) => {
  const { kode } = req.params;
  const { alasan_batal } = req.body || {};

  try {
    const booking = await DB("trx_booking")
      .where("kode_booking", kode)
      .first();

    if (!booking) {
      return sendError(res, "Data booking tidak ditemukan", 404);
    }

    if (["selesai", "batal"].includes(booking.status)) {
      return sendError(
        res,
        `Booking tidak dapat dibatalkan karena status saat ini: ${booking.status}`,
        400
      );
    }

    await DB("trx_booking")
      .where("kode_booking", kode)
      .update({
        status: "batal",
        catatan_pasien: alasan_batal
          ? `${booking.catatan_pasien || ""}\nAlasan Batal: ${alasan_batal}`.trim()
          : booking.catatan_pasien,
        updated_at: formatDateSystem(),
      });

    return sendSuccess(res, "Reservasi booking berhasil dibatalkan");
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
