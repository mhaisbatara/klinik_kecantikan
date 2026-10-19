import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { formatDateSystem } from "../../../utils/date_tools.js";
import { optionalAuth } from "../../../middleware/auth_middleware.js";

const router = express.Router();

/**
 * GET /api/v1/antrean/status
 * Cek Status Antrean Pasien yang Sedang Menunggu di Klinik Hari Ini
 */
router.get("/status", optionalAuth, async (req, res) => {
  try {
    const today = formatDateSystem(new Date(), "yyyy-MM-dd");
    const noRm = req.auth?.no_rm || req.query.no_rm;

    if (!noRm) {
      return sendError(res, "Nomor RM diperlukan untuk mengecek status antrean pribadi", 400);
    }

    // Ambil antrean pasien hari ini
    const antreanPasien = await DB("trx_antrian_layanan as a")
      .leftJoin("mst_ruangan as r", "a.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_pasien as p", "a.no_rm", "p.no_rm")
      .where("a.no_rm", noRm)
      .whereRaw("DATE(a.created_at) = ?", [today])
      .whereNotIn("a.status", ["batal"])
      .orderBy("a.id", "desc")
      .select(
        "a.id",
        "a.no_antrian",
        "a.status",
        "a.kode_ruangan",
        "r.nama_ruangan",
        "p.nama as nama_pasien",
        "a.created_at"
      )
      .first();

    if (!antreanPasien) {
      return sendSuccess(res, "Anda tidak memiliki antrean aktif untuk hari ini", null);
    }

    // Hitung nomor antrean yang sedang dipanggil saat ini di ruangan yang sama
    const antreanDipanggil = await DB("trx_antrian_layanan")
      .where("kode_ruangan", antreanPasien.kode_ruangan)
      .whereRaw("DATE(created_at) = ?", [today])
      .whereIn("status", ["dipanggil", "sedang_tindakan", "dilayani"])
      .orderBy("id", "desc")
      .select("no_antrian", "status")
      .first();

    // Hitung berapa orang yang mengantre di depan pasien
    const antreanDiDepan = await DB("trx_antrian_layanan")
      .where("kode_ruangan", antreanPasien.kode_ruangan)
      .whereRaw("DATE(created_at) = ?", [today])
      .where("status", "menunggu")
      .where("id", "<", antreanPasien.id)
      .count("id as total")
      .first();

    const jumlahDiDepan = parseInt(antreanDiDepan?.total || 0, 10);
    const estimasiMenit = jumlahDiDepan * 15; // Estimasi 15 menit per antrean

    return sendSuccess(res, "Status antrean berhasil dimuat", {
      antrean_pasien: antreanPasien,
      sedang_dipanggil: antreanDipanggil ? antreanDipanggil.no_antrian : "-",
      antrean_di_depan: jumlahDiDepan,
      estimasi_menit_tunggu: estimasiMenit,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/antrean/live
 * Live Antrean Klinik per Ruangan/Poli untuk Display Mobile
 */
router.get("/live", async (req, res) => {
  try {
    const today = formatDateSystem(new Date(), "yyyy-MM-dd");
    const { kode_cabang } = req.query;

    const ruanganList = await DB("mst_ruangan")
      .where("status", "aktif")
      .select("kode_ruangan", "nama_ruangan", "kode_cabang");

    const liveData = [];
    for (const r of ruanganList) {
      // Antrean sedang dipanggil
      const current = await DB("trx_antrian_layanan")
        .where("kode_ruangan", r.kode_ruangan)
        .whereRaw("DATE(created_at) = ?", [today])
        .whereIn("status", ["dipanggil", "sedang_tindakan", "dilayani"])
        .orderBy("id", "desc")
        .select("no_antrian", "status")
        .first();

      // Total antrean hari ini
      const totalCount = await DB("trx_antrian_layanan")
        .where("kode_ruangan", r.kode_ruangan)
        .whereRaw("DATE(created_at) = ?", [today])
        .whereNotIn("status", ["batal"])
        .count("id as total")
        .first();

      // Sisa menunggu
      const sisaCount = await DB("trx_antrian_layanan")
        .where("kode_ruangan", r.kode_ruangan)
        .whereRaw("DATE(created_at) = ?", [today])
        .where("status", "menunggu")
        .count("id as total")
        .first();

      liveData.push({
        kode_ruangan: r.kode_ruangan,
        nama_ruangan: r.nama_ruangan,
        nomor_aktif: current?.no_antrian || "-",
        status_aktif: current?.status || "kosong",
        sisa_antrean: parseInt(sisaCount?.total || 0, 10),
        total_antrean_hari_ini: parseInt(totalCount?.total || 0, 10),
      });
    }

    return sendSuccess(res, "Live antrean klinik berhasil dimuat", liveData);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
