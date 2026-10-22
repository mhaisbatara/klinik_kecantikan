/**
 * @file metode_pembayaran_update.js
 * @description Endpoint untuk memperbarui master data metode pembayaran (rekening atau QRIS)
 */
import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs";
import DB from "../../../../core/config/knex.js";
import { status } from "../../components/tools/general.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";

const router = express.Router();

const upload = multer({
  dest: "temp/",
  limits: { fileSize: 2 * 1024 * 1024 }, // Maksimal 2MB
});

router.post("/", upload.any(), async (req, res) => {
  const { body, files, auth } = req;
  const oPayload = { ...body };
  const username = auth?.username || req?.auth?.username || "superadmin";
  const userRole = (auth?.role || req?.auth?.role || "").toLowerCase();

  // Role check: hanya superadmin (atau dev)
  if (userRole && userRole !== "superadmin" && userRole !== "dev") {
    files?.forEach((f) => {
      if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
    });
    return res.status(403).json({
      status: status.FORBIDDEN || 403,
      message: "Akses ditolak: Hanya Superadmin yang berhak mengedit metode pembayaran",
      datetime: formatDateSystem(),
    });
  }

  const kode_metode = (oPayload.kode_metode || "").trim();
  if (!kode_metode) {
    files?.forEach((f) => {
      if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
    });
    return res.status(422).json({
      status: status.BAD_REQUEST,
      message: "Kode metode pembayaran wajib diisi",
      datetime: formatDateSystem(),
    });
  }

  // Ambil record yang sudah ada
  const existing = await DB("mst_metode_pembayaran").where("kode_metode", kode_metode).first();
  if (!existing) {
    files?.forEach((f) => {
      if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
    });
    return res.status(404).json({
      status: status.NOT_FOUND || 404,
      message: `Data metode pembayaran ${kode_metode} tidak ditemukan`,
      datetime: formatDateSystem(),
    });
  }

  const tipe = (oPayload.tipe || existing.tipe || "").toLowerCase().trim();
  const nama_bank = oPayload.nama_bank !== undefined ? (oPayload.nama_bank || "").trim() || null : existing.nama_bank;
  const no_rekening = oPayload.no_rekening !== undefined ? (oPayload.no_rekening || "").trim() || null : existing.no_rekening;
  const atas_nama = oPayload.atas_nama !== undefined ? (oPayload.atas_nama || "").trim() || null : existing.atas_nama;
  const urutan = oPayload.urutan !== undefined && !isNaN(parseInt(oPayload.urutan, 10)) ? parseInt(oPayload.urutan, 10) : existing.urutan;
  const statusMetode = oPayload.status !== undefined && ["aktif", "nonaktif"].includes(oPayload.status.toLowerCase())
    ? oPayload.status.toLowerCase()
    : existing.status;
  let kode_cabang = existing.kode_cabang;
  if (oPayload.kode_cabang !== undefined) {
    const rawCabang = (oPayload.kode_cabang || "").toString().trim();
    kode_cabang = rawCabang && rawCabang !== "[object Object]" && rawCabang !== "null" && rawCabang !== "undefined"
      ? rawCabang
      : null;
  }

  // Validasi tipe rekening
  if (tipe === "rekening") {
    if (!nama_bank) {
      files?.forEach((f) => {
        if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
      });
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "Nama bank wajib diisi untuk tipe rekening",
        datetime: formatDateSystem(),
      });
    }
    if (!no_rekening) {
      files?.forEach((f) => {
        if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
      });
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "Nomor rekening wajib diisi untuk tipe rekening",
        datetime: formatDateSystem(),
      });
    }
    if (!/^\d+$/.test(no_rekening)) {
      files?.forEach((f) => {
        if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
      });
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "Nomor rekening hanya boleh berisi angka",
        datetime: formatDateSystem(),
      });
    }
    if (!atas_nama) {
      files?.forEach((f) => {
        if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
      });
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "Atas nama pemilik rekening wajib diisi",
        datetime: formatDateSystem(),
      });
    }
  }

  // Validasi file QRIS jika ada upload
  const oFileQris = files?.find((f) => f.fieldname === "gambar_qris" || f.fieldname === "qris" || f.fieldname === "file");
  if (oFileQris) {
    const allowedExt = [".jpg", ".jpeg", ".png", ".webp"];
    const ext = path.extname(oFileQris.originalname).toLowerCase();
    if (!allowedExt.includes(ext)) {
      files?.forEach((f) => {
        if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
      });
      return res.status(400).json({
        status: status.BAD_REQUEST,
        message: "Format file QRIS tidak didukung. Harap gunakan file JPG, JPEG, PNG, atau WEBP",
        datetime: formatDateSystem(),
      });
    }
  }

  // Jika tipe QRIS tapi belum ada file dan tidak upload baru
  if (tipe === "qris" && !existing.gambar_qris && !oFileQris) {
    return res.status(422).json({
      status: status.BAD_REQUEST,
      message: "File gambar QRIS wajib diunggah untuk tipe QRIS",
      datetime: formatDateSystem(),
    });
  }

  let newSavedFilename = null;
  const oldQrisFilename = existing.gambar_qris;

  try {
    const uploadDir = path.join(process.cwd(), "public", "uploads", "qris");
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    // Jika upload gambar QRIS baru
    if (tipe === "qris" && oFileQris) {
      const ext = path.extname(oFileQris.originalname).toLowerCase();
      const filename = `qris_${kode_metode}_${Date.now()}${ext}`;
      const targetPath = path.join(uploadDir, filename);
      fs.renameSync(oFileQris.path, targetPath);
      newSavedFilename = filename;

      // Hapus file QRIS lama dari storage
      if (oldQrisFilename && oldQrisFilename !== "qris_dummy_default.png") {
        const cleanOld = oldQrisFilename.replace(/^\/?(uploads\/qris\/|uploads\/)/, "");
        const oldPath = path.join(uploadDir, cleanOld);
        if (fs.existsSync(oldPath)) {
          try {
            fs.unlinkSync(oldPath);
          } catch (e) {
            console.warn("Gagal menghapus file QRIS lama:", e.message);
          }
        }
      }
    } else if (oFileQris) {
      if (fs.existsSync(oFileQris.path)) fs.unlinkSync(oFileQris.path);
    }

    // Jika beralih dari qris ke rekening, hapus file QRIS lama
    if (tipe === "rekening" && oldQrisFilename && oldQrisFilename !== "qris_dummy_default.png") {
      const cleanOld = oldQrisFilename.replace(/^\/?(uploads\/qris\/|uploads\/)/, "");
      const oldPath = path.join(uploadDir, cleanOld);
      if (fs.existsSync(oldPath)) {
        try {
          fs.unlinkSync(oldPath);
        } catch (e) {
          console.warn("Gagal menghapus file QRIS lama:", e.message);
        }
      }
    }

    const updateData = {
      tipe: tipe,
      nama_bank: tipe === "rekening" ? nama_bank : null,
      no_rekening: tipe === "rekening" ? no_rekening : null,
      atas_nama: tipe === "rekening" ? atas_nama : null,
      gambar_qris: tipe === "qris" ? (newSavedFilename || existing.gambar_qris) : null,
      urutan: urutan,
      status: statusMetode,
      kode_cabang: kode_cabang,
      updated_by: username,
      updated_at: formatDateSystem(),
    };

    await DB("mst_metode_pembayaran").where("kode_metode", kode_metode).update(updateData);

    return res.status(200).json({
      status: status.SUKSES,
      message: `Metode pembayaran ${kode_metode} berhasil diperbarui`,
      datetime: formatDateSystem(),
      data: {
        kode_metode: String(kode_metode),
        tipe: String(updateData.tipe),
        nama_bank: updateData.nama_bank ? String(updateData.nama_bank) : null,
        no_rekening: updateData.no_rekening ? String(updateData.no_rekening) : null,
        atas_nama: updateData.atas_nama ? String(updateData.atas_nama) : null,
        gambar_qris: updateData.gambar_qris ? String(updateData.gambar_qris) : null,
        urutan: Number(updateData.urutan || 0),
        status: String(updateData.status),
        kode_cabang: updateData.kode_cabang ? String(updateData.kode_cabang) : null,
        updated_by: String(updateData.updated_by),
        updated_at: String(updateData.updated_at),
      },
    });
  } catch (error) {
    if (newSavedFilename) {
      const savedPath = path.join(process.cwd(), "public", "uploads", "qris", newSavedFilename);
      if (fs.existsSync(savedPath)) fs.unlinkSync(savedPath);
    }
    files?.forEach((f) => {
      if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
    });

    const oResult = {
      status: status.BAD_REQUEST,
      message: error?.message || "Gagal memperbarui metode pembayaran",
      datetime: formatDateSystem(),
    };
    Logging(error, {
      file: "routes/v1/master/metode_pembayaran/metode_pembayaran_update.js",
      func: "update",
      request: oPayload,
      response: oResult,
      user: username,
    });
    return res.status(500).json(oResult);
  }
});

export default router;
