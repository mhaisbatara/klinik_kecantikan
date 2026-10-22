import express from "express";
import DB from "../../../core/config/knex.js";
import { sendSuccess, sendError } from "../../../utils/response.js";
import { authenticateMobile } from "../../../middleware/auth_middleware.js";

const router = express.Router();

/**
 * Format currency to Indonesian Rupiah
 */
const formatRupiah = (val) => {
  const num = Number(val) || 0;
  return "Rp" + num.toLocaleString("id-ID");
};

/**
 * Format date to Indonesian friendly string
 */
const formatTglIndo = (dateStr) => {
  if (!dateStr) return "-";
  try {
    const d = new Date(dateStr);
    return d.toLocaleDateString("id-ID", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  } catch (_) {
    return String(dateStr).slice(0, 10);
  }
};

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

/**
 * Query All Database Context for RAG Injection
 */
async function getClinicDatabaseContext(user = {}, kodeCabangFilter = null) {
  const noRm = user.no_rm || null;
  const userName = user.fullname || user.nama || user.username || "Pasien";

  const cleanCabangFilter =
    kodeCabangFilter &&
    typeof kodeCabangFilter === "string" &&
    kodeCabangFilter.trim().toLowerCase() !== "semua" &&
    kodeCabangFilter.trim().toLowerCase() !== "all"
      ? kodeCabangFilter.trim()
      : null;

  // 1. Layanan Aktif (Join mst_cabang untuk identitas cabang)
  const layananQuery = DB("mst_layanan as l")
    .leftJoin("mst_kategori_layanan as k", "l.kode_kategori_layanan", "k.kode_kategori_layanan")
    .leftJoin("mst_cabang as c", DB.raw("l.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
    .where(function () {
      this.where("l.status", "aktif").orWhere("l.status", "1");
    });

  if (cleanCabangFilter) {
    layananQuery.where("l.kode_cabang", cleanCabangFilter);
  }

  const rawLayanan = await layananQuery.select(
    "l.kode_layanan",
    "l.nama as nama_layanan",
    "l.harga",
    "l.durasi_menit",
    "l.is_include_konsultasi",
    "l.wajib_konsultasi",
    "l.kode_ruangan",
    "l.kode_cabang",
    "c.nama_cabang",
    "k.nama as kategori"
  );

  const layananList = rawLayanan.map((l) => ({
    kode_layanan: l.kode_layanan,
    nama_layanan: l.nama_layanan,
    harga: Number(l.harga) || 0,
    durasi_menit: Number(l.durasi_menit) || 30,
    is_include_konsultasi: Number(l.is_include_konsultasi) === 1 ? 1 : 0,
    wajib_konsultasi: Number(l.wajib_konsultasi) === 1 ? 1 : 0,
    kode_ruangan: l.kode_ruangan,
    kode_cabang: l.kode_cabang || "CBG-001",
    nama_cabang: cleanNamaCabang(l.nama_cabang),
    kategori: l.kategori || "Perawatan",
  }));

  // 2. Paket Layanan Aktif & Rincian Treatment Tiap Paket (Join mst_cabang)
  const paketQuery = DB("mst_paket_layanan as p")
    .leftJoin("mst_cabang as c", DB.raw("p.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
    .where(function () {
      this.where("p.status", "aktif").orWhere("p.status", "1");
    });

  if (cleanCabangFilter) {
    paketQuery.where("p.kode_cabang", cleanCabangFilter);
  }

  const rawPaket = await paketQuery.select(
    "p.kode_paket_layanan",
    "p.nama",
    "p.harga_paket",
    "p.masa_berlaku_hari",
    "p.is_include_konsultasi",
    "p.kode_cabang",
    "c.nama_cabang"
  );

  const hasDetailPaketTbl = await DB.schema.hasTable("mst_detail_paket_layanan");
  const paketList = [];

  for (const p of rawPaket) {
    let treatments = [];
    if (hasDetailPaketTbl) {
      treatments = await DB("mst_detail_paket_layanan as d")
        .leftJoin("mst_layanan as l", "d.kode_layanan", "l.kode_layanan")
        .where("d.kode_paket_layanan", p.kode_paket_layanan)
        .select("l.nama as nama_layanan", "d.jumlah_sesi");
    }

    paketList.push({
      kode_paket: p.kode_paket_layanan,
      nama_paket: p.nama,
      harga: Number(p.harga_paket) || 0,
      masa_berlaku_hari: Number(p.masa_berlaku_hari) || 30,
      is_include_konsultasi: Number(p.is_include_konsultasi) === 1 ? 1 : 0,
      kode_cabang: p.kode_cabang || "CBG-001",
      nama_cabang: cleanNamaCabang(p.nama_cabang),
      isi_paket: treatments.map((t) => `${t.nama_layanan || "Treatment"} (${t.jumlah_sesi} sesi)`).join(", ") || "Multi-sesi treatment",
    });
  }

  // 3. Daftar Cabang Klinik
  let cabangList = [];
  try {
    const rawCabang = await DB("mst_cabang")
      .where(function () {
        this.where("status", "aktif").orWhere("status", "1");
      })
      .select("kode_cabang", "nama_cabang", "alamat", "no_telp");
    cabangList = rawCabang.map((c) => ({
      kode: c.kode_cabang,
      nama: cleanNamaCabang(c.nama_cabang),
      alamat: c.alamat || "-",
      telepon: c.no_telp || "-",
      jam_operasional: "Setiap hari 09:00 - 20:00 WIB",
    }));
  } catch (_) {
    cabangList = [
      {
        kode: "CBG-001",
        nama: "Cabang Utama",
        alamat: "Pusat Kota",
        telepon: "081234567890",
        jam_operasional: "09:00 - 20:00 WIB",
      },
    ];
  }

  // 4. Data Pasien (Jika sudah terhubung No. RM)
  let userBookings = [];
  let userPackages = [];

  if (noRm) {
    // Booking aktif pasien
    const bookings = await DB("trx_booking as b")
      .leftJoin("mst_jadwal_karyawan as j", "b.kode_jadwal", "j.kode_jadwal")
      .leftJoin("mst_karyawan as k", "j.no_sip", "k.no_sip")
      .leftJoin("mst_ruangan as r", "j.kode_ruangan", "r.kode_ruangan")
      .leftJoin("mst_cabang as c", DB.raw("b.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .where("b.no_rm", noRm)
      .orderBy("b.tanggal_booking", "desc")
      .orderBy("b.jam_booking", "desc")
      .limit(5)
      .select(
        "b.kode_booking",
        "b.tanggal_booking",
        "b.jam_booking",
        "b.status",
        "b.dp_status",
        "b.dp_nominal",
        "b.metode_pembayaran_dp",
        "k.nama as nama_dokter",
        "r.nama_ruangan",
        "c.nama_cabang"
      );

    const hasDetailBooking = await DB.schema.hasTable("trx_detail_booking");
    for (const bk of bookings) {
      let itemsStr = "";
      if (hasDetailBooking) {
        const items = await DB("trx_detail_booking")
          .where("kode_booking", bk.kode_booking)
          .select("nama_layanan");
        itemsStr = items.map((i) => i.nama_layanan).join(", ");
      }
      userBookings.push({
        kode_booking: bk.kode_booking,
        tanggal: formatTglIndo(bk.tanggal_booking),
        jam: bk.jam_booking ? bk.jam_booking.slice(0, 5) : "-",
        layanan: itemsStr || "Perawatan Klinik",
        dokter: bk.nama_dokter ? `dr. ${bk.nama_dokter}` : "-",
        cabang: bk.nama_cabang || "Klinik Utama",
        status: bk.status || "TERJADWAL",
        dp_status: bk.dp_status === "lunas" || bk.dp_status === "dipotong_treatment" ? `Lunas (${formatRupiah(bk.dp_nominal)})` : (bk.dp_status || "Belum Bayar"),
      });
    }

    // Sisa kuota paket aktif milik pasien
    const rawUserPackages = await DB("trx_kepemilikan_paket_layanan as k")
      .leftJoin("mst_paket_layanan as p", "k.kode_paket_layanan", "p.kode_paket_layanan")
      .leftJoin("mst_cabang as c", DB.raw("k.kode_cabang = c.kode_cabang COLLATE utf8mb4_0900_ai_ci"))
      .where("k.no_rm", noRm)
      .where("k.status", "aktif")
      .select(
        "k.kode_kepemilikan_paket_layanan",
        "k.kode_paket_layanan",
        "p.nama as nama_paket",
        "k.tanggal_beli",
        "k.tanggal_expired",
        "k.status",
        "k.kode_cabang",
        "c.nama_cabang"
      );

    const hasDetailKepemilikan = await DB.schema.hasTable("trx_detail_kepemilikan_paket_layanan");
    for (const pk of rawUserPackages) {
      let details = [];
      if (hasDetailKepemilikan) {
        details = await DB("trx_detail_kepemilikan_paket_layanan as d")
          .leftJoin("mst_layanan as l", "d.kode_layanan", "l.kode_layanan")
          .where("d.kode_kepemilikan_paket_layanan", pk.kode_kepemilikan_paket_layanan)
          .select(
            "d.kode_detail_kepemilikan_paket_layanan",
            "d.kode_kepemilikan_paket_layanan",
            "d.kode_layanan",
            "l.nama as nama_layanan",
            "l.harga as harga_normal",
            "l.durasi_menit",
            "l.kode_ruangan",
            "l.is_include_konsultasi",
            "d.sesi_total",
            "d.sesi_terpakai"
          );
      }

      userPackages.push({
        kode_kepemilikan_paket_layanan: pk.kode_kepemilikan_paket_layanan,
        nama_paket: pk.nama_paket || pk.kode_paket_layanan,
        status: pk.status?.toUpperCase() || "AKTIF",
        berlaku_sampai: formatTglIndo(pk.tanggal_expired),
        tanggal_expired: pk.tanggal_expired,
        kode_cabang: pk.kode_cabang || "CBG-001",
        nama_cabang: cleanNamaCabang(pk.nama_cabang),
        rincian_sesi: details.map((d) => ({
          kode_detail_kepemilikan_paket_layanan: d.kode_detail_kepemilikan_paket_layanan,
          kode_layanan: d.kode_layanan,
          layanan: d.nama_layanan || d.kode_layanan,
          harga_normal: Number(d.harga_normal) || 0,
          durasi_menit: Number(d.durasi_menit) || 30,
          kode_ruangan: d.kode_ruangan,
          is_include_konsultasi: Number(d.is_include_konsultasi) === 1 ? 1 : 0,
          sisa: Math.max(0, (d.sesi_total || 0) - (d.sesi_terpakai || 0)),
          total: d.sesi_total,
          terpakai: d.sesi_terpakai,
        })),
      });
    }
  }

  // Kumpulkan sesi paket yang masih memiliki sisa kuota (bisa diklaim langsung)
  const claimableSessions = [];
  for (const pk of userPackages) {
    for (const r of pk.rincian_sesi) {
      if (r.sisa > 0) {
        claimableSessions.push({
          kode_layanan: r.kode_layanan,
          nama_layanan: r.layanan,
          nama: r.layanan,
          harga: 0, // Sisa sesi paket berstatus gratis (sudah dibayar)
          harga_normal: r.harga_normal,
          durasi_menit: r.durasi_menit,
          kode_ruangan: r.kode_ruangan,
          is_include_konsultasi: r.is_include_konsultasi,
          kode_cabang: pk.kode_cabang || "CBG-001",
          nama_cabang: cleanNamaCabang(pk.nama_cabang),
          is_claim_packet: true,
          kode_detail_kepemilikan_paket_layanan: r.kode_detail_kepemilikan_paket_layanan,
          kode_kepemilikan_paket_layanan: pk.kode_kepemilikan_paket_layanan,
          nama_paket: pk.nama_paket,
          sisa_sesi: r.sisa,
          sesi_total: r.total,
          berlaku_sampai: pk.berlaku_sampai,
        });
      }
    }
  }

  return {
    userName,
    noRm,
    layananList,
    paketList,
    cabangList,
    userBookings,
    userPackages,
    claimableSessions,
    selectedCabangFilter: cleanCabangFilter,
  };
}

/**
 * Buat System Prompt Profesional untuk LLM (Gemini / Groq)
 */
function buildSystemInstruction(context) {
  const {
    userName,
    noRm,
    layananList,
    paketList,
    cabangList,
    userBookings,
    userPackages,
    selectedCabangFilter,
  } = context;

  const filterInfo = selectedCabangFilter
    ? `Pasien saat ini memilih FILTER KHUSUS CABANG: "${selectedCabangFilter}". Tampilkan HANYA rekomendasi layanan/paket dari cabang ini.`
    : `Pasien memilih opsi "Semua Cabang". Semua layanan lintas cabang diizinkan muncul.`;

  return `Anda adalah "Beauty Care AI Assistant", asisten virtual & konsultan kecantikan resmi dari Klinik Kecantikan.
Persona Anda:
- Ramah, sopan, berempati tinggi, cerdas, solutif, dan profesional.
- Berbahasa Indonesia santai, hangat, dan natural (selalu sapa dan panggil pasien dengan ramah: "Kak ${userName}").
- Anda memahami dermatologi dasar, skincare, dan estetika klinis.

INFORMASI FILTER CABANG PASIEN SAAT INI:
${filterInfo}

DATA REAL-TIME DATABASE KLINIK KECANTIKAN:
--------------------------------------------------
1. PROFIL PASIEN SAAT INI:
- Nama: ${userName}
- No. Rekam Medis (RM): ${noRm ? noRm : "Belum terhubung / Belum memiliki No. RM"}
- Status RM: ${noRm ? "Terverifikasi" : "Belum verifikasi No. RM (arahkan hubungkan No. RM jika ingin cek paket pribadi)"}

2. JADWAL BOOKING AKTIF PASIEN (Real-time MySQL):
${userBookings.length > 0 ? JSON.stringify(userBookings, null, 2) : "Saat ini pasien belum memiliki jadwal booking yang aktif."}

3. SISA KUOTA PAKET PERAWATAN PASIEN (Real-time MySQL):
${userPackages.length > 0 ? JSON.stringify(userPackages, null, 2) : "Pasien belum memiliki paket perawatan multi-sesi aktif."}

4. DAFTAR LENGKAP LAYANAN KLINIK BESERTA HARGA & CABANG RESMI (Gunakan HANYA layanan ini):
${JSON.stringify(
  layananList.map((l) => ({
    kode: l.kode_layanan,
    nama: l.nama_layanan,
    harga: formatRupiah(l.harga),
    durasi: `${l.durasi_menit} menit`,
    cabang: l.nama_cabang,
    kode_cabang: l.kode_cabang,
    kategori: l.kategori,
    konsultasi:
      l.is_include_konsultasi === 1
        ? "Sudah termasuk Gratis Konsultasi Dokter"
        : "Biaya Konsul Dokter Normal (Rp30.000 - Rp50.000)",
  })),
  null,
  2
)}

5. DAFTAR PAKET MULTI-SESI HEMAT:
${JSON.stringify(
  paketList.map((p) => ({
    kode: p.kode_paket,
    nama: p.nama_paket,
    harga: formatRupiah(p.harga),
    cabang: p.nama_cabang,
    kode_cabang: p.kode_cabang,
    masa_berlaku: `${p.masa_berlaku_hari} hari`,
    isi: p.isi_paket,
  })),
  null,
  2
)}

6. CABANG KLINIK & JAM OPERASIONAL:
${JSON.stringify(cabangList, null, 2)}

7. ATURAN & PROSEDUR RESMI KLINIK:
- Down Payment (DP) Booking: Setiap reservasi memerlukan DP 20% untuk mengamankan slot dokter dan ruangan. DP ini langsung memotong total tagihan kasir saat kedatangan.
- Konsultasi Dokter: Layanan bertanda "Sudah termasuk Gratis Konsultasi Dokter" (seperti Facial Glow Up) bebas biaya konsultasi dokter.
- Sistem Paket: Memberikan potongan harga signifikan dan kuota sesi dapat digunakan berkala dalam masa aktif.

PEDOMAN MENJAWAB:
1. Jawab pertanyaan pasien dengan luwes, santai, dan percakapan natural. Jika pasien curhat keluhan kulit (misal: jerawat, kusam, kerutan), berikan edukasi singkat lalu rekomendasikan layanan/paket yang relevan dari data di atas beserta harganya.
2. ATURAN PENAMAAN CABANG: Selalu sebutkan nama cabang HANYA dengan format "Cabang [Nama]" (contoh: "Cabang Utama", "Cabang Surabaya" — JANGAN pernah menyebutkan kata "Klinik" di depan nama cabang). Pasien bebas melakukan reservasi di cabang manapun. Jika terdapat layanan dengan nama yang sama atau mirip namun berbeda cabang atau harga/durasi (contoh: konsultasi di Cabang Utama seharga Rp30.000 (10 menit) vs di Cabang Surabaya seharga Rp50.000 (30 menit)), Anda WAJIB menyebutkan nama cabangnya (contoh: "Cabang Utama" / "Cabang Surabaya") secara jelas dan ramah di dalam teks jawaban Anda agar pasien dapat membedakan dengan mudah!
3. Jika pasien bertanya tentang jadwal booking atau sisa paket mereka, gunakan data pribadi pasien di atas.
4. MEDICAL GUARDRAIL: Di akhir rekomendasi perawatan medis/tindakan, selalu berikan pengingat santun bahwa rekomendasi ini adalah konsultasi awal, dan diagnosis pasti disarankan melalui tatap muka dengan dokter klinik.
5. ATURAN KLAIM SISA SESI PAKET (FREE DP / GRATIS):
Jika pasien bertanya tentang sisa kuota paket atau ingin reservasi menggunakan sisa sesi paket yang masih aktif, ingatkan secara ramah bahwa mereka TIDAK PERLU membayar Down Payment (DP Rp0 / Gratis) karena menggunakan kuota paket yang sudah dibeli lunas.
6. TAG REKOMENDASI KARTU: Jika Anda menyarankan layanan klinik tertentu atau sisa sesi paket kepada pasien, letakkan tag berikut di PALING AKHIR jawaban Anda agar aplikasi dapat menampilkan kartu produk:
[REKOMENDASI: KODE_LAYANAN_1, KODE_LAYANAN_2]
Contoh: [REKOMENDASI: LAY-001, LAY-002]`;
}

/**
 * Panggil Google Gemini API (Model: gemini-2.5-flash / fallback gemini-1.5-flash)
 */
async function callGeminiAPI(apiKey, systemInstruction, history, userMessage) {
  // Gunakan model-model ultra-cepat (respon 1-2 detik) untuk pengalaman chat instan
  const models = [
    "gemini-3.5-flash-lite",
    "gemini-flash-lite-latest",
    "gemini-3.5-flash",
    "gemini-flash-latest",
  ];

  // Format riwayat chat untuk Gemini
  const contents = [];
  if (Array.isArray(history)) {
    for (const h of history) {
      if (!h.text || !h.text.trim()) continue;
      const role = h.role === "user" ? "user" : "model";
      contents.push({
        role,
        parts: [{ text: h.text }],
      });
    }
  }

  // Pesan user saat ini
  contents.push({
    role: "user",
    parts: [{ text: userMessage }],
  });

  const payload = {
    system_instruction: {
      parts: [{ text: systemInstruction }],
    },
    contents,
    generationConfig: {
      temperature: 0.7,
      maxOutputTokens: 1200,
    },
  };

  let lastError = null;

  for (const model of models) {
    try {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        signal: AbortSignal.timeout(12000), // Maksimal 12 detik per percobaan
      });

      if (!res.ok) {
        const errText = await res.text();
        continue;
      }

      const data = await res.json();
      const rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (rawText && rawText.trim().length > 0) {
        return rawText.trim();
      }
    } catch (err) {
      lastError = err;
    }
  }

  throw lastError || new Error("Semua model Gemini gagal merespons");
}

/**
 * Panggil Groq Cloud API (Model: openai/gpt-oss-20b / qwen/qwen3.8-27b / fallback)
 */
async function callGroqAPI(apiKey, systemInstruction, history, userMessage) {
  const models = [
    "openai/gpt-oss-20b",
    "qwen/qwen3.8-27b",
    "openai/gpt-oss-120b",
    "llama-3.3-70b-versatile",
  ];

  const messages = [{ role: "system", content: systemInstruction }];

  if (Array.isArray(history)) {
    for (const h of history) {
      if (!h.text || !h.text.trim()) continue;
      const role = h.role === "user" ? "user" : "assistant";
      messages.push({
        role,
        content: h.text,
      });
    }
  }

  messages.push({
    role: "user",
    content: userMessage,
  });

  let lastError = null;

  for (const model of models) {
    try {
      const payload = {
        model,
        messages,
        temperature: 0.7,
        max_tokens: 1500,
      };

      const res = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
        signal: AbortSignal.timeout(12000),
      });

      if (!res.ok) {
        continue;
      }

      const data = await res.json();
      const rawText = data?.choices?.[0]?.message?.content;
      if (rawText && rawText.trim().length > 0) {
        return rawText.trim();
      }
    } catch (err) {
      lastError = err;
    }
  }

  throw lastError || new Error("Semua model Groq gagal merespons");
}

/**
 * Ekstraksi Layanan yang Direkomendasikan AI & Pembersihan Teks
 */
function extractRecommendedServices(rawReply, layananList, claimableSessions = []) {
  let cleanReply = rawReply;
  const matchedCodes = new Set();

  // 1. Tangkap dari tag [REKOMENDASI: LAY-001, LAY-002] atau [REKOMENDASI_KLAIM: ...]
  const tagRegex = /\[(?:REKOMENDASI|REKOMENDASI_KLAIM):\s*([^\]]+)\]/i;
  const tagMatch = rawReply.match(tagRegex);
  if (tagMatch) {
    const codesStr = tagMatch[1];
    const codes = codesStr.split(/[,\s]+/).map((c) => c.trim().toUpperCase());
    codes.forEach((c) => {
      if (c.startsWith("LAY-") || c.startsWith("DKPL-")) matchedCodes.add(c);
    });
    // Hapus tag dari pesan yang ditampilkan ke pasien agar natural
    cleanReply = cleanReply.replace(tagRegex, "").trim();
  }

  // 2. Tangkap pola kode LAY-XXX atau DKPL-XXX yang muncul di dalam teks
  const inlineCodeRegex = /\b(LAY-\d{3}|DKPL-\d{3,4})\b/gi;
  let inlineMatch;
  while ((inlineMatch = inlineCodeRegex.exec(cleanReply)) !== null) {
    matchedCodes.add(inlineMatch[1].toUpperCase());
  }

  // 3. Pencocokan Nama Layanan jika belum ada kode yang tertangkap
  if (matchedCodes.size === 0) {
    const lowerReply = cleanReply.toLowerCase();
    // Cek dulu apakah menyebut nama layanan dari paket aktif pasien
    for (const cs of claimableSessions) {
      if (lowerReply.includes(cs.nama_layanan.toLowerCase())) {
        matchedCodes.add(cs.kode_layanan);
        if (matchedCodes.size >= 3) break;
      }
    }

    if (matchedCodes.size === 0) {
      for (const l of layananList) {
        if (lowerReply.includes(l.nama_layanan.toLowerCase())) {
          matchedCodes.add(l.kode_layanan);
          if (matchedCodes.size >= 3) break;
        }
      }
    }
  }

  // 4. Bangun daftar objek layanan (prioritaskan claimableSessions jika cocok)
  const recommendedServices = [];
  for (const code of matchedCodes) {
    const claimMatch = claimableSessions.find(
      (cs) => cs.kode_layanan === code || cs.kode_detail_kepemilikan_paket_layanan === code
    );
    if (claimMatch) {
      recommendedServices.push(claimMatch);
    } else {
      const normalMatch = layananList.find((l) => l.kode_layanan === code);
      if (normalMatch) {
        recommendedServices.push(normalMatch);
      }
    }
  }

  return {
    cleanReply,
    recommendedServices,
  };
}

/**
 * Smart Fallback Engine (Pencarian Database Cerdas Jika API Key Kosong)
 */
function runSmartFallbackEngine(userMessage, context) {
  const { userName, noRm, layananList, paketList, userBookings, userPackages } = context;
  const q = userMessage.toLowerCase().trim();

  const filterLayanan = (keywords) => {
    return layananList.filter((l) => {
      const name = l.nama_layanan.toLowerCase();
      const kat = (l.kategori || "").toLowerCase();
      return keywords.some((kw) => name.includes(kw) || kat.includes(kw));
    });
  };

  let reply = "";
  let services = [];
  let quickReplies = [];

  // Jerawat / Acne
  if (q.includes("jerawat") || q.includes("acne") || q.includes("komedo") || q.includes("bruntus")) {
    services = filterLayanan(["acne", "cleansing", "peeling"]).slice(0, 3);
    reply = `Halo Kak ${userName}! 🌸 Untuk keluhan kulit berjerawat dan komedo, klinik kami menyediakan treatment klinis yang dirancang untuk meredakan inflamasi serta membersihkan pori:\n\n`;
    services.forEach((s) => {
      const tag = s.is_include_konsultasi === 1 ? " *(Free Konsul Dokter)*" : "";
      const cbg = s.nama_cabang ? ` (📍 ${s.nama_cabang})` : "";
      reply += `• **${s.nama_layanan}**${cbg}${tag}\n  Biaya: ${formatRupiah(s.harga)} (${s.durasi_menit} menit)\n`;
    });
    reply += `\n⚠️ *Catatan Medis:* Saran ini merupakan informasi awal. Dokter kami siap memeriksa tipe jerawat Anda untuk menentukan tindakan terbaik.`;
    quickReplies = ["📅 Cek jadwal booking saya", "✨ Kulit cerah & glowing", "❓ Aturan konsultasi dokter"];
  }
  // Glowing / Kusam / Cerah
  else if (q.includes("glow") || q.includes("kusam") || q.includes("cerah") || q.includes("flek") || q.includes("bright")) {
    services = filterLayanan(["glow", "bright", "laser", "facial"]).slice(0, 3);
    reply = `Hai Kak ${userName}! ✨ Untuk kulit kusam dan ingin tampak lebih cerah bersinar, berikut rekomendasi perawatan terfavorit di klinik kami:\n\n`;
    services.forEach((s) => {
      const tag = s.is_include_konsultasi === 1 ? " *(Include Gratis Konsul)*" : "";
      const cbg = s.nama_cabang ? ` (📍 ${s.nama_cabang})` : "";
      reply += `• **${s.nama_layanan}**${cbg}${tag}\n  Biaya: ${formatRupiah(s.harga)} (${s.durasi_menit} menit)\n`;
    });
    reply += `\n⚠️ *Catatan Medis:* Hasil pencerahan optimal bervariasi tergantung kondisi skin barrier Anda.`;
    quickReplies = ["💆‍♀️ Daftar harga perawatan", "📅 Cek jadwal booking saya", "🎫 Cek sisa paket saya"];
  }
  // Cek Jadwal Booking
  else if (q.includes("jadwal") || q.includes("booking") || q.includes("janji")) {
    if (!noRm) {
      reply = `Halo Kak ${userName}, akun Anda belum memiliki Nomor Rekam Medis (No. RM) resmi klinik. Silakan hubungi bagian pendaftaran atau buat reservasi treatment baru.`;
      services = layananList.slice(0, 2);
    } else if (userBookings.length === 0) {
      reply = `Kak ${userName} (No. RM: **${noRm}**), saat ini Anda belum memiliki jadwal booking aktif. Ingin mereservasi perawatan sekarang?`;
      services = layananList.slice(0, 2);
    } else {
      reply = `Berikut adalah data jadwal booking aktif Kak **${userName}** (No. RM: **${noRm}**):\n\n`;
      userBookings.forEach((b, idx) => {
        reply += `${idx + 1}. **Kode Booking:** \`${b.kode_booking}\`\n   • Tanggal: ${b.tanggal} pukul ${b.jam}\n   • Layanan: ${b.layanan}\n   • Dokter: ${b.dokter}\n   • Status: ${b.status} • DP: ${b.dp_status}\n\n`;
      });
      reply += `*Harap hadir 15 menit sebelum waktu appointment untuk verifikasi kedatangan di kasir.*`;
    }
    quickReplies = ["🎫 Cek sisa paket saya", "💆‍♀️ Daftar harga perawatan", "❓ Aturan DP booking"];
  }
  // Cek Sisa Paket / Klaim Sesi Paket
  else if (q.includes("paket") && (q.includes("sisa") || q.includes("saya") || q.includes("kuota") || q.includes("klaim"))) {
    if (!noRm) {
      reply = `Halo Kak ${userName}, akun Anda belum terhubung dengan No. RM klinik. Rincian paket perawatan dicatat berdasarkan No. RM pasien.`;
      services = layananList.slice(0, 2);
    } else if (userPackages.length === 0) {
      reply = `Kak ${userName} (No. RM: **${noRm}**), saat ini Anda belum memiliki paket perawatan multi-sesi aktif. Kami menyediakan paket hemat dengan diskon menarik!`;
      services = layananList.slice(0, 2);
    } else {
      reply = `Berikut rincian sisa kuota paket Kak **${userName}** (No. RM: **${noRm}**):\n\n`;
      userPackages.forEach((p, idx) => {
        reply += `${idx + 1}. **${p.nama_paket}** (Berlaku s/d: ${p.berlaku_sampai})\n`;
        p.rincian_sesi.forEach((s) => {
          reply += `   • ${s.layanan}: **Sisa ${s.sisa} sesi** (Terpakai ${s.terpakai} dari ${s.total})\n`;
        });
        reply += `\n`;
      });
      reply += `💡 *Untuk menggunakan sisa sesi paket ini, silakan tekan tombol **"Klaim Sesi Ini"** pada kartu di bawah. Reservasi sisa paket ini **bebas biaya Down Payment (DP Rp0)**.*`;

      if (context.claimableSessions && context.claimableSessions.length > 0) {
        services = context.claimableSessions;
      } else {
        services = [];
      }
    }
    quickReplies = ["📅 Cek jadwal booking saya", "💆‍♀️ Daftar harga perawatan", "✨ Rekomendasi wajah berjerawat"];
  }
  // Aturan DP & Konsultasi
  else if (q.includes("dp") || q.includes("aturan") || q.includes("konsul") || q.includes("ketentuan")) {
    reply = `Ketentuan & Aturan di Klinik Kecantikan kami, Kak ${userName}:\n\n` +
      `1. **Aturan DP Booking (20%):** Setiap reservasi memerlukan Down Payment 20% untuk mengunci slot dokter/ruangan. DP ini otomatis memotong tagihan di kasir saat kedatangan.\n\n` +
      `2. **Konsultasi Dokter:** Beberapa treatment favorit (seperti *Facial Glow Up*) sudah Free Konsul Dokter. Untuk treatment biasa/konsul tersendiri, tarif dokter normal adalah Rp30.000 - Rp50.000.\n\n` +
      `3. **Paket Multi-Sesi:** Memberikan diskon lebih hemat dan sesi dapat digunakan berkala dalam masa aktif 30-180 hari.`;
    services = layananList.filter((l) => l.is_include_konsultasi === 1).slice(0, 2);
    quickReplies = ["📅 Cek jadwal booking saya", "💆‍♀️ Daftar harga perawatan", "✨ Rekomendasi wajah berjerawat"];
  }
  // Default / Greeting
  else {
    services = layananList.slice(0, 3);
    reply = `Halo Kak ${userName}! 🌸 Selamat datang di **Beauty Care AI Assistant** Klinik Kecantikan.\n\n` +
      `Saya siap membantu konsultasi keluhan kulit Anda, memberikan rekomendasi treatment & paket hemat, hingga memeriksa jadwal booking aktif dan sisa kuota paket Anda secara real-time.\n\n` +
      `Ada yang bisa saya bantu hari ini, Kak?`;
    quickReplies = [
      "✨ Rekomendasi wajah berjerawat",
      "✨ Kulit cerah & glowing",
      "📅 Cek jadwal booking saya",
      "🎫 Cek sisa paket saya",
    ];
  }

  return {
    reply,
    recommendedServices: services,
    quickReplies,
  };
}

/**
 * Controller Utama Chatbot Multi-Turn
 */
const handleChatRequest = async (req, res) => {
  try {
    const { message, history, kode_cabang_filter } = req.body;
    if (!message || typeof message !== "string" || !message.trim()) {
      return sendError(res, "Pesan tidak boleh kosong", 422);
    }

    const user = req.auth || req.user || {};
    const context = await getClinicDatabaseContext(user, kode_cabang_filter);
    const systemInstruction = buildSystemInstruction(context);

    const geminiKey = (process.env.GEMINI_API_KEY || "").trim();
    const groqKey = (process.env.GROQ_API_KEY || "").trim();

    let rawReply = null;
    let providerUsed = "local_intent";

    // ── 1. Coba Provider 1: Google Gemini API (gemini-2.5-flash) ──────────
    if (geminiKey.length > 10) {
      try {
        rawReply = await callGeminiAPI(geminiKey, systemInstruction, history, message);
        providerUsed = "google_gemini";
      } catch (err) {
        console.warn("⚠️ Gemini API Gagal:", err.message);
      }
    }

    // ── 2. Coba Provider 2: Groq Cloud API (llama-3.3-70b-versatile) ──────
    if (!rawReply && groqKey.length > 10) {
      try {
        rawReply = await callGroqAPI(groqKey, systemInstruction, history, message);
        providerUsed = "groq_llama";
      } catch (err) {
        console.warn("⚠️ Groq API Gagal:", err.message);
      }
    }

    // ── 3. Fallback Cerdas (Database RAG Intent Engine) ────────────────────
    let finalReply = "";
    let recommendedServices = [];
    let quickReplies = [
      "✨ Rekomendasi wajah berjerawat",
      "✨ Kulit cerah & glowing",
      "📅 Cek jadwal booking saya",
      "🎫 Cek sisa paket saya",
    ];

    const isPackageQuery =
      /(paket|sisa|kuota|klaim|sesi)/i.test(message) &&
      /(paket|sisa|kuota|klaim|sesi|punya|ada|berapa)/i.test(message);

    if (rawReply) {
      const extracted = extractRecommendedServices(
        rawReply,
        context.layananList,
        context.claimableSessions
      );
      finalReply = extracted.cleanReply;
      recommendedServices = extracted.recommendedServices;

      // Jika user bertanya tentang sisa paket dan memiliki claimableSessions aktif
      // tapi AI belum menyertakan tag rekomendasi, sertakan claimableSessions pasien!
      if (
        isPackageQuery &&
        context.claimableSessions &&
        context.claimableSessions.length > 0 &&
        recommendedServices.length === 0
      ) {
        recommendedServices = context.claimableSessions;
      }
    } else {
      const fallbackResult = runSmartFallbackEngine(message, context);
      finalReply = fallbackResult.reply;
      recommendedServices = fallbackResult.recommendedServices;
      quickReplies = fallbackResult.quickReplies;

      // Berikan catatan tips konfigurasi API key jika belum ada key
      if (!geminiKey && !groqKey) {
        finalReply += `\n\n*(💡 Asisten berjalan dalam mode Database Real-Time. Masukkan GEMINI_API_KEY di file .env backend untuk mengaktifkan AI percakapan bebas)*`;
      }
    }

    return sendSuccess(res, "Pesan chatbot berhasil diproses", {
      reply: finalReply,
      recommended_services: recommendedServices,
      suggested_services: recommendedServices, // Alias untuk kompatibilitas
      quick_replies: quickReplies,
      provider: providerUsed,
    });
  } catch (err) {
    console.error("Chatbot Error:", err);
    return sendError(res, "Terjadi kendala pada asisten AI: " + err.message, 500);
  }
};

// ── Expose Endpoint /chat dan /message ─────────────────────────────
router.post("/chat", authenticateMobile, handleChatRequest);
router.post("/message", authenticateMobile, handleChatRequest);

export default router;
