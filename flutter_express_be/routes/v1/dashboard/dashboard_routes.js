import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { optionalAuth } from "../../../middleware/auth_middleware.js";
import { formatDateSystem } from "../../../utils/date_tools.js";

const router = express.Router();

/**
 * GET /api/v1/dashboard/home
 * Single Endpoint Aggregate untuk Mobile Home Screen Flutter
 * Mengembalikan: Banner Promo, Layanan Populer, Produk Skincare, Dokter, dan Status Booking/Antrean jika login
 */
router.get("/home", optionalAuth, async (req, res) => {
  try {
    const today = formatDateSystem(new Date(), "yyyy-MM-dd");
    const user = req.auth || null;

    // 1. Promo Aktif untuk Banner Carousel
    const promos = await DB("mst_promo")
      .where("status", "1")
      .andWhere(function () {
        this.whereNull("tanggal_selesai").orWhere("tanggal_selesai", ">=", today);
      })
      .orderBy("created_at", "desc")
      .limit(5)
      .select(
        "id",
        "kode_promo",
        "nama_promo",
        "jenis_promo",
        "nilai_promo",
        "tanggal_mulai",
        "tanggal_selesai",
        "banner"
      );

    // 2. Kategori & Layanan Populer
    const layananList = await DB("mst_layanan as l")
      .leftJoin("mst_kategori_layanan as k", "l.kode_kategori_layanan", "k.kode_kategori_layanan")
      .where(function () {
        this.where("l.status", "aktif").orWhere("l.status", "1");
      })
      .select(
        "l.id",
        "l.kode_layanan",
        "l.nama as nama_layanan",
        "l.nama",
        "l.harga",
        "l.durasi_menit",
        "l.foto as gambar",
        "k.nama as kategori"
      )
      .limit(6);

    // 3. Produk Skincare Populer
    const produkList = await DB("mst_produk as p")
      .leftJoin("mst_kategori_produk as kp", "p.kode_kategori", "kp.kode_kategori")
      .where(function () {
        this.where("p.status", "aktif").orWhere("p.status", "1");
      })
      .select(
        "p.id",
        "p.kode_produk",
        "p.nama_produk",
        "p.harga_jual",
        "p.stok",
        "p.satuan",
        "p.deskripsi",
        "p.gambar",
        "kp.nama_kategori as kategori"
      )
      .limit(6);

    // 4. Dokter Spesialis & Estetika
    const dokterList = await DB("mst_karyawan as k")
      .where("k.status", "aktif")
      .andWhere(function () {
        this.where("k.jabatan", "like", "%dokter%")
          .orWhere("k.role", "dokter")
          .orWhereNotNull("k.no_sip");
      })
      .select(
        "k.id",
        "k.kode_karyawan",
        "k.nama as nama",
        "k.jabatan",
        "k.no_sip",
        "k.kode_cabang"
      )
      .limit(6);

    // 5. Data Khusus Pengguna Login (Booking Terdekat & Antrean Hari Ini)
    let userActiveBooking = null;
    let userActiveAntrean = null;

    if (user && user.no_rm) {
      // Cek booking aktif mendatang
      userActiveBooking = await DB("trx_booking as b")
        .leftJoin("mst_jadwal_karyawan as j", "b.kode_jadwal", "j.kode_jadwal")
        .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
        .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
        .where("b.no_rm", user.no_rm)
        .whereIn("b.status", ["menunggu", "dikonfirmasi", "terkonfirmasi"])
        .andWhere("b.tanggal_booking", ">=", today)
        .orderBy("b.tanggal_booking", "asc")
        .orderBy("b.jam_booking", "asc")
        .select(
          "b.kode_booking",
          "b.tanggal_booking",
          "b.jam_booking",
          "b.status",
          "b.dp_status",
          "k.nama as nama_dokter",
          "r.nama_ruangan"
        )
        .first();

      // Cek antrean hari ini
      userActiveAntrean = await DB("trx_antrian_layanan as a")
        .leftJoin("mst_ruangan as r", "a.kode_ruangan", "r.kode_ruangan")
        .where("a.no_rm", user.no_rm)
        .andWhereRaw("DATE(a.created_at) = ?", [today])
        .whereNotIn("a.status", ["selesai", "batal"])
        .select(
          "a.no_antrian",
          "a.status",
          "r.nama_ruangan",
          "a.created_at"
        )
        .first();
    }

    return sendSuccess(res, "Data dashboard mobile berhasil dimuat", {
      promos,
      layanan_populer: layananList,
      produk_populer: produkList,
      dokter: dokterList,
      booking_terdekat: userActiveBooking,
      antrean_hari_ini: userActiveAntrean,
    });
  } catch (error) {
    console.error("Dashboard Home Error:", error);
    return sendError(res, error.message, 500);
  }
});

export default router;
