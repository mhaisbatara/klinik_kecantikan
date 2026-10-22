/**
 * @file metode_pembayaran_routes.js
 * @description Endpoint untuk Mobile App: Mengambil daftar metode pembayaran (rekening bank & QRIS) yang aktif
 */
import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { optionalAuth } from "../../../middleware/auth_middleware.js";

const router = express.Router();

/**
 * GET /api/v1/metode-pembayaran
 * Mengambil daftar metode pembayaran aktif, urut berdasarkan urutan lalu id
 * Query: ?kode_cabang=CBG-001 (opsional: ambil cabang tertentu + data umum yang kode_cabang NULL)
 */
router.get("/", optionalAuth, async (req, res) => {
  try {
    const hasTable = await DB.schema.hasTable("mst_metode_pembayaran");
    if (!hasTable) {
      return sendSuccess(res, "Daftar metode pembayaran", {
        total: 0,
        metode_pembayaran: [],
        grouped: { rekening: [], qris: [] },
      });
    }

    const { kode_cabang } = req.query;
    const branchCode = kode_cabang || req.auth?.kode_cabang || null;

    let query = DB("mst_metode_pembayaran")
      .where("status", "aktif")
      .select(
        "id",
        "kode_metode",
        "tipe",
        "nama_bank",
        "no_rekening",
        "atas_nama",
        "gambar_qris",
        "urutan",
        "status",
        "kode_cabang"
      );

    if (branchCode) {
      query.andWhere((builder) => {
        builder.where("kode_cabang", branchCode).orWhereNull("kode_cabang");
      });
    }

    const list = await query.orderBy("urutan", "asc").orderBy("id", "asc");

    // Ambil nama cabang untuk mapping
    let branchMap = new Map();
    try {
      const branches = await DB("mst_cabang").select("kode_cabang", "nama_cabang");
      branchMap = new Map(branches.map((b) => [b.kode_cabang, b.nama_cabang]));
    } catch (e) {
      // ignore
    }

    const baseUrl = process.env.APP_SERVER || "http://127.0.0.1:8008";

    const formattedData = list.map((item) => {
      let qrisUrl = null;
      if (item.gambar_qris) {
        if (item.gambar_qris.startsWith("http://") || item.gambar_qris.startsWith("https://")) {
          qrisUrl = item.gambar_qris;
        } else {
          const cleanFile = item.gambar_qris.replace(/^\/?(uploads\/qris\/|uploads\/)/, "");
          qrisUrl = `${baseUrl}/uploads/qris/${cleanFile}`;
        }
      }

      return {
        id: item.id,
        kode_metode: item.kode_metode,
        tipe: item.tipe,
        nama_bank: item.nama_bank || null,
        no_rekening: item.no_rekening || null,
        atas_nama: item.atas_nama || null,
        gambar_qris: qrisUrl,
        urutan: Number(item.urutan || 0),
        status: item.status,
        kode_cabang: item.kode_cabang || null,
        nama_cabang: branchMap.get(item.kode_cabang) || (item.kode_cabang ? item.kode_cabang : "Semua Cabang"),
      };
    });

    const rekeningList = formattedData.filter((i) => i.tipe === "rekening");
    const qrisList = formattedData.filter((i) => i.tipe === "qris");

    return sendSuccess(res, "Daftar metode pembayaran berhasil dimuat", {
      total: formattedData.length,
      metode_pembayaran: formattedData,
      grouped: {
        rekening: rekeningList,
        qris: qrisList,
      },
    });
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
