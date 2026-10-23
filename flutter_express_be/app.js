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
