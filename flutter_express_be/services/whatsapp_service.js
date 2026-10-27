import makeWASocket, {
  useMultiFileAuthState,
  DisconnectReason,
  fetchLatestBaileysVersion,
} from "@whiskeysockets/baileys";
import pino from "pino";
import QRCode from "qrcode";
import qrcodeTerminal from "qrcode-terminal";
import path from "path";
import fs from "fs";

const AUTH_FOLDER = path.resolve("./baileys_auth_info");

let waSocket = null;
let connectionStatus = "disconnected"; // 'disconnected' | 'connecting' | 'qr_ready' | 'connected'
let currentQrString = null;
let currentQrDataUrl = null;
let connectedNumber = null;
let isInitializing = false;

/**
 * Inisialisasi WhatsApp Bot Self-Hosted (100% Gratis Tanpa Pihak Ketiga)
 */
export async function initWhatsAppBot() {
  if (isInitializing) return;
  isInitializing = true;
  connectionStatus = "connecting";

  // Bersihkan socket lama dan event listener agar tidak terjadi duplikasi koneksi (error 440)
  if (waSocket) {
    try {
      waSocket.ev.removeAllListeners();
      waSocket.end();
    } catch (_) {}
    waSocket = null;
  }

  try {
    if (!fs.existsSync(AUTH_FOLDER)) {
      fs.mkdirSync(AUTH_FOLDER, { recursive: true });
    }

    const { state, saveCreds } = await useMultiFileAuthState(AUTH_FOLDER);
    const { version } = await fetchLatestBaileysVersion();

    waSocket = makeWASocket({
      version,
      auth: state,
      logger: pino({ level: "silent" }),
      printQRInTerminal: false,
      browser: ["Klinik Kecantikan Bot", "Chrome", "1.0.0"],
      connectTimeoutMs: 60000,
      defaultQueryTimeoutMs: 60000,
      keepAliveIntervalMs: 10000,
    });

    waSocket.ev.on("creds.update", saveCreds);

    waSocket.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update;

      if (qr) {
        connectionStatus = "qr_ready";
        currentQrString = qr;
        try {
          currentQrDataUrl = await QRCode.toDataURL(qr, { margin: 2, scale: 8 });
        } catch (e) {
          console.error("Gagal generate DataURL QR:", e.message);
        }

        console.log("\n==================================================================");
        console.log("📲 [SCAN QR CODE WHATSAPP BOT KLINIK - 100% GRATIS TANPA FONNTE]");
        console.log("1. Buka WhatsApp di HP Anda");
        console.log("2. Tekan menu Titik Tiga (atau Pengaturan) > Perangkat Tertaut > Tautkan Perangkat");
        console.log("3. Scan QR code di bawah ini, atau buka di browser: http://localhost:8008/whatsapp-qr");
        console.log("==================================================================");
        try {
          qrcodeTerminal.generate(qr, { small: true });
        } catch (_) {}
      }

      if (connection === "open") {
        connectionStatus = "connected";
        currentQrString = null;
        currentQrDataUrl = null;
        connectedNumber = waSocket?.user?.id ? waSocket.user.id.split(":")[0] : "Aktif";

        console.log("\n==================================================================");
        console.log("🎉 [WHATSAPP BOT KLINIK SUKSES TERHUBUNG!]");
        console.log(`📱 Nomor WhatsApp Bot : ${connectedNumber}`);
        console.log("✨ Siap mengirimkan kode OTP secara otomatis & gratis ke pasien!");
        console.log("==================================================================\n");
      }

      if (connection === "close") {
        const statusCode = lastDisconnect?.error?.output?.statusCode;
        const isLoggedOut = statusCode === DisconnectReason.loggedOut;
        const isReplaced = statusCode === DisconnectReason.connectionReplaced;

        connectionStatus = "disconnected";
        currentQrString = null;
        currentQrDataUrl = null;

        console.log(`[WhatsApp Bot] Koneksi terputus (Status code: ${statusCode}).`);

        if (isReplaced) {
          console.log("[WhatsApp Bot] Sesi WhatsApp dibuka di browser/perangkat lain. Bot dijeda 20 detik sebelum cek kembali...");
          setTimeout(() => {
            isInitializing = false;
            initWhatsAppBot();
          }, 20000);
        } else if (isLoggedOut) {
          console.log("[WhatsApp Bot] Sesi telah logout. Menghapus auth dan menyiapkan QR baru...");
          try {
            fs.rmSync(AUTH_FOLDER, { recursive: true, force: true });
          } catch (_) {}
          setTimeout(() => {
            isInitializing = false;
            initWhatsAppBot();
          }, 2000);
        } else {
          console.log("[WhatsApp Bot] Mencoba menyambungkan kembali dalam 5 detik...");
          setTimeout(() => {
            isInitializing = false;
            initWhatsAppBot();
          }, 5000);
        }
      }
    });
  } catch (error) {
    console.error("[WhatsApp Bot Init Error]:", error);
    connectionStatus = "disconnected";
    isInitializing = false;
  }
}

/**
 * Cek status koneksi WhatsApp Bot
 */
export function getWhatsAppStatus() {
  return {
    status: connectionStatus,
    isConnected: connectionStatus === "connected",
    connectedNumber,
    qrDataUrl: currentQrDataUrl,
    hasQr: Boolean(currentQrDataUrl),
  };
}

/**
 * Kirim Pesan WhatsApp Nyata Langsung via Backend Self-Hosted
 */
export async function sendRealWhatsAppMessage(targetPhone, message) {
  if (connectionStatus !== "connected" || !waSocket) {
    return {
      success: false,
      status: connectionStatus,
      reason: "WhatsApp Bot belum terhubung. Silakan scan QR code terlebih dahulu di http://localhost:8008/whatsapp-qr",
    };
  }

  try {
    let phone = String(targetPhone).replace(/[^0-9]/g, "");
    if (phone.startsWith("0")) {
      phone = "62" + phone.slice(1);
    }
    const jid = `${phone}@s.whatsapp.net`;

    const result = await waSocket.sendMessage(jid, { text: message });
    console.log(`✅ [Self-Hosted WA] Berhasil kirim pesan nyata ke ${phone}`);
    return { success: true, via: "baileys_self_hosted", result };
  } catch (err) {
    console.error(`❌ [Self-Hosted WA Error] Gagal kirim pesan ke ${targetPhone}:`, err.message);
    return { success: false, via: "baileys_error", error: err.message };
  }
}

/**
 * Logout / Putuskan Sesi WhatsApp Bot untuk Menautkan Nomor Baru
 */
export async function logoutWhatsAppBot() {
  try {
    if (waSocket) {
      await waSocket.logout().catch(() => {});
    }
  } catch (_) {}

  try {
    fs.rmSync(AUTH_FOLDER, { recursive: true, force: true });
  } catch (_) {}

  connectionStatus = "disconnected";
  currentQrString = null;
  currentQrDataUrl = null;
  connectedNumber = null;

  console.log("[WhatsApp Bot] Sesi berhasil diputus oleh Superadmin. Menyiapkan QR baru...");

  setTimeout(() => {
    isInitializing = false;
    initWhatsAppBot();
  }, 1000);

  return {
    success: true,
    message: "Sesi WhatsApp berhasil diputuskan. QR Code baru sedang disiapkan.",
  };
}
