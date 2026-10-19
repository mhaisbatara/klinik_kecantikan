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
    const paketLayanan = await DB("mst_paket_layanan")
      .where("status", "1")
      .select("*");

    const paketProduk = await DB("mst_paket_produk")
      .where("status", "1")
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
      .leftJoin("mst_paket_layanan as p", "k.kode_paket", "p.kode_paket")
      .where("k.no_rm", noRm)
      .where("k.status", "aktif")
      .select(
        "k.id",
        "k.kode_transaksi",
        "k.kode_paket",
        "p.nama_paket",
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
