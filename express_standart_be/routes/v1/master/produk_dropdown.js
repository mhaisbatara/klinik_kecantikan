/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Sistem Klinik Kecantikan
 * @file produk_dropdown.js
 * @description Endpoint dropdown daftar produk aktif untuk form hasil treatment & rekomendasi
 *
 * @author Antigravity
 * @created 2026-08-27
 */

import express from "express";
import DB from "../../../core/config/knex.js";
import { formatDateSystem } from "../components/tools/date_tools.js";
import { Logging } from "../components/tools/servertool.js";
import { status } from "../components/tools/general.js";
import { getBranchScope } from "../components/tools/branch_scope.js";
import { getProdukBatchStockInfo } from "./inventori/batch_helper.js";

const router = express.Router();

const handleProdukDropdown = async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const username = req?.auth?.username || "system";
  const branchCode = getBranchScope(req, oPayload.kode_cabang);
  const search = oPayload.search || oPayload.keyword || "";

  try {
    let query = DB("mst_produk as pr")
      .leftJoin("mst_kategori_produk as kp", "pr.kode_kategori_produk", "kp.kode_kategori_produk")
      .where("pr.status", "aktif")
      .whereRaw("pr.kode_produk NOT LIKE 'CUSTOM-%' AND pr.kode_produk NOT LIKE 'CST-%'");

    if (branchCode) query = query.where("pr.kode_cabang", branchCode);

    query = query
      .select(
        "pr.kode_produk",
        "pr.nama",
        "pr.foto",
        "pr.harga_jual",
        "pr.satuan",
        "pr.stok_tersedia",
        "pr.tanggal_kadaluarsa",
        "pr.kode_kategori_produk",
        "kp.nama as nama_kategori"
      )
      .orderBy("pr.nama", "asc");

    if (search) {
      const lower = search.toLowerCase();
      query = query.where(function () {
        this.whereRaw("LOWER(pr.nama) LIKE ?", [`%${lower}%`])
          .orWhereRaw("LOWER(pr.kode_produk) LIKE ?", [`%${lower}%`]);
      });
    }

    const vaData = await query;
    const productCodes = vaData.map((p) => p.kode_produk);
    const batchStockMap = await getProdukBatchStockInfo(productCodes, branchCode);

    // Ambil promo aktif produk untuk hari ini
    const todayYmd = new Date().toISOString().slice(0, 10);
    const qPromos = DB("mst_promo as p")
      .join("mst_detail_promo as dp", "p.kode_promo", "dp.kode_promo")
      .where("p.status", "aktif")
      .where("dp.status", "aktif")
      .whereRaw("DATE(p.tanggal_mulai) <= ?", [todayYmd])
      .whereRaw("DATE(p.tanggal_selesai) >= ?", [todayYmd]);

    if (branchCode) {
      qPromos.where(function () {
        this.where("p.kode_cabang", branchCode).orWhereNull("p.kode_cabang");
      });
    }

    const activePromos = await qPromos.select(
      "p.kode_promo",
      "p.nama as nama_promo",
      "p.jenis_diskon",
      "p.nilai_diskon",
      "dp.jenis_item",
      "dp.kode_item"
    );

    const promoMap = {};
    activePromos.forEach((pr) => {
      const jenisClean = (pr.jenis_item || "").toLowerCase();
      if (jenisClean.includes("produk") || !jenisClean.includes("layanan")) {
        const key = pr.kode_item;
        if (!promoMap[key]) {
          promoMap[key] = pr;
        } else {
          const curVal = parseFloat(promoMap[key].nilai_diskon || 0);
          const newVal = parseFloat(pr.nilai_diskon || 0);
          if (newVal > curVal) {
            promoMap[key] = pr;
          }
        }
      }
    });

    const host = req.get("host");
    const protocol = req.protocol || "http";
    const assetsBase = `${protocol}://${host}`;

    const formattedData = vaData.map((item) => {
      const fotoUrl = item.foto
        ? (item.foto.startsWith("http") ? item.foto : `${assetsBase}/uploads/produk/${item.foto}`)
        : null;

      const rawHarga = parseFloat(item.harga_jual || 0);
      const promo = promoMap[item.kode_produk];
      const batchInfo = batchStockMap[item.kode_produk] || {
        stok_layak_jual: item.stok_tersedia || 0,
        stok_total_fisik: item.stok_tersedia || 0,
        is_expired: false,
        tanggal_kadaluarsa: item.tanggal_kadaluarsa || null,
        tanggal_kadaluarsa_terdekat: item.tanggal_kadaluarsa || null,
        total_batch_kadaluarsa: 0,
      };

      const stokLayakJual = batchInfo.stok_layak_jual;
      const isExpired = Boolean(batchInfo.is_expired);
      const expDate = batchInfo.tanggal_kadaluarsa || (item.tanggal_kadaluarsa ? String(item.tanggal_kadaluarsa).slice(0, 10) : null);
      const alasanExpired = isExpired
        ? `Batch kadaluarsa sejak ${batchInfo.tanggal_kadaluarsa_terdekat || expDate || 'beberapa hari lalu'}`
        : null;

      const baseItem = {
        ...item,
        foto: fotoUrl,
        stok_tersedia: stokLayakJual,
        stok_layak_jual: stokLayakJual,
        stok_total_fisik: batchInfo.stok_total_fisik,
        is_expired: isExpired,
        tanggal_kadaluarsa: expDate,
        tanggal_kadaluarsa_terdekat: batchInfo.tanggal_kadaluarsa_terdekat,
        alasan_expired: alasanExpired,
      };

      if (promo) {
        const diskonNilai = parseFloat(promo.nilai_diskon || 0);
        let hargaDiskon = rawHarga;
        if (promo.jenis_diskon === "persen") {
          hargaDiskon = Math.max(0, rawHarga - (rawHarga * diskonNilai) / 100);
        } else {
          hargaDiskon = Math.max(0, rawHarga - diskonNilai);
        }

        return {
          ...baseItem,
          is_promo: true,
          kode_promo: promo.kode_promo,
          nama_promo: promo.nama_promo,
          jenis_diskon: promo.jenis_diskon,
          nilai_diskon: diskonNilai,
          harga_asal: rawHarga,
          harga_promo: hargaDiskon,
        };
      }

      return {
        ...baseItem,
        is_promo: false,
        harga_asal: rawHarga,
        harga_promo: null,
      };
    });

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data produk berhasil dimuat",
      datetime: formatDateSystem(),
      data: formattedData,
    });
  } catch (error) {
    const oResult = {
      status: status.BAD_REQUEST,
      message: "Sistem sedang maintenance harap tunggu sebentar",
      datetime: formatDateSystem(),
    };
    Logging(error, {
      file: "/master/produk_dropdown.js",
      func: "dropdown",
      request: oPayload,
      response: oResult,
      user: username,
    });
    return res.status(500).json(oResult);
  }
};

router.get("/", handleProdukDropdown);
router.post("/", handleProdukDropdown);

export default router;
