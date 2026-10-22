/**
 * @file metode_pembayaran_data.js
 * @description Endpoint untuk mengambil daftar master data metode pembayaran (rekening bank & QRIS)
 */
import express from "express";
import DB from "../../../../core/config/knex.js";
import { status } from "../../components/tools/general.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";

const router = express.Router();

const handleGetData = async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const username = req?.auth?.username || "SYSTEM";

  try {
    let query = DB("mst_metode_pembayaran").select(
      "id",
      "kode_metode",
      "tipe",
      "nama_bank",
      "no_rekening",
      "atas_nama",
      "gambar_qris",
      "urutan",
      "status",
      "tz",
      "kode_cabang",
      "created_by",
      "created_at",
      "updated_by",
      "updated_at"
    );

    // Filter status
    if (oPayload.status) {
      query.where("status", oPayload.status);
    }

    // Filter tipe (rekening / qris)
    if (oPayload.tipe) {
      query.where("tipe", oPayload.tipe);
    }

    // Filter kode_cabang jika spesifik
    if (oPayload.kode_cabang) {
      if (oPayload.kode_cabang === "ALL" || oPayload.kode_cabang === "null") {
        query.whereNull("kode_cabang");
      } else {
        query.where("kode_cabang", oPayload.kode_cabang);
      }
    }

    // Search filter
    if (oPayload.search || oPayload.keyword) {
      const kw = `%${(oPayload.search || oPayload.keyword).trim()}%`;
      query.where((builder) => {
        builder
          .where("kode_metode", "like", kw)
          .orWhere("nama_bank", "like", kw)
          .orWhere("no_rekening", "like", kw)
          .orWhere("atas_nama", "like", kw);
      });
    }

    // Urutan: urutan ASC, lalu id ASC
    const records = await query.orderBy("urutan", "asc").orderBy("id", "asc");

    // Ambil mapping nama cabang
    let branchMap = new Map();
    try {
      const branches = await DB("mst_cabang").select("kode_cabang", "nama_cabang");
      branchMap = new Map(branches.map((b) => [b.kode_cabang, b.nama_cabang]));
    } catch (e) {
      // ignore
    }

    const host = process.env.APP_SERVER || "http://127.0.0.1:8000";
    const formattedData = records.map((item) => {
      let qrisUrl = null;
      if (item.gambar_qris) {
        if (item.gambar_qris.startsWith("http://") || item.gambar_qris.startsWith("https://")) {
          qrisUrl = item.gambar_qris;
        } else {
          const cleanFile = item.gambar_qris.replace(/^\/?(uploads\/qris\/|uploads\/)/, "");
          qrisUrl = `/uploads/qris/${cleanFile}`;
        }
      }

      return {
        ...item,
        nama_cabang: branchMap.get(item.kode_cabang) || (item.kode_cabang ? item.kode_cabang : "Semua Cabang"),
        urutan: Number(item.urutan || 0),
        gambar_qris_filename: item.gambar_qris,
        gambar_qris_url: qrisUrl,
        gambar_qris_full_url: qrisUrl ? (qrisUrl.startsWith("http") ? qrisUrl : `${host}${qrisUrl}`) : null,
      };
    });

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data metode pembayaran berhasil dimuat",
      datetime: formatDateSystem(),
      data: formattedData,
      total_data: formattedData.length,
    });
  } catch (error) {
    const oResult = {
      status: status.BAD_REQUEST,
      message: "Gagal memuat data metode pembayaran",
      datetime: formatDateSystem(),
    };
    Logging(error, {
      file: "routes/v1/master/metode_pembayaran/metode_pembayaran_data.js",
      func: "data",
      request: oPayload,
      response: oResult,
      user: username,
    });
    return res.status(500).json(oResult);
  }
};

router.post("/", handleGetData);
router.get("/", handleGetData);

export default router;
