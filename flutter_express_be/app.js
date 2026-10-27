import express from "express";
import cors from "cors";
import path from "path";
import fs from "fs";
import morgan from "morgan";
import { fileURLToPath } from "url";
import dotenv from "dotenv";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const envLocalPath = path.join(__dirname, ".env.local");
if (fs.existsSync(envLocalPath)) {
  dotenv.config({ path: envLocalPath, override: true });
}

import apiV1Router from "./routes/v1/index.js";
import { mobileHeaderMiddleware } from "./middleware/mobile_header_middleware.js";
import { errorHandler } from "./middleware/error_middleware.js";
import { formatDateSystem } from "./utils/date_tools.js";
import {
  getWhatsAppStatus,
  logoutWhatsAppBot,
  sendRealWhatsAppMessage,
} from "./services/whatsapp_service.js";

process.env.TZ = process.env.APP_TZ || "Asia/Jakarta";

const app = express();

// ── 1. Konfigurasi CORS (Ramah Mobile & Web) ───────────────────────────
app.use(
  cors({
    origin: true,
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: [
      "Content-Type",
      "Authorization",
      "Accept",
      "X-Timestamp",
      "X-Kode-Cabang",
      "X-UniqueId",
      "X-Role",
      "X-Signature",
      "X-Credential",
    ],
    credentials: true,
  })
);
app.options("*", cors({ origin: true, credentials: true }));

// ── 2. Request Logging & Body Parsers ─────────────────────────────────
if (process.env.NODE_ENV !== "test") {
  app.use(morgan("dev"));
}
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));
app.use(mobileHeaderMiddleware);

// ── 3. Static Files (Uploads Directory) ───────────────────────────────
const localUploadsDir = path.join(__dirname, "public", "uploads");
const parentUploadsDir = path.resolve(__dirname, "../express_standart_be/public/uploads");
const uploadsDir = fs.existsSync(parentUploadsDir) ? parentUploadsDir : localUploadsDir;

if (!fs.existsSync(localUploadsDir)) {
  fs.mkdirSync(localUploadsDir, { recursive: true });
}

app.use("/uploads", express.static(uploadsDir));
app.use("/api/assets/uploads", express.static(uploadsDir));
app.use("/api/assets", express.static(uploadsDir));

// ── 4. Health Check & Root Endpoints ──────────────────────────────────
app.get("/", (req, res) => {
  return res.status(200).json({
    status: "00",
    name: "Klinik Kecantikan Mobile RESTful API",
    version: "1.0.0",
    client: "flutter_standart_fe",
    datetime: formatDateSystem(),
  });
});

app.get("/health", (req, res) => {
  return res.status(200).send("OK");
});

// ── 4b. WhatsApp Bot Self-Hosted Status & QR Code Web UI ─────────────
app.get("/api/v1/whatsapp/status", (req, res) => {
  return res.status(200).json(getWhatsAppStatus());
});

app.post("/api/v1/whatsapp/test-send", async (req, res) => {
  const { targetPhone, message } = req.body || {};
  if (!targetPhone) {
    return res.status(400).json({ success: false, message: "Nomor tujuan WhatsApp wajib diisi" });
  }
  const msg = message || `*[Uji Coba WhatsApp Bot Klinik]*\nPesan uji coba berhasil terkirim dari Bot WhatsApp Klinik pada ${new Date().toLocaleTimeString('id-ID')} WIB.`;
  const result = await sendRealWhatsAppMessage(targetPhone, msg);
  if (result.success) {
    return res.status(200).json({ success: true, message: `Pesan uji coba berhasil terkirim ke ${targetPhone}!`, result });
  } else {
    return res.status(400).json({ success: false, message: result.reason || result.error || "Gagal mengirim pesan uji coba", result });
  }
});

app.post("/api/v1/whatsapp/disconnect", async (req, res) => {
  const result = await logoutWhatsAppBot();
  return res.status(200).json(result);
});

app.get("/whatsapp-qr", (req, res) => {
  const wa = getWhatsAppStatus();
  const html = `
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WhatsApp Bot Klinik - Self-Hosted Gratis</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
    body { background: #0b132b; color: #f8fafc; min-height: 100vh; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 20px; }
    .card { background: #1c2541; border: 1px solid #3a506b; border-radius: 24px; padding: 32px; max-width: 480px; width: 100%; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.6); text-align: center; }
    .badge { display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 9999px; font-size: 13px; font-weight: 700; margin-bottom: 20px; }
    .badge-waiting { background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3); }
    .badge-connected { background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.3); }
    h1 { font-size: 22px; font-weight: 800; margin-bottom: 8px; color: #ffffff; }
    p.desc { font-size: 13px; color: #94a3b8; line-height: 1.5; margin-bottom: 24px; }
    .qr-box { background: #ffffff; padding: 14px; border-radius: 20px; display: inline-block; margin-bottom: 20px; box-shadow: 0 10px 25px rgba(0,0,0,0.4); }
    .qr-box img { width: 230px; height: 230px; display: block; border-radius: 8px; }
    .instructions { background: #0b132b; border: 1px solid #3a506b; border-radius: 16px; padding: 16px; text-align: left; font-size: 13px; color: #cbd5e1; margin-top: 10px; }
    .instructions ol { padding-left: 20px; }
    .instructions li { margin-bottom: 8px; line-height: 1.4; }
    .instructions li:last-child { margin-bottom: 0; }
    .success-box { padding: 20px 10px; }
    .success-icon { width: 68px; height: 68px; background: rgba(16, 185, 129, 0.15); border: 2px solid #10b981; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; font-size: 32px; color: #10b981; }
    .bot-number { font-size: 18px; font-weight: 800; color: #34d399; margin: 8px 0; }
    .footer-note { font-size: 11px; color: #64748b; margin-top: 20px; }
  </style>
  <script>
    // Auto-refresh cek status
    setInterval(async () => {
      try {
        const res = await fetch('/api/v1/whatsapp/status');
        const data = await res.json();
        const currentlyConnected = ${wa.isConnected};
        if (data.isConnected !== currentlyConnected || (!currentlyConnected && data.hasQr && !document.getElementById('qr-img'))) {
          window.location.reload();
        }
      } catch (e) {}
    }, 3000);
  </script>
</head>
<body>
  <div class="card">
    ${
      wa.isConnected
        ? `
      <div class="badge badge-connected">● TERHUBUNG</div>
      <div class="success-box">
        <div class="success-icon">✓</div>
        <h1>WhatsApp Bot Aktif!</h1>
        <p class="desc">Bot WhatsApp klinik telah berhasil terhubung dan siap mengirimkan pesan OTP secara gratis.</p>
        <div class="bot-number">Nomor Bot: +${wa.connectedNumber}</div>
        <p style="font-size: 12px; color: #94a3b8; margin-top: 14px;">Semua pesan OTP sekarang akan langsung terkirim secara nyata ke nomor WhatsApp pasien tanpa biaya!</p>
      </div>
      `
        : wa.hasQr
        ? `
      <div class="badge badge-waiting">⏳ MENUNGGU SCAN QR CODE</div>
      <h1>Tautkan WhatsApp Klinik</h1>
      <p class="desc">Scan QR Code di bawah menggunakan WhatsApp di HP Anda untuk mengaktifkan bot pengirim pesan OTP (100% Gratis).</p>
      <div class="qr-box">
        <img id="qr-img" src="${wa.qrDataUrl}" alt="Scan WhatsApp QR" />
      </div>
      <div class="instructions">
        <ol>
          <li>Buka aplikasi <strong>WhatsApp</strong> di HP Anda</li>
          <li>Ketuk menu <strong>Titik Tiga</strong> (atau <strong>Pengaturan</strong> di iPhone)</li>
          <li>Pilih <strong>Perangkat Tertaut</strong> &gt; <strong>Tautkan Perangkat</strong></li>
          <li>Arahkan kamera ke QR Code di atas</li>
        </ol>
      </div>
      `
        : `
      <div class="badge badge-waiting">⚙️ MENYIAPKAN SESI WHATSAPP</div>
      <h1>Memulai Bot WhatsApp...</h1>
      <p class="desc">Sedang menginisialisasi modul WhatsApp. Halaman ini akan memuat QR Code secara otomatis dalam beberapa detik...</p>
      `
    }
    <div class="footer-note">Klinik Kecantikan Mobile &bull; Self-Hosted Baileys Engine</div>
  </div>
</body>
</html>
  `;
  return res.status(200).send(html);
});

// ── 5. API Routes v1 ──────────────────────────────────────────────────
app.use("/api/v1", apiV1Router);

// ── 6. 404 Handler ────────────────────────────────────────────────────
app.use((req, res) => {
  return res.status(404).json({
    status: "03",
    message: `Endpoint '${req.method} ${req.originalUrl}' tidak ditemukan`,
    datetime: formatDateSystem(),
  });
});

// ── 7. Global Error Handler ───────────────────────────────────────────
app.use(errorHandler);

export default app;
