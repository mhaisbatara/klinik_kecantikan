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
      {
        kode_promo: Joi.string().required().label("Kode Promo"),
        jenis_item: Joi.string().valid("produk", "layanan", "paket").required().label("Jenis Item"),
        kode_item: Joi.string().required().label("Kode Item"),
        status: Joi.string().valid("aktif", "nonaktif").optional().default("aktif").label("Status")
      },
      { "any.required": "{#label} wajib diisi", "any.only": "{#label} tidak valid" },
      oPayload,
      { allowUnknown: true }
    );

    if (cValidation) return res.status(422).json({ status: status.BAD_REQUEST, message: cValidation, datetime: formatDateSystem() });

    // Validate kode_promo exists
    const promo = await DB("mst_promo").where("kode_promo", oPayload.kode_promo).first();
    if (!promo) return res.status(422).json({ status: status.BAD_REQUEST, message: "Promo tidak ditemukan", datetime: formatDateSystem() });

    // Check duplicate kode_promo + jenis_item + kode_item
    const existing = await DB("mst_detail_promo")
      .where("kode_promo", oPayload.kode_promo)
      .where("jenis_item", oPayload.jenis_item)
      .where("kode_item", oPayload.kode_item)
      .first();
    if (existing) return res.status(422).json({ status: status.BAD_REQUEST, message: "Item ini sudah terdaftar pada promo yang sama", datetime: formatDateSystem() });

    let kode = "";
    await DB.transaction(async (trx) => {
      const last = await trx("mst_detail_promo").orderBy("id", "desc").first();
      let n = 1;
      if (last?.kode_detail_promo) {
        n = (parseInt(last.kode_detail_promo.replace("DPRM-", "")) || 0) + 1;
      }
      kode = `DPRM-${String(n).padStart(4, "0")}`;

      const oData = {
        kode_detail_promo: kode,
        kode_promo: oPayload.kode_promo,
        jenis_item: oPayload.jenis_item,
        kode_item: oPayload.kode_item,
        status: oPayload.status || "aktif",
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem()
      };

      await trx("mst_detail_promo").insert(oData);
      await ChangesLog({ description: `Tambah Detail Promo ${kode}`, tableName: "mst_detail_promo", referenceCode: kode, action: "CREATE", dataBefore: null, dataAfter: oData, user: username, tz: oPayload.tz || "UTC" }, trx);
    });

    return res.status(200).json({ status: status.SUKSES, message: "Detail promo berhasil ditambahkan", datetime: formatDateSystem(), data: { kode_detail_promo: kode } });
  } catch (error) {
    const oResult = { status: status.BAD_REQUEST, message: error.message || "Sistem sedang maintenance", datetime: formatDateSystem() };
    Logging(error, { file: "/master/detail_promo/detail_promo_create.js", func: "create", request: oPayload, response: oResult, user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
