import multer from "multer";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const localUploadDir = path.join(__dirname, "..", "public", "uploads");
const parentUploadDir = path.resolve(__dirname, "../../express_standart_be/public/uploads");
const targetUploadDir = fs.existsSync(parentUploadDir) ? parentUploadDir : localUploadDir;

if (!fs.existsSync(localUploadDir)) {
  fs.mkdirSync(localUploadDir, { recursive: true });
}
if (!fs.existsSync(parentUploadDir)) {
  try {
    fs.mkdirSync(parentUploadDir, { recursive: true });
  } catch (_) {}
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, targetUploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const fname = `${file.fieldname}-${uniqueSuffix}${ext}`;
    cb(null, fname);
  },
});

const fileFilter = (req, file, cb) => {
  const allowedExts = [".jpg", ".jpeg", ".png", ".webp", ".jfif"];
  const allowedMime = [
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/jpg",
    "application/octet-stream",
  ];
  const ext = path.extname(file.originalname).toLowerCase();
  const isAllowedExt = allowedExts.includes(ext);
  const isAllowedMime = allowedMime.includes(file.mimetype);

  if (isAllowedExt || (isAllowedMime && file.mimetype !== "application/octet-stream")) {
    cb(null, true);
  } else {
    cb(new Error("Format file tidak didukung. Harap upload gambar (JPG, PNG, WEBP)"), false);
  }
};

export const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter,
});
