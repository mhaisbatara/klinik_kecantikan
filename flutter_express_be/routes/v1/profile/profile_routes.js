import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { formatDateSystem } from "../../../utils/date_tools.js";
import { authenticateMobile } from "../../../middleware/auth_middleware.js";
import { upload } from "../../../middleware/upload_middleware.js";

const router = express.Router();

/**
 * GET /api/v1/profile
 * Profil Lengkap Pengguna / Pasien
 */
router.get("/", authenticateMobile, async (req, res) => {
  const user = req.auth;

  try {
    const cred = await DB("user_credential as u")
      .leftJoin("mst_cabang as c", "u.kode_cabang", "c.kode_cabang")
      .where("u.user_code", user.user_code)
      .select(
        "u.id",
        "u.user_code",
        "u.username",
        "u.fullname",
        "u.telp",
        "u.role",
        "u.kode_cabang",
        "c.nama_cabang"
      )
      .first();

    let pasien = null;
    if (user.no_rm) {
      pasien = await DB("mst_pasien").where("no_rm", user.no_rm).first();
    } else {
      pasien = await DB("mst_pasien")
        .where("no_hp", cred?.telp)
        .orWhere("email", cred?.username)
        .first();
    }

    return sendSuccess(res, "Profil pengguna berhasil dimuat", {
      user: cred,
      pasien: pasien,
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * PUT /api/v1/profile
 * Update Informasi Profil Pasien
 */
router.put("/", authenticateMobile, async (req, res) => {
  const user = req.auth;
  const {
    nama,
    no_hp,
    alamat,
    tempat_lahir,
    tanggal_lahir,
    jenis_kelamin,
    alergi,
    nama_kontak_darurat,
    no_hp_kontak_darurat,
  } = req.body || {};

  try {
    let noRm = user.no_rm;
    if (!noRm) {
      const p = await DB("mst_pasien").where("no_hp", user.username).first();
      if (p) noRm = p.no_rm;
    }

    if (noRm) {
      const updateData = {};
      if (nama) updateData.nama = nama;
      if (no_hp) updateData.no_hp = no_hp;
      if (alamat) updateData.patokan = alamat;
      if (tempat_lahir) updateData.tempat_lahir = tempat_lahir;
      if (tanggal_lahir) updateData.tanggal_lahir = tanggal_lahir;
      if (jenis_kelamin) updateData.jenis_kelamin = jenis_kelamin;
      if (alergi !== undefined) updateData.alergi = alergi;
      if (nama_kontak_darurat) updateData.nama_kontak_darurat = nama_kontak_darurat;
      if (no_hp_kontak_darurat) updateData.no_hp_kontak_darurat = no_hp_kontak_darurat;
      updateData.updated_at = formatDateSystem();

      await DB("mst_pasien").where("no_rm", noRm).update(updateData);
    }

    // Update user_credential
    const userUpdate = {};
    if (nama) userUpdate.fullname = nama;
    if (no_hp) userUpdate.telp = no_hp;
    if (Object.keys(userUpdate).length > 0) {
      userUpdate.updated_at = formatDateSystem();
      await DB("user_credential")
        .where("user_code", user.user_code)
        .update(userUpdate);
    }

    return sendSuccess(res, "Profil berhasil diperbarui");
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

/**
 * POST /api/v1/profile/foto
 * Upload Foto Profil Pasien
 */
router.post(
  "/foto",
  authenticateMobile,
  upload.single("foto"),
  async (req, res) => {
    if (!req.file) {
      return sendError(res, "File foto wajib diupload (field: 'foto')", 400);
    }

    try {
      const fileName = req.file.filename;
      const fileUrl = `/uploads/${fileName}`;

      const noRm = req.auth.no_rm;
      if (noRm) {
        await DB("mst_pasien")
          .where("no_rm", noRm)
          .update({
            foto: fileUrl,
            updated_at: formatDateSystem(),
          });
      }

      return sendSuccess(res, "Foto profil berhasil diupload", {
        foto_url: fileUrl,
        filename: fileName,
      });
    } catch (err) {
      return sendError(res, err.message, 500);
    }
  }
);

export default router;
