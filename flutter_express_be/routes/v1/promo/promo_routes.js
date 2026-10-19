import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { formatDateSystem } from "../../../utils/date_tools.js";

const router = express.Router();

/**
 * GET /api/v1/promo
 * Daftar Promo & Diskon Aktif untuk Mobile Carousel/List
 */
router.get("/", async (req, res) => {
  try {
    const today = formatDateSystem(new Date(), "yyyy-MM-dd");

    const promos = await DB("mst_promo")
      .where("status", "1")
      .andWhere(function () {
        this.whereNull("tanggal_selesai").orWhere("tanggal_selesai", ">=", today);
      })
      .orderBy("tanggal_mulai", "desc")
      .select("*");

    return sendSuccess(res, "Daftar promo berhasil dimuat", promos);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/promo/:kode
 * Detail Promo dan Item yang Tercakup
 */
router.get("/:kode", async (req, res) => {
  try {
    const { kode } = req.params;

    const promo = await DB("mst_promo")
      .where("kode_promo", kode)
      .orWhere("id", kode)
      .first();

    if (!promo) {
      return sendError(res, "Promo tidak ditemukan", 404);
    }

    // Ambil detail item promo jika ada di mst_detail_promo
    const details = await DB("mst_detail_promo")
      .where("kode_promo", promo.kode_promo)
      .select("*");

    return sendSuccess(res, "Detail promo berhasil dimuat", {
      promo,
      items: details,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
