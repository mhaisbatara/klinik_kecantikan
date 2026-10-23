import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";

const router = express.Router();

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

/**
 * GET /api/v1/cabang
 * Daftar Cabang Klinik Kecantikan
 */
router.get("/", async (req, res) => {
  try {
    const hasCabangTable = await DB.schema.hasTable("mst_cabang");
    if (!hasCabangTable) {
      return sendSuccess(res, "Daftar cabang", [
        {
          kode_cabang: "CBG-001",
          nama_cabang: "Cabang Utama",
          alamat: "Kantor Pusat Klinik Kecantikan",
          telp: "081234567890",
        },
      ]);
    }

    const cabang = await DB("mst_cabang")
      .where("status", "aktif")
      .orWhere("status", "1")
      .select(
        "id",
        "kode_cabang",
        "nama_cabang",
        "alamat",
        "no_telp as telp",
        "email",
        "pj_manager",
        "status"
      );

    const formattedCabang = cabang.map((c) => ({
      ...c,
      nama_cabang: cleanNamaCabang(c.nama_cabang),
    }));

    return sendSuccess(res, "Daftar cabang berhasil dimuat", formattedCabang);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
