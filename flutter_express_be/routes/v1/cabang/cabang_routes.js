import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";

const router = express.Router();

const cleanNamaCabang = (name) => {
  if (!name) return "Cabang Utama";
  let s = String(name).trim();
  if (s.toLowerCase().startsWith("klinik ")) {
    s = s.slice(7).trim();
  }
  if (!s.toLowerCase().startsWith("cabang ")) {
    s = `Cabang ${s}`;
  }
  return s;
};

const DAY_NAMES = {
  1: "Senin",
  2: "Selasa",
  3: "Rabu",
  4: "Kamis",
  5: "Jumat",
  6: "Sabtu",
  7: "Minggu",
};

/**
 * Format hari operasional ringkas:
 * Contoh: 1..7 -> "Senin – Minggu"
 * 1..5 -> "Senin – Jumat"
 * 1,3,5 -> "Senin, Rabu, Jumat"
 */
export const formatHariOperasional = (hariOperasional) => {
  if (!hariOperasional) return "Senin – Minggu";
  const days = String(hariOperasional)
    .split(",")
    .map((d) => parseInt(d.trim(), 10))
    .filter((d) => d >= 1 && d <= 7);

  const uniqueSorted = [...new Set(days)].sort((a, b) => a - b);
  if (uniqueSorted.length === 0) return "Senin – Minggu";
  if (uniqueSorted.length === 7) return "Senin – Minggu";

  // Cek apakah deret berurutan penuh (misal 1,2,3,4,5)
  let isContiguous = true;
  for (let i = 0; i < uniqueSorted.length - 1; i++) {
    if (uniqueSorted[i + 1] !== uniqueSorted[i] + 1) {
      isContiguous = false;
      break;
    }
  }

  if (isContiguous && uniqueSorted.length >= 3) {
    return `${DAY_NAMES[uniqueSorted[0]]} – ${DAY_NAMES[uniqueSorted[uniqueSorted.length - 1]]}`;
  }

  return uniqueSorted.map((d) => DAY_NAMES[d]).join(", ");
};

/**
 * Format jam HH:mm
 */
const formatHourMinute = (t, fallback = "00:00") => {
  if (!t) return fallback;
  const parts = String(t).split(":");
  const h = parts[0].padStart(2, "0");
  const m = (parts[1] || "00").padStart(2, "0");
  return `${h}:${m}`;
};

/**
 * Format zona waktu (WIB, WITA, WIT)
 */
const getTzLabel = (tz = "Asia/Jakarta") => {
  const s = String(tz).toLowerCase();
  if (s.includes("makassar") || s.includes("bali") || s.includes("ujung_pandang") || s.includes("wita")) {
    return "WITA";
  }
  if (s.includes("jayapura") || s.includes("wit")) {
    return "WIT";
  }
  return "WIB";
};

/**
 * Cek apakah cabang buka hari ini dan pada jam sekarang
 */
export const checkBranchStatus = (cabang) => {
  const tz = cabang.tz || "Asia/Jakarta";
  const jamBuka = formatHourMinute(cabang.jam_buka, "09:00");
  const jamTutup = formatHourMinute(cabang.jam_tutup, "20:00");
  const tzLabel = getTzLabel(tz);
  const hariText = formatHariOperasional(cabang.hari_operasional);

  const formattedJamOperasional = `${jamBuka} – ${jamTutup} ${tzLabel} (${hariText})`;

  try {
    const now = new Date();
    // Waktu lokal di timezone cabang
    const timeStr = now.toLocaleTimeString("en-GB", { timeZone: tz, hour12: false }); // "HH:mm:ss"
    const currentHhMm = timeStr.slice(0, 5);

    // Hari saat ini di timezone cabang (Mon, Tue, ...)
    const weekdayShort = now.toLocaleDateString("en-US", { timeZone: tz, weekday: "short" });
    const dayMap = { Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6, Sun: 7 };
    const currentDayNum = dayMap[weekdayShort] || 1;

    const openDays = String(cabang.hari_operasional || "1,2,3,4,5,6,7")
      .split(",")
      .map((d) => parseInt(d.trim(), 10))
      .filter((d) => !isNaN(d));

    const isOpenDay = openDays.includes(currentDayNum);
    const isOpenTime = currentHhMm >= jamBuka && currentHhMm < jamTutup;
    const isCurrentlyOpen = isOpenDay && isOpenTime;

    return {
      is_open: isCurrentlyOpen,
      status_buka: isCurrentlyOpen ? "BUKA HARI INI" : "TUTUP",
      jam_operasional_formatted: formattedJamOperasional,
    };
  } catch (_) {
    return {
      is_open: true,
      status_buka: "BUKA HARI INI",
      jam_operasional_formatted: formattedJamOperasional,
    };
  }
};

/**
 * GET /api/v1/cabang
 * Daftar Cabang Klinik Kecantikan
 */
router.get("/", async (req, res) => {
  try {
    const hasCabangTable = await DB.schema.hasTable("mst_cabang");
    if (!hasCabangTable) {
      return sendSuccess(res, "Daftar cabang", [
        {
          kode_cabang: "CBG-001",
          nama_cabang: "Cabang Utama",
          alamat: "Kantor Pusat Klinik Kecantikan",
          telp: "081234567890",
          email: "pusat@klinik.com",
          pj_manager: "Manager Utama",
          jam_buka: "09:00:00",
          jam_tutup: "20:00:00",
          hari_operasional: "1,2,3,4,5,6,7",
          fasilitas: [],
          is_open: true,
          status_buka: "BUKA HARI INI",
          jam_operasional_formatted: "09:00 – 20:00 WIB (Senin – Minggu)",
        },
      ]);
    }

    const cabang = await DB("mst_cabang")
      .where("status", "aktif")
      .orWhere("status", "1")
      .select(
        "id",
        "kode_cabang",
        "nama_cabang",
        "alamat",
        "no_telp as telp",
        "email",
        "pj_manager",
        "jam_buka",
        "jam_tutup",
        "hari_operasional",
        "fasilitas",
        "tz",
        "status"
      );

    const formattedCabang = cabang.map((c) => {
      let parsedFasilitas = [];
      if (c.fasilitas) {
        if (typeof c.fasilitas === "string") {
          try {
            parsedFasilitas = JSON.parse(c.fasilitas);
          } catch (_) {
            parsedFasilitas = [];
          }
        } else if (Array.isArray(c.fasilitas)) {
          parsedFasilitas = c.fasilitas;
        }
      }

      const statusInfo = checkBranchStatus(c);

      return {
        ...c,
        nama_cabang: cleanNamaCabang(c.nama_cabang),
        fasilitas: parsedFasilitas,
        is_open: statusInfo.is_open,
        status_buka: statusInfo.status_buka,
        jam_operasional_formatted: statusInfo.jam_operasional_formatted,
      };
    });

    return sendSuccess(res, "Daftar cabang berhasil dimuat", formattedCabang);
  } catch (err) {
    return sendError(res, err.message, 500);
  }
});

export default router;
