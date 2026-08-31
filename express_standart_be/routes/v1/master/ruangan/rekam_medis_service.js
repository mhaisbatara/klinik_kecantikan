import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";

/**
 * Sync rekam medis data for a given visit (kode_kunjungan).
 * Store / merge custom form values and staff notes per room into trx_rekam_medis.
 *
 * @param {Object} params
 * @param {string} params.kode_kunjungan
 * @param {string} params.kode_ruangan
 * @param {string} params.nama_ruangan
 * @param {Object} params.hasil_form
 * @param {string} params.catatan_petugas
 * @param {string} params.username
 */
export async function syncRekamMedisPerKunjungan({
  kode_kunjungan,
  kode_ruangan,
  nama_ruangan,
  hasil_form,
  catatan_petugas,
  username = "system",
}) {
  if (!kode_kunjungan) return;

  try {
    const hasTable = await DB.schema.hasTable("trx_rekam_medis");
    if (!hasTable) {
      await DB.schema.createTable("trx_rekam_medis", (table) => {
        table.bigIncrements("id").primary();
        table.string("kode_kunjungan", 50).notNullable();
        table.string("no_rm", 50).nullable();
        table.text("detail_layanan_ruangan").nullable();
        table.text("catatan_petugas").nullable();
        table.string("created_by", 100).nullable();
        table.string("created_at", 50).nullable();
        table.string("updated_by", 100).nullable();
        table.string("updated_at", 50).nullable();
      });
    } else {
      const hasDetailCol = await DB.schema.hasColumn("trx_rekam_medis", "detail_layanan_ruangan");
      if (!hasDetailCol) {
        await DB.schema.table("trx_rekam_medis", (table) => {
          table.text("detail_layanan_ruangan").nullable();
        });
      }
    }

    const kunjungan = await DB("trx_kunjungan")
      .where("kode_kunjungan", kode_kunjungan)
      .first();
    const no_rm = kunjungan ? kunjungan.no_rm : null;

    const existingRM = await DB("trx_rekam_medis")
      .where("kode_kunjungan", kode_kunjungan)
      .first();

    let detailRuanganObj = {};
    if (existingRM && existingRM.detail_layanan_ruangan) {
      try {
        detailRuanganObj =
          typeof existingRM.detail_layanan_ruangan === "string"
            ? JSON.parse(existingRM.detail_layanan_ruangan)
            : existingRM.detail_layanan_ruangan;
      } catch (_) {
        detailRuanganObj = {};
      }
    }

    const keyRuangan = kode_ruangan || "default";
    detailRuanganObj[keyRuangan] = {
      kode_ruangan,
      nama_ruangan,
      hasil_form,
      catatan_petugas,
      rekomendasi_items: (typeof hasil_form === "object" && Array.isArray(hasil_form?.rekomendasi_items)) ? hasil_form.rekomendasi_items : [],
      updated_at: formatDateSystem(),
      updated_by: username,
    };

    const detailJsonStr = JSON.stringify(detailRuanganObj);
    const now = formatDateSystem();

    if (existingRM) {
      await DB("trx_rekam_medis")
        .where("id", existingRM.id)
        .update({
          no_rm: no_rm || existingRM.no_rm || "RM-000000",
          detail_layanan_ruangan: detailJsonStr,
          catatan: catatan_petugas || existingRM.catatan,
          updated_by: username,
          updated_at: now,
        });
    } else {
      await DB("trx_rekam_medis").insert({
        kode_rekam_medis: `RM-${kode_kunjungan}`,
        kode_kunjungan: kode_kunjungan,
        no_rm: no_rm || "RM-000000",
        no_sip: "-",
        detail_layanan_ruangan: detailJsonStr,
        catatan: catatan_petugas || "",
        tz: "Asia/Jakarta",
        created_by: username,
        created_at: now,
        updated_by: username,
        updated_at: now,
      });
    }
  } catch (err) {
    console.error("Error in syncRekamMedisPerKunjungan:", err);
  }
}
