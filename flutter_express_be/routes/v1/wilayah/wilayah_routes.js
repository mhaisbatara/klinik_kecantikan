/**
 * @file wilayah_routes.js
 * @description Wilayah Indonesia API (Provinsi, Kota/Kabupaten, Kecamatan, Kelurahan)
 */

import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";

const router = express.Router();
const BASE_URL = "https://emsifa.github.io/api-wilayah-indonesia/api";

const _cache = {};
async function fetchFallback(key, url) {
  if (_cache[key]) return _cache[key];
  try {
    const res = await fetch(url);
    if (!res.ok) return [];
    const data = await res.json();
    _cache[key] = data;
    return data;
  } catch (err) {
    return [];
  }
}

// 1. Handler Provinsi
router.all("/provinsi", async (req, res) => {
  try {
    let data = [];
    const hasTable = await DB.schema.hasTable("mst_provinsi");
    if (hasTable) {
      data = await DB("mst_provinsi").select("kode", "nama").orderBy("nama", "asc");
    }

    if (!data || data.length === 0) {
      const raw = await fetchFallback("prov", `${BASE_URL}/provinces.json`);
      data = raw.map((p) => ({ kode: String(p.id), nama: p.name }));
    }

    const formatted = data.map((p) => ({
      id: String(p.kode),
      kode: String(p.kode),
      nama: p.nama,
      name: p.nama,
    }));

    return sendSuccess(res, "OK", formatted);
  } catch (error) {
    return sendError(res, "Gagal memuat data provinsi", 500);
  }
});

// 2. Handler Kota / Kabupaten
router.all("/kota", async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const kode_provinsi = (oPayload.kode_provinsi || oPayload.id_provinsi || oPayload.province_id || "").trim();

  try {
    let data = [];
    const hasTable = await DB.schema.hasTable("mst_kabupaten");
    if (hasTable) {
      if (kode_provinsi) {
        data = await DB("mst_kabupaten")
          .select("kode", "kode_provinsi", "nama")
          .where("kode_provinsi", kode_provinsi)
          .orderBy("nama", "asc");
      } else {
        data = await DB("mst_kabupaten").select("kode", "kode_provinsi", "nama").orderBy("nama", "asc").limit(100);
      }
    }

    if ((!data || data.length === 0) && kode_provinsi) {
      const raw = await fetchFallback(`kab_${kode_provinsi}`, `${BASE_URL}/regencies/${kode_provinsi}.json`);
      data = raw.map((r) => ({
        kode: String(r.id),
        kode_provinsi: String(r.province_id || kode_provinsi),
        nama: r.name,
      }));
    }

    const formatted = data.map((k) => ({
      id: String(k.kode),
      kode: String(k.kode),
      kode_provinsi: String(k.kode_provinsi),
      nama: k.nama,
      name: k.nama,
    }));

    return sendSuccess(res, "OK", formatted);
  } catch (error) {
    return sendError(res, "Gagal memuat data kota/kabupaten", 500);
  }
});

// 3. Handler Kecamatan
router.all("/kecamatan", async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const kode_kota = (oPayload.kode_kota || oPayload.kode_kabupaten || oPayload.id_kabupaten || oPayload.regency_id || "").trim();

  try {
    let data = [];
    const hasTable = await DB.schema.hasTable("mst_kecamatan");
    if (hasTable) {
      if (kode_kota) {
        data = await DB("mst_kecamatan")
          .select("kode", "kode_kabupaten", "nama")
          .where("kode_kabupaten", kode_kota)
          .orderBy("nama", "asc");
      } else {
        data = await DB("mst_kecamatan").select("kode", "kode_kabupaten", "nama").orderBy("nama", "asc").limit(100);
      }
    }

    if ((!data || data.length === 0) && kode_kota) {
      const raw = await fetchFallback(`kec_${kode_kota}`, `${BASE_URL}/districts/${kode_kota}.json`);
      data = raw.map((c) => ({
        kode: String(c.id),
        kode_kabupaten: String(c.regency_id || kode_kota),
        nama: c.name,
      }));
    }

    const formatted = data.map((c) => ({
      id: String(c.kode),
      kode: String(c.kode),
      kode_kabupaten: String(c.kode_kabupaten),
      nama: c.nama,
      name: c.nama,
    }));

    return sendSuccess(res, "OK", formatted);
  } catch (error) {
    return sendError(res, "Gagal memuat data kecamatan", 500);
  }
});

// 4. Handler Kelurahan
router.all("/kelurahan", async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const kode_kecamatan = (oPayload.kode_kecamatan || oPayload.id_kecamatan || oPayload.district_id || "").trim();

  try {
    let data = [];
    const hasTable = await DB.schema.hasTable("mst_kelurahan");
    if (hasTable) {
      if (kode_kecamatan) {
        data = await DB("mst_kelurahan")
          .select("kode", "kode_kecamatan", "nama")
          .where("kode_kecamatan", kode_kecamatan)
          .orderBy("nama", "asc");
      } else {
        data = await DB("mst_kelurahan").select("kode", "kode_kecamatan", "nama").orderBy("nama", "asc").limit(100);
      }
    }

    if ((!data || data.length === 0) && kode_kecamatan) {
      const raw = await fetchFallback(`kel_${kode_kecamatan}`, `${BASE_URL}/villages/${kode_kecamatan}.json`);
      data = raw.map((l) => ({
        kode: String(l.id),
        kode_kecamatan: String(l.district_id || kode_kecamatan),
        nama: l.name,
      }));
    }

    const formatted = data.map((l) => ({
      id: String(l.kode),
      kode: String(l.kode),
      kode_kecamatan: String(l.kode_kecamatan),
      nama: l.nama,
      name: l.nama,
    }));

    return sendSuccess(res, "OK", formatted);
  } catch (error) {
    return sendError(res, "Gagal memuat data kelurahan/desa", 500);
  }
});

export default router;
