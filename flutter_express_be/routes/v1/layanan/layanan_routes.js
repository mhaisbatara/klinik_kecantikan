import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";

const router = express.Router();

/**
 * GET /api/v1/layanan/kategori
 * Daftar Kategori Layanan / Treatment
 */
router.get("/kategori", async (req, res) => {
  try {
    const kategori = await DB("mst_kategori_layanan")
      .where("status", "aktif")
      .orWhere("status", "1")
      .orderBy("nama", "asc")
      .select("id", "kode_kategori_layanan", "nama as nama_kategori", "deskripsi as keterangan");

    return sendSuccess(res, "Daftar kategori layanan berhasil dimuat", kategori);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/layanan
 * Katalog Layanan & Treatment Kecantikan untuk Mobile
 */
router.get("/", async (req, res) => {
  try {
    const { search, kategori, kode_cabang, cabang, page = 1, limit = 50 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);

    const query = DB("mst_layanan as l")
      .leftJoin("mst_kategori_layanan as k", "l.kode_kategori_layanan", "k.kode_kategori_layanan")
      .leftJoin("mst_ruangan as r", "l.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_cabang as c", DB.raw("l.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .where(function () {
        this.where("l.status", "aktif").orWhere("l.status", "1");
      })
      .modify((qb) => {
        if (search) {
          const s = `%${search.toLowerCase()}%`;
          qb.whereRaw("LOWER(l.nama) LIKE ?", [s]);
        }
        if (kategori) {
          qb.where("l.kode_kategori_layanan", kategori);
        }
        const branchFilter = kode_cabang || cabang;
        if (branchFilter && branchFilter.toLowerCase() !== "semua" && branchFilter.toLowerCase() !== "all") {
          qb.where("l.kode_cabang", branchFilter);
        }
      });

    const totalCount = await query.clone().count("l.id as total").first();
    const data = await query
      .clone()
      .select(
        "l.id",
        "l.kode_layanan",
        "l.nama as nama_layanan",
        "l.nama",
        "l.kode_kategori_layanan",
        "k.nama as kategori",
        "l.harga",
        "l.durasi_menit",
        "l.foto",
        "l.foto as gambar",
        "l.kode_ruangan",
        "r.nama_ruangan",
        "l.wajib_konsultasi",
        "l.is_include_konsultasi",
        "l.tipe",
        "l.kode_cabang",
        "c.nama_cabang"
      )
      .orderBy("l.nama", "asc")
      .limit(Number(limit))
      .offset(offset);

    const cleanNamaCabang = (name) => {
      if (!name) return "Cabang Utama";
      let s = String(name).trim();
      if (s.toLowerCase().startsWith("klinik ")) {
        s = s.slice(7).trim();
      }
      if (!s.toLowerCase().startsWith("cabang ")) {
        s = `Cabang ${s}`;
      }
      return s;
    };

    const formattedData = data.map((item) => {
      let fotoUrl = null;
      if (item.foto) {
        fotoUrl = item.foto.startsWith("http")
          ? item.foto
          : `/uploads/layanan/${item.foto}`;
      }
      return {
        ...item,
        nama_cabang: cleanNamaCabang(item.nama_cabang),
        harga: Number(item.harga) || 0,
        durasi_menit: Number(item.durasi_menit) || 30,
        foto: fotoUrl,
        gambar: fotoUrl,
      };
    });

    return sendSuccess(res, "Katalog layanan berhasil dimuat", {
      items: formattedData,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total_records: totalCount?.total || 0,
        total_pages: Math.ceil((totalCount?.total || 0) / Number(limit)),
      },
    });
  } catch (err) {
    console.error("Layanan Error:", err);
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/layanan/:kode
 * Detail Layanan Treatment
 */
router.get("/:kode", async (req, res) => {
  try {
    const { kode } = req.params;

    const layanan = await DB("mst_layanan as l")
      .leftJoin("mst_kategori_layanan as k", "l.kode_kategori_layanan", "k.kode_kategori_layanan")
      .leftJoin("mst_ruangan as r", "l.kode_ruangan", "r.kode_ruangan")
      .where("l.kode_layanan", kode)
      .orWhere("l.id", kode)
      .select(
        "l.*",
        "l.nama as nama_layanan",
        "k.nama as kategori",
        "r.nama_ruangan"
      )
      .first();

    if (!layanan) {
      return sendError(res, "Layanan treatment tidak ditemukan", 404);
    }

    if (layanan.foto) {
      layanan.foto = layanan.foto.startsWith("http")
        ? layanan.foto
        : `/uploads/layanan/${layanan.foto}`;
      layanan.gambar = layanan.foto;
    }

    return sendSuccess(res, "Detail layanan berhasil dimuat", layanan);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
