/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Sistem Klinik
 * @file antrian_layanan_panggil.js
 * @description Endpoint untuk mengupdate status antrian layanan (dipanggil, selesai, batal, menunggu)
 *
 * @author Antigravity
 * @created 2026-08-21
 */

import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging, ChangesLog } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";
import Joi from "joi";

const router = express.Router();

router.post("/", async (req, res) => {
  const oPayload = { ...req.query, ...req.body };
  const username = req?.auth?.username || "";

  try {
    const cValidation = await Joi.object({
      kode_antrian_layanan: Joi.string().required().label("Kode Antrian Layanan"),
      aksi: Joi.string().valid("dipanggil", "selesai", "batal", "menunggu").required().label("Aksi"),
    }).validateAsync(
      {
        kode_antrian_layanan: oPayload.kode_antrian_layanan || oPayload.kode_antrian,
        aksi: oPayload.aksi || oPayload.status,
      },
      { allowUnknown: true }
    );

    const kodeAntrian = cValidation.kode_antrian_layanan;
    const aksi = cValidation.aksi;
    let updatedRecord = null;

    await DB.transaction(async (trx) => {
      const record = await trx("trx_antrian_layanan")
        .where("kode_antrian_layanan", kodeAntrian)
        .forUpdate()
        .first();

      if (!record) {
        const error = new Error("Data antrian layanan tidak ditemukan");
        error.statusCode = 404;
        throw error;
      }

      const updateData = {
        status: aksi,
        updated_by: username,
        updated_at: formatDateSystem(),
      };

      if (aksi === "dipanggil") {
        updateData.dipanggil_at = formatDateSystem();
      } else if (aksi === "selesai") {
        updateData.selesai_at = formatDateSystem();
      }

      await trx("trx_antrian_layanan")
        .where("kode_antrian_layanan", kodeAntrian)
        .update(updateData);

      updatedRecord = { ...record, ...updateData };

      await ChangesLog(
        {
          description: `Update status antrian layanan ${record.nomor_antrian} ke ${aksi}`,
          tableName: "trx_antrian_layanan",
          referenceCode: kodeAntrian,
          action: "UPDATE",
          dataBefore: record,
          dataAfter: updatedRecord,
          user: username,
          tz: oPayload.tz || "UTC",
        },
        trx
      );
    });

    const pesanAksi = {
      dipanggil: `Nomor antrian layanan ${updatedRecord.nomor_antrian} dipanggil`,
      selesai: `Nomor antrian layanan ${updatedRecord.nomor_antrian} selesai`,
      batal: `Nomor antrian layanan ${updatedRecord.nomor_antrian} dibatalkan`,
      menunggu: `Nomor antrian layanan ${updatedRecord.nomor_antrian} dikembalikan ke menunggu`,
    };

    return res.status(200).json({
      status: status.SUKSES,
      message: pesanAksi[aksi] || "Berhasil mengubah status antrian",
      datetime: formatDateSystem(),
      data: updatedRecord,
    });
  } catch (error) {
    if (error.statusCode === 404) {
      return res.status(404).json({
        status: status.NOT_FOUND,
        message: error.message,
        datetime: formatDateSystem(),
      });
    }

    Logging(error, { file: "/master/antrian_layanan/antrian_layanan_panggil.js", func: "panggil", request: oPayload, response: {}, user: username });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: error.message || "Gagal mengubah status antrian layanan",
      datetime: formatDateSystem(),
    });
  }
});

export default router;
