/**
 * General constants and helper utilities
 */

export const status = {
  SUKSES: "00",
  GAGAL: "01",
  PENDING: "02",
  NOT_FOUND: "03",
  BAD_REQUEST: "99",
};

export const rupiahConverter = (number = 0) => {
  const num = Number(number) || 0;
  const formattedNumber = new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(num);

  return formattedNumber.replace("Rp", "Rp ");
};

export const sanitizeString = (str) => {
  if (typeof str !== "string") return str;
  return str.replace(/<[^>]*>/g, "").trim();
};
