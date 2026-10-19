import express from "express";
import authRoutes from "./auth/auth_routes.js";
import dashboardRoutes from "./dashboard/dashboard_routes.js";
import layananRoutes from "./layanan/layanan_routes.js";
import produkRoutes from "./produk/produk_routes.js";
import promoRoutes from "./promo/promo_routes.js";
import paketRoutes from "./paket/paket_routes.js";
import dokterRoutes from "./dokter/dokter_routes.js";
import cabangRoutes from "./cabang/cabang_routes.js";
import bookingRoutes from "./booking/booking_routes.js";
import antreanRoutes from "./antrean/antrean_routes.js";
import rekamMedisRoutes from "./rekam_medis/rekam_medis_routes.js";
import profileRoutes from "./profile/profile_routes.js";

const router = express.Router();

// ── Modul Route Hub untuk Flutter Mobile Backend ──
router.use("/auth", authRoutes);
router.use("/dashboard", dashboardRoutes);
router.use("/layanan", layananRoutes);
router.use("/produk", produkRoutes);
router.use("/promo", promoRoutes);
router.use("/paket", paketRoutes);
router.use("/dokter", dokterRoutes);
router.use("/cabang", cabangRoutes);
router.use("/booking", bookingRoutes);
router.use("/antrean", antreanRoutes);
router.use("/rekam-medis", rekamMedisRoutes);
router.use("/profile", profileRoutes);

export default router;
