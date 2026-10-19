/**
 * Middleware untuk validasi header mobile request
 * Didesain ramah untuk aplikasi Flutter/Mobile (toleran terhadap sedikit perbedaan jam perangkat)
 */
export const mobileHeaderMiddleware = (req, res, next) => {
  // Passthrough timestamp jika ada
  const timestamp = req.headers["x-timestamp"];
  if (timestamp) {
    const inputDate = new Date(timestamp);
    if (!isNaN(inputDate.getTime())) {
      req.requestTime = inputDate;
    }
  }

  // Passthrough branch header jika ada
  const branch = req.headers["x-kode-cabang"];
  if (branch) {
    req.clientBranch = branch;
  }

  next();
};
