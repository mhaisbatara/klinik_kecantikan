import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";

const router = express.Router();

/**
 * GET /api/v1/dokter
 * Daftar Dokter Klinik Kecantikan (dengan info jadwal & cabang)
 */
router.get("/", async (req, res) => {
  try {
    const { kode_cabang, search } = req.query;

    const query = DB("mst_karyawan as k")
      .leftJoin("mst_cabang as c", "k.kode_cabang", "c.kode_cabang")
      .where("k.status", "aktif")
      .andWhere(function () {
        this.where("k.jabatan", "like", "%dokter%")
          .orWhere("k.role", "dokter")
          .orWhereNotNull("k.no_sip");
      })
      .modify((qb) => {
        if (kode_cabang) {
          qb.where("k.kode_cabang", kode_cabang);
        }
        if (search) {
          const s = `%${search.toLowerCase()}%`;
          qb.whereRaw("LOWER(k.nama) LIKE ?", [s]);
        }
      });

    const dokterList = await query.select(
      "k.id",
      "k.kode_karyawan",
      "k.nama as nama",
      "k.jabatan",
      "k.no_sip",
      "k.kode_cabang",
      "c.nama_cabang"
    );

    // Ambil jadwal praktek untuk setiap dokter
    for (const d of dokterList) {
      if (d.no_sip) {
        d.jadwal = await DB("mst_jadwal_karyawan as j")
          .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
          .where("j.no_sip", d.no_sip)
          .where("j.status", "aktif")
          .select(
            "j.kode_jadwal",
            "j.hari",
            "j.jam_mulai",
            "j.jam_selesai",
            "j.kuota",
            "r.nama_ruangan"
          )
          .orderByRaw("FIELD(j.hari, 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu')");
      } else {
        d.jadwal = [];
      }
    }

    return sendSuccess(res, "Daftar dokter berhasil dimuat", dokterList);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * GET /api/v1/dokter/:no_sip/jadwal
 * Jadwal Praktek Dokter Tertentu
 */
router.get("/:no_sip/jadwal", async (req, res) => {
  try {
    const { no_sip } = req.params;

    const jadwal = await DB("mst_jadwal_karyawan as j")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .where("j.no_sip", no_sip)
      .where("j.status", "aktif")
      .select(
        "j.kode_jadwal",
        "j.hari",
        "j.jam_mulai",
        "j.jam_selesai",
        "j.kuota",
        "k.nama_karyawan as nama_dokter",
        "r.nama_ruangan",
        "r.kode_ruangan"
      )
      .orderByRaw("FIELD(j.hari, 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu')");

    return sendSuccess(res, "Jadwal dokter berhasil dimuat", jadwal);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
