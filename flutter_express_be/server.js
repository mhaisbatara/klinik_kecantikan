import app from "./app.js";
import { initWhatsAppBot } from "./services/whatsapp_service.js";

const PORT = process.env.APP_PORT || process.env.PORT || 8008;

const server = app
  .listen(PORT, "0.0.0.0", () => {
    console.log("==================================================================");
    console.log("   🌸 KLINIK KECANTIKAN MOBILE RESTful API (FLUTTER BACKEND)     ");
    console.log("==================================================================");
    console.log(`🚀 Server aktif di port: ${PORT}`);
    console.log(`🌐 Local URL:            http://localhost:${PORT}`);
    console.log(`📱 Android Emulator URL: http://10.0.2.2:${PORT}/api/v1`);
    console.log(`🍎 iOS Simulator URL:    http://localhost:${PORT}/api/v1`);
    console.log(`⚡ API Healthcheck:      http://localhost:${PORT}/health`);
    console.log(`📲 Scan WhatsApp Bot:    http://localhost:${PORT}/whatsapp-qr`);
    console.log("==================================================================");

    // Inisialisasi WhatsApp Bot Self-Hosted (100% Gratis Tanpa Pihak Ketiga)
    initWhatsAppBot();
  })
  .on("error", (err) => {
    if (err.code === "EADDRINUSE") {
      console.error(`❌ Port ${PORT} sedang digunakan. Ubah APP_PORT di file .env.`);
      process.exit(1);
    } else {
      console.error("❌ Server Error:", err);
      throw err;
    }
  });

export default server;
