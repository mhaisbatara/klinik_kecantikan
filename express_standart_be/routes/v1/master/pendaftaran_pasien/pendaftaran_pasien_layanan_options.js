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
    // 1. Fetch ALL ruangan aktif from DB
    const vaRuangan = await DB("mst_ruangan")
      .where("status", "aktif")
      .select("kode_ruangan", "nama_ruangan")
      .orderBy("id", "asc");

    // 2. Fetch layanan aktif
    const vaLayanan = await DB("mst_layanan as l")
      .leftJoin("mst_kategori_layanan as k", "l.kode_kategori_layanan", "k.kode_kategori_layanan")
      .leftJoin("mst_ruangan as r", "l.kode_ruangan", "r.kode_ruangan")
      .where("l.status", "aktif")
      .select(
        "l.kode_layanan",
        "l.kode_kategori_layanan",
        "k.nama as nama_kategori",
        "l.nama",
        "l.harga",
        "l.durasi_menit",
        "l.kode_ruangan",
        "r.nama_ruangan as nama_ruangan"
      )
      .orderBy("l.id", "asc");

    // Auto nonaktifkan paket yang sudah melewati tanggal_selesai
    const todayStr = formatDateSystem(new Date(), "yyyy-MM-dd");
    await DB("mst_paket_layanan")
      .where("status", "aktif")
      .whereNotNull("tanggal_selesai")
      .whereRaw("DATE(tanggal_selesai) < ?", [todayStr])
      .update({
        status: "nonaktif",
        updated_at: formatDateSystem(),
      });

    // 3. Fetch paket layanan aktif
    const vaPaket = await DB("mst_paket_layanan as p")
      .leftJoin("mst_ruangan as r", "p.kode_ruangan", "r.kode_ruangan")
      .where("p.status", "aktif")
      .select("p.kode_paket_layanan", "p.nama", "p.harga_paket", "p.masa_berlaku_hari", "p.tanggal_mulai", "p.tanggal_selesai", "p.kode_ruangan", "r.nama_ruangan as nama_ruangan")
      .orderBy("p.id", "asc");

    // Map layanan & paket grouped by ruangan (initialized with ALL DB rooms)
    const ruanganMap = new Map();
    vaRuangan.forEach((rng) => {
      ruanganMap.set(rng.kode_ruangan, {
        kode_ruangan: rng.kode_ruangan,
        nama_ruangan: rng.nama_ruangan || rng.kode_ruangan,
        deskripsi: "",
        items: [],
      });
    });

    vaLayanan.forEach((lay) => {
      const kodeRuang = lay.kode_ruangan || "LAINNYA";
      let rngObj = ruanganMap.get(kodeRuang);

      const itemData = {
        jenis: "layanan",
        kode_layanan: lay.kode_layanan,
        kode_kategori: lay.kode_kategori_layanan,
        nama_kategori: lay.nama_kategori || "",
        nama: lay.nama,
        harga: parseFloat(lay.harga || 0),
        durasi_menit: parseInt(lay.durasi_menit || 30, 10),
        kode_ruangan: lay.kode_ruangan || "",
        nama_ruangan: lay.nama_ruangan || lay.kode_ruangan || "Ruang Treatment",
      };

      if (!rngObj) {
        rngObj = {
          kode_ruangan: kodeRuang,
          nama_ruangan: lay.nama_ruangan || "Ruangan Lainnya",
          deskripsi: "",
          items: [],
        };
        ruanganMap.set(kodeRuang, rngObj);
      }
      rngObj.items.push(itemData);
    });

    // Format paket items & merge into ruanganMap
    const paketItems = vaPaket.map((pkt) => {
      const itemData = {
        jenis: "paket",
        kode_layanan: pkt.kode_paket_layanan,
        kode_kategori: "PAKET",
        nama_kategori: "Paket Layanan",
        nama: pkt.nama,
        harga: parseFloat(pkt.harga_paket || 0),
        durasi_menit: 60, // default estimasi durasi paket
        masa_berlaku_hari: pkt.masa_berlaku_hari,
        kode_ruangan: pkt.kode_ruangan || "",
        nama_ruangan: pkt.nama_ruangan || pkt.kode_ruangan || "Ruang Treatment",
      };

      const kodeRuang = pkt.kode_ruangan || "LAINNYA";
      let rngObj = ruanganMap.get(kodeRuang);
      if (!rngObj) {
        rngObj = {
          kode_ruangan: kodeRuang,
          nama_ruangan: pkt.nama_ruangan || "Ruangan Lainnya",
          deskripsi: "",
          items: [],
        };
        ruanganMap.set(kodeRuang, rngObj);
      }
      rngObj.items.push(itemData);

      return itemData;
    });

    // Output all ruangan data from database (all 5 rooms)
    const resultRuangan = Array.from(ruanganMap.values());

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data pilihan layanan dan paket ditemukan",
      datetime: formatDateSystem(),
      data: {
        ruangan_layanan: resultRuangan,
        kategori_layanan: resultRuangan,
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
