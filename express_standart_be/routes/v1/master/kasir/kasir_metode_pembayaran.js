/**
 * @project Sistem Klinik Kecantikan
 * @file kasir_metode_pembayaran.js
 * @description Endpoint read-only daftar metode pembayaran aktif untuk kasir dengan filter multi-cabang
 */
import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { status } from "../../components/tools/general.js";
import { getBranchScope } from "../../components/tools/branch_scope.js";

const router = express.Router();

const handleGetKasirMetodePembayaran = async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const username = req?.auth?.username || "KASIR";
  const branchCode = getBranchScope(req, oPayload.kode_cabang);

  try {
    let query = DB("mst_metode_pembayaran")
      .where("status", "aktif")
      .where(function () {
        if (branchCode) {
          this.where("kode_cabang", branchCode).orWhereNull("kode_cabang");
        }
      });

    // Filter opsional berdasarkan tipe (rekening / qris) jika dikirim kasir
    if (oPayload.tipe) {
      query.where("tipe", (oPayload.tipe || "").toLowerCase().trim());
    }

    const records = await query.orderBy("urutan", "asc").orderBy("id", "asc");

    // Mapping nama cabang untuk label
    let branchMap = new Map();
    try {
      const branches = await DB("mst_cabang").select("kode_cabang", "nama_cabang");
      branchMap = new Map(branches.map((b) => [b.kode_cabang, b.nama_cabang]));
    } catch {
      // ignore
    }

    const host = process.env.APP_SERVER
      ? (process.env.APP_PORT ? `${process.env.APP_SERVER}:${process.env.APP_PORT}` : process.env.APP_SERVER)
      : (process.env.APP_PORT ? `http://127.0.0.1:${process.env.APP_PORT}` : "http://127.0.0.1:8000");

    const formattedData = records.map((item) => {
      let qrisUrl = null;
      let fullUrl = null;
      if (item.gambar_qris) {
        if (item.gambar_qris.startsWith("http://") || item.gambar_qris.startsWith("https://")) {
          qrisUrl = item.gambar_qris;
          fullUrl = item.gambar_qris;
        } else {
          const cleanFile = item.gambar_qris.replace(/^\/?(uploads\/qris\/|uploads\/)/, "");
          qrisUrl = `/uploads/qris/${cleanFile}`;
          fullUrl = `${host}${qrisUrl}`;
        }
      }

      return {
        id: Number(item.id),
        kode_metode: String(item.kode_metode),
        tipe: String(item.tipe),
        nama_bank: item.nama_bank ? String(item.nama_bank) : null,
        no_rekening: item.no_rekening ? String(item.no_rekening) : null,
        atas_nama: item.atas_nama ? String(item.atas_nama) : null,
        urutan: Number(item.urutan || 0),
        status: String(item.status),
        kode_cabang: item.kode_cabang ? String(item.kode_cabang) : null,
        nama_cabang: branchMap.get(item.kode_cabang) || (item.kode_cabang ? item.kode_cabang : "Semua Cabang"),
        gambar_qris: fullUrl || qrisUrl || null,
        gambar_qris_url: qrisUrl,
        gambar_qris_full_url: fullUrl,
      };
    });

    return res.status(200).json({
      status: status.SUKSES,
      message: "Daftar metode pembayaran aktif berhasil dimuat",
      datetime: formatDateSystem(),
      data: formattedData,
      total_data: formattedData.length,
    });
  } catch (error) {
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: error?.message || "Gagal memuat metode pembayaran kasir",
      datetime: formatDateSystem(),
    });
  }
};

router.get("/", handleGetKasirMetodePembayaran);
router.post("/", handleGetKasirMetodePembayaran);

export default router;
