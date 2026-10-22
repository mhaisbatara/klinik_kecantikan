/**
 * @file metode_pembayaran_delete.js
 * @description Endpoint untuk menghapus data metode pembayaran (rekening atau QRIS)
 */
import express from "express";
import path from "path";
import fs from "fs";
import DB from "../../../../core/config/knex.js";
import { status } from "../../components/tools/general.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";

const router = express.Router();

router.post("/", async (req, res) => {
  const oPayload = { ...req.body };
  const username = req?.auth?.username || "superadmin";
  const userRole = (req?.auth?.role || "").toLowerCase();

  // Role check: hanya superadmin (atau dev)
  if (userRole && userRole !== "superadmin" && userRole !== "dev") {
    return res.status(403).json({
      status: status.FORBIDDEN || 403,
      message: "Akses ditolak: Hanya Superadmin yang berhak menghapus metode pembayaran",
      datetime: formatDateSystem(),
    });
  }

  let codes = [];
  if (Array.isArray(oPayload.kode_metode)) {
    codes = oPayload.kode_metode.filter(Boolean);
  } else if (typeof oPayload.kode_metode === "string" && oPayload.kode_metode.trim()) {
    codes = [oPayload.kode_metode.trim()];
  }

  if (codes.length === 0) {
    return res.status(422).json({
      status: status.BAD_REQUEST,
      message: "Parameter kode_metode wajib diisi",
      datetime: formatDateSystem(),
    });
  }

  try {
    const uploadDir = path.join(process.cwd(), "public", "uploads", "qris");

    // Ambil data yang akan dihapus untuk membersihkan file QRIS
    const records = await DB("mst_metode_pembayaran").whereIn("kode_metode", codes).select("kode_metode", "gambar_qris");

    for (const item of records) {
      if (item.gambar_qris && item.gambar_qris !== "qris_dummy_default.png") {
        const cleanFile = item.gambar_qris.replace(/^\/?(uploads\/qris\/|uploads\/)/, "");
        const filePath = path.join(uploadDir, cleanFile);
        if (fs.existsSync(filePath)) {
          try {
            fs.unlinkSync(filePath);
          } catch (e) {
            console.warn("Gagal menghapus file QRIS:", filePath, e.message);
          }
        }
      }
    }

    const deletedCount = await DB("mst_metode_pembayaran").whereIn("kode_metode", codes).del();

    return res.status(200).json({
      status: status.SUKSES,
      message: `${deletedCount} metode pembayaran berhasil dihapus`,
      datetime: formatDateSystem(),
      deleted_codes: codes,
    });
  } catch (error) {
    const oResult = {
      status: status.BAD_REQUEST,
      message: error?.message || "Gagal menghapus metode pembayaran",
      datetime: formatDateSystem(),
    };
    Logging(error, {
      file: "routes/v1/master/metode_pembayaran/metode_pembayaran_delete.js",
      func: "delete",
      request: oPayload,
      response: oResult,
      user: username,
    });
    return res.status(500).json(oResult);
  }
});

export default router;
