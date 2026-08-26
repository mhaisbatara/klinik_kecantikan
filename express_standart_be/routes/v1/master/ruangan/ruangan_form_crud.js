import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";

const router = express.Router();

// ─── 1. FETCH CUSTOM FIELDS FOR A ROOM ───────────────────────────────────────
router.post("/ruangan-form-data", async (req, res) => {
  const oPayload = req.body || {};
  const { kode_ruangan } = oPayload;
  const username = req?.auth?.username || "system";

  try {
    if (!kode_ruangan) {
      return res.status(400).json({
        status: status.BAD_REQUEST,
        message: "kode_ruangan wajib diisi",
        datetime: formatDateSystem(),
      });
    }

    const fields = await DB("mst_ruangan_form")
      .where("kode_ruangan", kode_ruangan)
      .orderBy("urutan", "asc")
      .orderBy("id", "asc");

    return res.status(200).json({
      status: status.SUKSES,
      message: "Data form ruangan ditemukan",
      datetime: formatDateSystem(),
      data: fields,
    });
  } catch (error) {
    Logging(error, { file: "/master/ruangan/ruangan_form_crud.js", func: "ruangan-form-data", request: oPayload, response: {}, user: username });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal mengambil data form ruangan",
      datetime: formatDateSystem(),
    });
  }
});

// ─── 2. CREATE CUSTOM FIELD FOR A ROOM ───────────────────────────────────────
router.post("/ruangan-form-create", async (req, res) => {
  const oPayload = req.body || {};
  const { kode_ruangan, label_field, tipe_field, options, is_required, urutan } = oPayload;
  const username = req?.auth?.username || "system";

  try {
    if (!kode_ruangan || !label_field) {
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "kode_ruangan dan label_field wajib diisi",
        datetime: formatDateSystem(),
      });
    }

    const newField = {
      kode_ruangan,
      label_field: label_field.trim(),
      tipe_field: tipe_field || "text",
      options: options ? (typeof options === "string" ? options : JSON.stringify(options)) : null,
      is_required: is_required ? 1 : 0,
      urutan: parseInt(urutan, 10) || 0,
      created_by: username,
      created_at: formatDateSystem(),
      updated_by: username,
      updated_at: formatDateSystem(),
    };

    const [id] = await DB("mst_ruangan_form").insert(newField);

    return res.status(200).json({
      status: status.SUKSES,
      message: "Field form ruangan berhasil ditambahkan",
      datetime: formatDateSystem(),
      data: { id, ...newField },
    });
  } catch (error) {
    Logging(error, { file: "/master/ruangan/ruangan_form_crud.js", func: "ruangan-form-create", request: oPayload, response: {}, user: username });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal membuat field form ruangan",
      datetime: formatDateSystem(),
    });
  }
});

// ─── 3. UPDATE CUSTOM FIELD FOR A ROOM ───────────────────────────────────────
router.post("/ruangan-form-update", async (req, res) => {
  const oPayload = req.body || {};
  const { id, label_field, tipe_field, options, is_required, urutan } = oPayload;
  const username = req?.auth?.username || "system";

  try {
    if (!id || !label_field) {
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "id dan label_field wajib diisi",
        datetime: formatDateSystem(),
      });
    }

    const updateData = {
      label_field: label_field.trim(),
      tipe_field: tipe_field || "text",
      options: options ? (typeof options === "string" ? options : JSON.stringify(options)) : null,
      is_required: is_required ? 1 : 0,
      urutan: parseInt(urutan, 10) || 0,
      updated_by: username,
      updated_at: formatDateSystem(),
    };

    await DB("mst_ruangan_form").where("id", id).update(updateData);

    return res.status(200).json({
      status: status.SUKSES,
      message: "Field form ruangan berhasil diperbarui",
      datetime: formatDateSystem(),
    });
  } catch (error) {
    Logging(error, { file: "/master/ruangan/ruangan_form_crud.js", func: "ruangan-form-update", request: oPayload, response: {}, user: username });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal memperbarui field form ruangan",
      datetime: formatDateSystem(),
    });
  }
});

// ─── 4. DELETE CUSTOM FIELD FOR A ROOM ───────────────────────────────────────
router.post("/ruangan-form-delete", async (req, res) => {
  const oPayload = req.body || {};
  const { id } = oPayload;
  const username = req?.auth?.username || "system";

  try {
    if (!id) {
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "id field wajib diisi",
        datetime: formatDateSystem(),
      });
    }

    await DB("mst_ruangan_form").where("id", id).del();

    return res.status(200).json({
      status: status.SUKSES,
      message: "Field form ruangan berhasil dihapus",
      datetime: formatDateSystem(),
    });
  } catch (error) {
    Logging(error, { file: "/master/ruangan/ruangan_form_crud.js", func: "ruangan-form-delete", request: oPayload, response: {}, user: username });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal menghapus field form ruangan",
      datetime: formatDateSystem(),
    });
  }
});

// ─── 5. SIMPAN HASIL FORM & CATATAN TINDAKAN PASIEN ──────────────────────────
router.post("/antrian-layanan-simpan-form", async (req, res) => {
  const oPayload = req.body || {};
  const { kode_antrian_layanan, hasil_form, catatan_petugas, status_tindakan } = oPayload;
  const username = req?.auth?.username || "system";

  try {
    if (!kode_antrian_layanan) {
      return res.status(422).json({
        status: status.BAD_REQUEST,
        message: "kode_antrian_layanan wajib diisi",
        datetime: formatDateSystem(),
      });
    }

    const updateObj = {
      hasil_form: hasil_form ? (typeof hasil_form === "string" ? hasil_form : JSON.stringify(hasil_form)) : null,
      catatan_petugas: catatan_petugas ? catatan_petugas.trim() : null,
      updated_by: username,
      updated_at: formatDateSystem(),
    };

    if (status_tindakan && ["menunggu", "dipanggil", "selesai", "batal"].includes(status_tindakan)) {
      updateObj.status = status_tindakan;
      if (status_tindakan === "selesai") {
        updateObj.selesai_at = formatDateSystem();
      }
    }

    await DB("trx_antrian_layanan")
      .where("kode_antrian_layanan", kode_antrian_layanan)
      .update(updateObj);

    return res.status(200).json({
      status: status.SUKSES,
      message: "Hasil penanganan & catatan ruangan berhasil disimpan",
      datetime: formatDateSystem(),
    });
  } catch (error) {
    Logging(error, { file: "/master/ruangan/ruangan_form_crud.js", func: "antrian-layanan-simpan-form", request: oPayload, response: {}, user: username });
    return res.status(500).json({
      status: status.BAD_REQUEST,
      message: "Gagal menyimpan hasil form penanganan pasien",
      datetime: formatDateSystem(),
    });
  }
});

export default router;
