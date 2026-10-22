/**
 * @file metode_pembayaran_create.js
 * @description Endpoint untuk menambah master data metode pembayaran baru (rekening atau QRIS)
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
      message: "Akses ditolak: Hanya Superadmin yang berhak menambah metode pembayaran",
      datetime: formatDateSystem(),
    });
  }

  // Type casting & sanitasi dasar
  const tipe = (oPayload.tipe || "").toLowerCase().trim();
  const nama_bank = (oPayload.nama_bank || "").trim() || null;
  const no_rekening = (oPayload.no_rekening || "").trim() || null;
  const atas_nama = (oPayload.atas_nama || "").trim() || null;
  const urutan = !isNaN(parseInt(oPayload.urutan, 10)) ? parseInt(oPayload.urutan, 10) : 0;
  const statusMetode = ["aktif", "nonaktif"].includes((oPayload.status || "").toLowerCase())
    ? oPayload.status.toLowerCase()
    : "aktif";
  const rawCabang = (oPayload.kode_cabang || "").toString().trim();
  const kode_cabang = rawCabang && rawCabang !== "[object Object]" && rawCabang !== "null" && rawCabang !== "undefined"
    ? rawCabang
    : null;

  // 1. Validasi Tipe
  if (!["rekening", "qris"].includes(tipe)) {
    files?.forEach((f) => {
      if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
    });
    return res.status(422).json({
      status: status.BAD_REQUEST,
      message: "Tipe metode pembayaran harus 'rekening' atau 'qris'",
      datetime: formatDateSystem(),
    });
  }

  // 2. Validasi Tipe Rekening
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
    // Validasi hanya angka
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

  // 3. Validasi Tipe QRIS & File Upload
  const oFileQris = files?.find((f) => f.fieldname === "gambar_qris" || f.fieldname === "qris" || f.fieldname === "file");
  let savedQrisFilename = null;

  if (tipe === "qris") {
    if (!oFileQris) {
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "File gambar QRIS wajib diunggah untuk tipe QRIS",
        datetime: formatDateSystem(),
      });
    }

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

  try {
    let createdRecord = null;

    await DB.transaction(async (trx) => {
      // Auto-generate kode_metode: MP-001, MP-002, dst.
      const allCodes = await trx("mst_metode_pembayaran")
        .where("kode_metode", "like", "MP-%")
        .select("kode_metode");

      let maxNum = 0;
      for (const row of allCodes) {
        const num = parseInt((row.kode_metode || "").replace(/^MP-/i, ""), 10);
        if (!isNaN(num) && num > maxNum) maxNum = num;
      }
      const kodeMetode = `MP-${String(maxNum + 1).padStart(3, "0")}`;

      // Simpan file QRIS jika ada
      if (tipe === "qris" && oFileQris) {
        const ext = path.extname(oFileQris.originalname).toLowerCase();
        const uploadDir = path.join(process.cwd(), "public", "uploads", "qris");
        if (!fs.existsSync(uploadDir)) {
          fs.mkdirSync(uploadDir, { recursive: true });
        }

        const filename = `qris_${kodeMetode}_${Date.now()}${ext}`;
        const targetPath = path.join(uploadDir, filename);
        fs.renameSync(oFileQris.path, targetPath);
        savedQrisFilename = filename;
      } else if (oFileQris) {
        // Jika upload file tetapi tipe rekening, hapus temp file
        if (fs.existsSync(oFileQris.path)) fs.unlinkSync(oFileQris.path);
      }

      const insertData = {
        kode_metode: kodeMetode,
        tipe: tipe,
        nama_bank: tipe === "rekening" ? nama_bank : null,
        no_rekening: tipe === "rekening" ? no_rekening : null,
        atas_nama: tipe === "rekening" ? atas_nama : null,
        gambar_qris: tipe === "qris" ? savedQrisFilename : null,
        urutan: urutan,
        status: statusMetode,
        tz: "Asia/Jakarta",
        kode_cabang: kode_cabang,
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      };

      const [insertId] = await trx("mst_metode_pembayaran").insert(insertData);
      createdRecord = { id: insertId, ...insertData };
    });

    return res.status(200).json({
      status: status.SUKSES,
      message: `Metode pembayaran ${createdRecord.kode_metode} berhasil ditambahkan`,
      datetime: formatDateSystem(),
      data: {
        id: Number(createdRecord.id),
        kode_metode: String(createdRecord.kode_metode),
        tipe: String(createdRecord.tipe),
        nama_bank: createdRecord.nama_bank ? String(createdRecord.nama_bank) : null,
        no_rekening: createdRecord.no_rekening ? String(createdRecord.no_rekening) : null,
        atas_nama: createdRecord.atas_nama ? String(createdRecord.atas_nama) : null,
        gambar_qris: createdRecord.gambar_qris ? String(createdRecord.gambar_qris) : null,
        urutan: Number(createdRecord.urutan || 0),
        status: String(createdRecord.status),
        tz: String(createdRecord.tz || "Asia/Jakarta"),
        kode_cabang: createdRecord.kode_cabang ? String(createdRecord.kode_cabang) : null,
        created_by: String(createdRecord.created_by),
        created_at: String(createdRecord.created_at),
        updated_by: String(createdRecord.updated_by),
        updated_at: String(createdRecord.updated_at),
      },
    });
  } catch (error) {
    // Bersihkan file jika gagal simpan
    if (savedQrisFilename) {
      const savedPath = path.join(process.cwd(), "public", "uploads", "qris", savedQrisFilename);
      if (fs.existsSync(savedPath)) fs.unlinkSync(savedPath);
    }
    files?.forEach((f) => {
      if (fs.existsSync(f.path)) fs.unlinkSync(f.path);
    });

    const oResult = {
      status: status.BAD_REQUEST,
      message: error?.message || "Gagal menambahkan metode pembayaran",
      datetime: formatDateSystem(),
    };
    Logging(error, {
      file: "routes/v1/master/metode_pembayaran/metode_pembayaran_create.js",
      func: "create",
      request: oPayload,
      response: oResult,
      user: username,
    });
    return res.status(500).json(oResult);
  }
});

export default router;
