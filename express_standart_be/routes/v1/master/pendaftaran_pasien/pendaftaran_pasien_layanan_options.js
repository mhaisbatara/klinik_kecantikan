/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Sistem Klinik
 * @file pendaftaran_pasien_layanan_options.js
 * @description Endpoint untuk mengambil pilihan layanan aktif (per kategori) dan paket layanan aktif
 *
 * @author Antigravity
 * @created 2026-08-21
 */

import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";

const router = express.Router();

const handleGetOptions = async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const username = req?.auth?.username || "";

  try {
    // 1. Fetch kategori layanan aktif
    const vaKategori = await DB("mst_kategori_layanan")
      .where("status", "aktif")
      .select("kode_kategori_layanan", "nama", "deskripsi")
      .orderBy("id", "asc");

    // 2. Fetch layanan aktif
    const vaLayanan = await DB("mst_layanan as l")
      .leftJoin("mst_kategori_layanan as k", "l.kode_kategori_layanan", "k.kode_kategori_layanan")
      .where("l.status", "aktif")
      .select(
        "l.kode_layanan",
        "l.kode_kategori_layanan",
        "k.nama as nama_kategori",
        "l.nama",
        "l.harga",
        "l.durasi_menit"
      )
      .orderBy("l.id", "asc");

    // 3. Fetch paket layanan aktif
    const vaPaket = await DB("mst_paket_layanan")
      .where("status", "aktif")
      .select("kode_paket_layanan", "nama", "harga_paket", "masa_berlaku_hari")
      .orderBy("id", "asc");

    // Map layanan grouped by kategori
    const kategoriMap = new Map();
    vaKategori.forEach((kat) => {
      kategoriMap.set(kat.kode_kategori_layanan, {
        kode_kategori: kat.kode_kategori_layanan,
        nama_kategori: kat.nama,
        deskripsi: kat.deskripsi || "",
        items: [],
      });
    });

    vaLayanan.forEach((lay) => {
      const katObj = kategoriMap.get(lay.kode_kategori_layanan);
      const itemData = {
        jenis: "layanan",
        kode_layanan: lay.kode_layanan,
        kode_kategori: lay.kode_kategori_layanan,
        nama_kategori: lay.nama_kategori || "",
        nama: lay.nama,
        harga: parseFloat(lay.harga || 0),
        durasi_menit: parseInt(lay.durasi_menit || 30, 10),
      };

      if (katObj) {
        katObj.items.push(itemData);
      } else {
        // Fallback for categories not in active list
        kategoriMap.set(lay.kode_kategori_layanan, {
          kode_kategori: lay.kode_kategori_layanan,
          nama_kategori: lay.nama_kategori || "Lainnya",
          deskripsi: "",
          items: [itemData],
        });
      }
    });

    // Format paket items
    const paketItems = vaPaket.map((pkt) => ({
      jenis: "paket",
      kode_layanan: pkt.kode_paket_layanan,
      kode_kategori: "PAKET",
      nama_kategori: "Paket Layanan",
      nama: pkt.nama,
      harga: parseFloat(pkt.harga_paket || 0),
      durasi_menit: 60, // default estimasi durasi paket
      masa_berlaku_hari: pkt.masa_berlaku_hari,
    }));

    // Filter out categories with empty items
    const resultKategori = Array.from(kategoriMap.values()).filter(
      (k) => k.items.length > 0
    );

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data pilihan layanan dan paket ditemukan",
      datetime: formatDateSystem(),
      data: {
        kategori_layanan: resultKategori,
        paket_layanan: paketItems,
      },
    });
  } catch (error) {
    const oResult = {
      status: status.BAD_REQUEST,
      message: "Sistem sedang maintenance harap tunggu sebentar",
      datetime: formatDateSystem(),
    };

    Logging(error, {
      file: "/master/pendaftaran_pasien/pendaftaran_pasien_layanan_options.js",
      func: "get_options",
      request: oPayload,
      response: oResult,
      user: username,
    });

    return res.status(500).json(oResult);
  }
};

router.get("/", handleGetOptions);
router.post("/", handleGetOptions);

export default router;
