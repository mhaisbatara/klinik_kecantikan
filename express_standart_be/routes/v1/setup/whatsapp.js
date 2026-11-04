import express from "express";
import { status } from "../components/tools/general.js";
import { formatDateSystem } from "../components/tools/date_tools.js";

const router = express.Router();
const FLUTTER_BE_URL = process.env.FLUTTER_BE_URL || "http://127.0.0.1:8008";

/**
 * GET /status atau POST /status
 * Mengambil live status koneksi WhatsApp Bot & QR Code
 */
router.all("/status", async (req, res) => {
  try {
    const response = await fetch(`${FLUTTER_BE_URL}/api/v1/whatsapp/status`);
    const data = await response.json();
    return res.status(200).json({
      status: status.SUKSES,
      message: "Berhasil mengambil status WhatsApp Bot",
      datetime: formatDateSystem(),
      data,
    });
  } catch (error) {
    return res.status(200).json({
      status: status.SUKSES,
      message: "Gateway WhatsApp offline",
      datetime: formatDateSystem(),
      data: {
        status: "disconnected",
        isConnected: false,
        connectedNumber: null,
        hasQr: false,
        qrDataUrl: null,
      },
    });
  }
});

/**
 * POST /test-send
 * Mengirim pesan WhatsApp uji coba ke nomor yang ditentukan
 */
router.post("/test-send", async (req, res) => {
  try {
    const { targetPhone, message } = req.body || {};
    if (!targetPhone) {
      return res.status(400).json({
        status: status.BAD_REQUEST,
        message: "Nomor tujuan WhatsApp wajib diisi",
        datetime: formatDateSystem(),
      });
    }

    const response = await fetch(`${FLUTTER_BE_URL}/api/v1/whatsapp/test-send`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ targetPhone, message }),
    });

    const data = await response.json();
    return res.status(response.status).json({
      status: data.success ? status.SUKSES : status.GAGAL,
      message: data.message,
      datetime: formatDateSystem(),
      data: data.result,
    });
  } catch (error) {
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: `Gagal terhubung ke WhatsApp engine: ${error.message}`,
      datetime: formatDateSystem(),
    });
  }
});

/**
 * POST /disconnect
 * Memutuskan sesi WhatsApp Bot (Logout) untuk menautkan nomor baru
 */
router.post("/disconnect", async (req, res) => {
  try {
    const response = await fetch(`${FLUTTER_BE_URL}/api/v1/whatsapp/disconnect`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
    });
    const data = await response.json();
    return res.status(200).json({
      status: status.SUKSES,
      message: data.message || "Sesi WhatsApp berhasil diputuskan",
      datetime: formatDateSystem(),
    });
  } catch (error) {
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: `Gagal logout sesi WhatsApp: ${error.message}`,
      datetime: formatDateSystem(),
    });
  }
});

export default router;
