/**
 * Helper terpusat untuk memetakan label Bahasa Indonesia / UI ke nilai ENUM sah database MySQL `trx_rekam_medis`,
 * serta memetakan nilai ENUM database kembali ke label tampilan UI.
 *
 * Nilai ENUM MySQL trx_rekam_medis:
 * - pemeriksaan_acne: 'none', 'mild', 'moderate', 'severe'
 * - pemeriksaan_inflammation: 'none', 'mild', 'moderate', 'severe'
 * - pemeriksaan_skin_type: 'normal', 'oily', 'dry', 'combination', 'sensitive'
 * - pemeriksaan_pigmentation: 'none', 'mild', 'moderate', 'severe'
 * - pemeriksaan_sensitivity: 'low', 'medium', 'high'
 */

export function mapAcneToEnum(val) {
  if (!val) return "none";
  const v = String(val).toLowerCase();
  if (v.includes("none") || v.includes("tidak")) return "none";
  if (v.includes("grade 1") || v.includes("mild") || v.includes("ringan")) return "mild";
  if (v.includes("grade 2") || v.includes("moderate") || v.includes("sedang")) return "moderate";
  if (v.includes("grade 3") || v.includes("grade 4") || v.includes("severe") || v.includes("berat")) return "severe";
  return "none";
}

export function mapInflammationToEnum(val) {
  if (!val) return "none";
  const v = String(val).toLowerCase();
  if (v.includes("none") || v.includes("tidak")) return "none";
  if (v.includes("ringan") || v.includes("mild")) return "mild";
  if (v.includes("sedang") || v.includes("moderate")) return "moderate";
  if (v.includes("berat") || v.includes("severe")) return "severe";
  return "none";
}

export function mapSkinTypeToEnum(val) {
  if (!val) return "normal";
  const v = String(val).toLowerCase();
  if (v.includes("normal")) return "normal";
  if (v.includes("berminyak") || v.includes("oily")) return "oily";
  if (v.includes("kering") || v.includes("dry")) return "dry";
  if (v.includes("kombinasi") || v.includes("combination")) return "combination";
  if (v.includes("sensitif") || v.includes("sensitive")) return "sensitive";
  return "normal";
}

export function mapPigmentationToEnum(val) {
  if (!val) return "none";
  const v = String(val).toLowerCase();
  if (v.includes("none") || v.includes("tidak")) return "none";
  if (v.includes("melasma") || v.includes("mild")) return "mild";
  if (v.includes("pih") || v.includes("freckles") || v.includes("moderate")) return "moderate";
  if (v.includes("lentigo") || v.includes("pie") || v.includes("severe")) return "severe";
  return "none";
}

export function mapSensitivityToEnum(val) {
  if (!val) return "low";
  const v = String(val).toLowerCase();
  if (v.includes("rendah") || v.includes("low")) return "low";
  if (v.includes("sedang") || v.includes("medium")) return "medium";
  if (v.includes("tinggi") || v.includes("high")) return "high";
  return "low";
}

export function mapHeaderRMDataToDB(headerData = {}) {
  if (!headerData || typeof headerData !== "object") return {};
  const mapped = { ...headerData };

  if (mapped.pemeriksaan_acne !== undefined) {
    mapped.pemeriksaan_acne = mapAcneToEnum(mapped.pemeriksaan_acne);
  }
  if (mapped.pemeriksaan_inflammation !== undefined) {
    mapped.pemeriksaan_inflammation = mapInflammationToEnum(mapped.pemeriksaan_inflammation);
  }
  if (mapped.pemeriksaan_skin_type !== undefined) {
    mapped.pemeriksaan_skin_type = mapSkinTypeToEnum(mapped.pemeriksaan_skin_type);
  }
  if (mapped.pemeriksaan_pigmentation !== undefined) {
    mapped.pemeriksaan_pigmentation = mapPigmentationToEnum(mapped.pemeriksaan_pigmentation);
  }
  if (mapped.pemeriksaan_sensitivity !== undefined) {
    mapped.pemeriksaan_sensitivity = mapSensitivityToEnum(mapped.pemeriksaan_sensitivity);
  }

  return mapped;
}

export function mapEnumToDisplayLabel(columnName, val) {
  if (!val) return "-";
  const v = String(val).toLowerCase();

  switch (columnName) {
    case "pemeriksaan_acne":
      if (v === "none" || v === "tidak ada") return "Tidak Ada";
      if (v === "mild") return "Grade 1 (Mild)";
      if (v === "moderate") return "Grade 2 (Moderate)";
      if (v === "severe") return "Grade 3 / 4 (Severe)";
      return val;

    case "pemeriksaan_inflammation":
      if (v === "none" || v === "tidak ada") return "Tidak Ada";
      if (v === "mild") return "Ringan";
      if (v === "moderate") return "Sedang";
      if (v === "severe") return "Berat";
      return val;

    case "pemeriksaan_skin_type":
      if (v === "normal") return "Normal";
      if (v === "oily") return "Berminyak";
      if (v === "dry") return "Kering";
      if (v === "combination") return "Kombinasi";
      if (v === "sensitive") return "Sensitif";
      return val;

    case "pemeriksaan_pigmentation":
      if (v === "none" || v === "tidak ada") return "Tidak Ada";
      if (v === "mild") return "Melasma / Ringan";
      if (v === "moderate") return "PIH / Freckles / Sedang";
      if (v === "severe") return "Lentigo / PIE / Berat";
      return val;

    case "pemeriksaan_sensitivity":
      if (v === "low") return "Rendah";
      if (v === "medium") return "Sedang";
      if (v === "high") return "Tinggi";
      return val;

    default:
      return val;
  }
}
