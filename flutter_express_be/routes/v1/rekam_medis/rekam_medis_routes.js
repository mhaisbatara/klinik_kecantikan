import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { authenticateMobile } from "../../../middleware/auth_middleware.js";

const router = express.Router();

/**
 * GET /api/v1/rekam-medis
 * Riwayat Pemeriksaan & Treatment Pasien
 */
router.get("/", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const noRm = user.no_rm;

  if (!noRm) {
    return sendSuccess(res, "Riwayat medis pasien", []);
  }

  try {
    const records = await DB("trx_rekam_medis as rm")
      .leftJoin("mst_karyawan as k", "rm.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "rm.kode_ruangan", "r.kode_ruangan")
      .where("rm.no_rm", noRm)
      .orderBy("rm.tgl_periksa", "desc")
      .select(
        "rm.id",
        "rm.no_rm",
        "rm.tgl_periksa",
        "rm.keluhan_utama",
        "rm.diagnosa",
        "rm.tindakan",
        "rm.saran_anjuran",
        "k.nama_karyawan as nama_dokter",
        "r.nama_ruangan",
        "rm.created_at"
      );

    return sendSuccess(res, "Riwayat rekam medis berhasil dimuat", records);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/rekam-medis/:id
 * Detail Rekam Medis Pasien (Termasuk Foto Sebelum & Sesudah Treatment)
 */
router.get("/:id", authenticateMobile, async (req, res) => {
  try {
    const { id } = req.params;

    const record = await DB("trx_rekam_medis as rm")
      .leftJoin("mst_pasien as p", "rm.no_rm", "p.no_rm")
      .leftJoin("mst_karyawan as k", "rm.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "rm.kode_ruangan", "r.kode_ruangan")
      .where("rm.id", id)
      .select(
        "rm.*",
        "p.nama as nama_pasien",
        "k.nama_karyawan as nama_dokter",
        "r.nama_ruangan"
      )
      .first();

    if (!record) {
      return sendError(res, "Data rekam medis tidak ditemukan", 404);
    }

    // Ambil foto before/after jika tabel trx_rekam_medis_foto ada
    let fotos = [];
    const hasFotoTable = await DB.schema.hasTable("trx_rekam_medis_foto");
    if (hasFotoTable) {
      fotos = await DB("trx_rekam_medis_foto")
        .where("id_rekam_medis", id)
        .orWhere("no_rm", record.no_rm)
        .select("*");
    }

    return sendSuccess(res, "Detail rekam medis berhasil dimuat", {
      ...record,
      foto_treatment: fotos,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
