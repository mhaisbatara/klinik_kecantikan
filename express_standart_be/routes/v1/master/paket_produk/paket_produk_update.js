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
        kode_paket_produk: Joi.string().required().label("Kode Paket"),
        nama: Joi.string().max(100).required().label("Nama Paket Produk"),
        harga_paket: Joi.number().min(0).required().label("Harga Paket"),
        masa_berlaku_hari: Joi.number().integer().min(1).required().label("Masa Berlaku (Hari)"),
        status: Joi.string().valid("aktif", "nonaktif").required().label("Status"),
        details: Joi.array().items(
          Joi.object({
            kode_produk: Joi.string().required().label("Produk"),
            jumlah: Joi.number().integer().min(1).required().label("Jumlah")
          })
        ).min(1).required().label("Detail Produk")
      },
      { "any.required": "{#label} wajib diisi" }, oPayload, { allowUnknown: true }
    );
    if (cValidation) return res.status(422).json({ status: status.BAD_REQUEST, message: cValidation, datetime: formatDateSystem() });

    await DB.transaction(async (trx) => {
      const prev = await trx("mst_paket_produk").where("kode_paket_produk", oPayload.kode_paket_produk).forUpdate().first();
      if (!prev) { const e = new Error("Data tidak ditemukan"); e.statusCode = 404; throw e; }

      const oData = {
        nama: oPayload.nama,
        harga_paket: oPayload.harga_paket,
        masa_berlaku_hari: oPayload.masa_berlaku_hari,
        status: oPayload.status,
        updated_by: username,
        updated_at: formatDateSystem(),
      };
      await trx("mst_paket_produk").where("kode_paket_produk", oPayload.kode_paket_produk).update(oData);

      // Re-insert detail items
      await trx("mst_detail_paket_produk").where("kode_paket_produk", oPayload.kode_paket_produk).del();
      let detailSeq = 1;
      const detailInserts = oPayload.details.map((d) => ({
        kode_detail_paket_produk: `DPPRD-${oPayload.kode_paket_produk}-${String(detailSeq++).padStart(2, "0")}`,
        kode_paket_produk: oPayload.kode_paket_produk,
        kode_produk: d.kode_produk,
        jumlah: d.jumlah,
        tz: oPayload.tz || "UTC",
        created_by: username,
        created_at: formatDateSystem(),
        updated_by: username,
        updated_at: formatDateSystem(),
      }));
      await trx("mst_detail_paket_produk").insert(detailInserts);

      await ChangesLog({ description: `Edit Paket Produk ${oPayload.kode_paket_produk}`, tableName: "mst_paket_produk", referenceCode: oPayload.kode_paket_produk, action: "UPDATE", dataBefore: prev, dataAfter: { ...prev, ...oData, details: detailInserts }, user: username, tz: oPayload.tz || "UTC" }, trx);
    });

    return res.status(200).json({ status: status.SUKSES, message: "Paket produk berhasil diupdate", datetime: formatDateSystem() });
  } catch (error) {
    if (error.statusCode === 404) return res.status(404).json({ status: status.NOT_FOUND, message: "Data tidak ditemukan", datetime: formatDateSystem() });
    const oResult = { status: status.BAD_REQUEST, message: "Sistem sedang maintenance", datetime: formatDateSystem() };
    Logging(error, { file: "/master/paket_produk/paket_produk_update.js", func: "update", request: oPayload, response: oResult, user: username });
    return res.status(500).json(oResult);
  }
});

export default router;
