import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";

const router = express.Router();

/**
 * GET /api/v1/produk/kategori
 * Kategori Produk Skincare
 */
router.get("/kategori", async (req, res) => {
  try {
    const kategori = await DB("mst_kategori_produk")
      .where("status", "1")
      .orderBy("nama_kategori", "asc")
      .select("id", "kode_kategori", "nama_kategori", "keterangan");

    return sendSuccess(res, "Daftar kategori produk berhasil dimuat", kategori);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/produk
 * Katalog Produk Skincare untuk Mobile
 */
router.get("/", async (req, res) => {
  try {
    const { search, kategori, page = 1, limit = 20 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);

    const query = DB("mst_produk as p")
      .leftJoin("mst_kategori_produk as kp", "p.kode_kategori", "kp.kode_kategori")
      .where("p.status", "1")
      .modify((qb) => {
        if (search) {
          const s = `%${search.toLowerCase()}%`;
          qb.where(function () {
            this.whereRaw("LOWER(p.nama_produk) LIKE ?", [s]).orWhereRaw(
              "LOWER(p.deskripsi) LIKE ?",
              [s]
            );
          });
        }
        if (kategori) {
          qb.where("p.kode_kategori", kategori);
        }
      });

    const totalCount = await query.clone().count("p.id as total").first();
    const data = await query
      .clone()
      .select(
        "p.id",
        "p.kode_produk",
        "p.nama_produk",
        "p.kode_kategori",
        "kp.nama_kategori as kategori",
        "p.harga_jual",
        "p.stok",
        "p.satuan",
        "p.deskripsi",
        "p.gambar"
      )
      .orderBy("p.nama_produk", "asc")
      .limit(Number(limit))
      .offset(offset);

    return sendSuccess(res, "Katalog produk berhasil dimuat", {
      items: data,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total_records: totalCount?.total || 0,
        total_pages: Math.ceil((totalCount?.total || 0) / Number(limit)),
      },
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/produk/:kode
 * Detail Produk Skincare
 */
router.get("/:kode", async (req, res) => {
  try {
    const { kode } = req.params;

    const produk = await DB("mst_produk as p")
      .leftJoin("mst_kategori_produk as kp", "p.kode_kategori", "kp.kode_kategori")
      .where("p.kode_produk", kode)
      .orWhere("p.id", kode)
      .select(
        "p.*",
        "kp.nama_kategori as kategori"
      )
      .first();

    if (!produk) {
      return sendError(res, "Produk tidak ditemukan", 404);
    }

    return sendSuccess(res, "Detail produk berhasil dimuat", produk);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
