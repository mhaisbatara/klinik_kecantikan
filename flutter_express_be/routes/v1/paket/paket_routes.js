import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { authenticateMobile } from "../../../middleware/auth_middleware.js";

const router = express.Router();

/**
 * GET /api/v1/paket
 * Daftar Paket Perawatan Klinik (Layanan & Produk)
 */
router.get("/", async (req, res) => {
  try {
    const { kode_cabang } = req.query;

    const paketLayananQuery = DB("mst_paket_layanan as p")
      .leftJoin("mst_ruangan as r", "p.kode_ruangan", "r.kode_ruangan")
      .whereIn("p.status", ["aktif", "1"]);

    if (kode_cabang) {
      paketLayananQuery.where((qb) => {
        qb.where("p.kode_cabang", kode_cabang).orWhereNull("p.kode_cabang");
      });
    }

    const paketLayanan = await paketLayananQuery.select(
      "p.id",
      "p.kode_paket_layanan",
      "p.kode_paket_layanan as kode_layanan",
      "p.nama as nama_paket",
      "p.nama as nama_layanan",
      "p.nama",
      "p.harga_paket",
      "p.harga_paket as harga",
      "p.masa_berlaku_hari",
      "p.status",
      "p.foto",
      "p.foto as gambar",
      "p.kode_ruangan",
      "r.nama_ruangan",
      "p.is_include_konsultasi",
      "p.tipe",
      "p.kode_cabang"
    );

    // Ambil detail items untuk setiap paket
    const hasDetail = await DB.schema.hasTable("mst_detail_paket_layanan");
    if (hasDetail) {
      for (const p of paketLayanan) {
        const details = await DB("mst_detail_paket_layanan as d")
          .leftJoin("mst_layanan as l", "d.kode_layanan", "l.kode_layanan")
          .where("d.kode_paket_layanan", p.kode_paket_layanan)
          .select("d.kode_layanan", "l.nama as nama_layanan", "d.jumlah_sesi", "l.durasi_menit");
        p.details = details;
        p.total_sesi = details.reduce((sum, d) => sum + (d.jumlah_sesi || 1), 0);
        p.durasi_menit = details.reduce((sum, d) => sum + (d.durasi_menit || 30), 0) || 60;
        p.is_paket = true;
        p.jenis = "paket";
        p.kategori = "Paket Perawatan";
        p.nama_kategori = "Paket Perawatan";
      }
    }

    const paketProduk = await DB("mst_paket_produk")
      .whereIn("status", ["aktif", "1"])
      .select("*");

    return sendSuccess(res, "Daftar paket berhasil dimuat", {
      paket_layanan: paketLayanan,
      paket_produk: paketProduk,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/paket/saya
 * Paket Perawatan Aktif yang Dimiliki Pasien (Sisa Kuota Treatment)
 */
router.get("/saya", authenticateMobile, async (req, res) => {
  try {
    const noRm = req.auth.no_rm;
    if (!noRm) {
      return sendSuccess(res, "Pasien belum memiliki rekam medis terdaftar", []);
    }

    // Ambil kepemilikan paket layanan pasien
    const kepemilikan = await DB("trx_kepemilikan_paket_layanan as k")
      .leftJoin("mst_paket_layanan as p", "k.kode_paket", "p.kode_paket_layanan")
      .where("k.no_rm", noRm)
      .where("k.status", "aktif")
      .select(
        "k.id",
        "k.kode_transaksi",
        "k.kode_paket",
        "p.nama as nama_paket",
        "k.total_sesi",
        "k.sisa_sesi",
        "k.tanggal_kadaluarsa",
        "k.status",
        "k.created_at"
      );

    return sendSuccess(res, "Paket perawatan saya berhasil dimuat", kepemilikan);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
