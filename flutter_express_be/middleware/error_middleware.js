import { sendError } from "../utils/response.js";
import { status } from "../utils/general.js";

export const errorHandler = (err, req, res, next) => {
  console.error("❌ [API Error]:", err);

  if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
    return sendError(res, "Format payload JSON tidak valid", 400, status.BAD_REQUEST);
  }

  if (err.name === "MulterError") {
    if (err.code === "LIMIT_FILE_SIZE") {
      return sendError(res, "Ukuran file terlalu besar. Maksimal 5MB", 400, status.BAD_REQUEST);
    }
    return sendError(res, `Upload error: ${err.message}`, 400, status.BAD_REQUEST);
  }

  const message = process.env.APP_DEBUG === "true" ? err.message : "Terjadi kesalahan pada server";
  return sendError(res, message, 500, status.BAD_REQUEST);
};
