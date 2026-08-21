import express from "express";
import { status } from "../../components/tools/general.js";
import Joi from "joi";
import DB from "../../../../core/config/knex.js";
import { Logging, ChangesLog, validatePayload } from "../../components/tools/servertool.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
const router = express.Router();
router.post("/", async (req, res) => {
  const oPayload = req.body;
  const username = req?.auth?.username || "";
  try {
    const cValidation = await validatePayload(
      { nama: Joi.string().max(100).required().label("Nama Karyawan"), no_sip: Joi.string().max(20).required().label("No SIP"), jabatan: Joi.string().valid("dokter", "perawat", "admin", "kasir", "apoteker", "terapis").required().label("Jabatan"), no_hp: Joi.string().max(20).allow("", null).label("No HP"), email: Joi.string().email().max(100).allow("", null).label("Email"), kode_user: Joi.string().allow("", null).label("Kode User"), status: Joi.string().valid("aktif", "nonaktif").required().label("Status") },
      { "any.required": "{#label} wajib diisi", "any.only": "{#label} tidak valid" },
      oPayload, { uniqueField: ["no_sip"], table: "mst_karyawan", allowUnknown: true }
    );
    if (cValidation) return res.status(422).json({ status: status.BAD_REQUEST, message: cValidation, datetime: formatDateSystem() });
    await DB.transaction(async (trx) => {
      const oData = { no_sip: oPayload.no_sip, kode_user: oPayload.kode_user || null, nama: oPayload.nama, jabatan: oPayload.jabatan, no_hp: oPayload.no_hp || null, email: oPayload.email || null, status: oPayload.status, tz: oPayload.tz || "UTC", created_by: username, created_at: formatDateSystem(), updated_by: username, updated_at: formatDateSystem() };
      await trx("mst_karyawan").insert(oData);
      await ChangesLog({ description: `Tambah Karyawan ${oPayload.no_sip}`, tableName: "mst_karyawan", referenceCode: oPayload.no_sip, action: "CREATE", dataBefore: null, dataAfter: oData, user: username, tz: oPayload.tz || "UTC" }, trx);
    });
    return res.status(200).json({ status: status.SUKSES, message: "Karyawan berhasil ditambahkan", datetime: formatDateSystem() });
  } catch (error) {
    const oResult = { status: status.BAD_REQUEST, message: error.message || "Sistem sedang maintenance", datetime: formatDateSystem() };
    Logging(error, { file: "/master/karyawan/karyawan_create.js", func: "create", request: oPayload, response: oResult, user: username });
    return res.status(500).json(oResult);
  }
});
export default router;
