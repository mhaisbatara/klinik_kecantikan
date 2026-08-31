import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";

/**
 * Sync rekam medis per ruangan untuk kunjungan pasien (kode_kunjungan & kode_ruangan).
 * Menyimpan data penanganan per ruangan secara terstruktur ke `trx_rekam_medis_ruangan`
 * serta dokumentasi foto ke `trx_rekam_medis_foto`.
 *
 * JANGAN LAGI MENULIS/APPEND STRINGS KE KOLOM LAMA TRX_REKAM_MEDIS.
 */
export async function syncRekamMedisPerAntrian({
  kode_kunjungan,
  kode_antrian_layanan,
  kode_ruangan,
  nama_ruangan,
  hasil_form,
  catatan_petugas,
  catatan_tindakan,
  catatan_hasil_treatment,
  kode_karyawan,
  username = "system",
}) {
  if (!kode_kunjungan) return null;

  try {
    // 1. Pastikan Header Record di `trx_rekam_medis` ADA (sebagai parent FK id_rekam_medis)
    const kunjungan = await DB("trx_kunjungan")
      .where("kode_kunjungan", kode_kunjungan)
      .first();

    const no_rm = kunjungan ? kunjungan.no_rm : null;

    let existingHeaderRM = await DB("trx_rekam_medis")
      .where("kode_kunjungan", kode_kunjungan)
      .first();

    let id_rekam_medis = existingHeaderRM?.id;

    let resolvedKodeKaryawan = null;
    let resolvedNoSip = "-";

    const targetKaryawanParam = kode_karyawan || existingHeaderRM?.kode_karyawan;
    if (targetKaryawanParam) {
      const karyawanRec = await DB("mst_karyawan")
        .where("kode_karyawan", targetKaryawanParam)
        .orWhere("no_sip", targetKaryawanParam)
        .orWhere("kode_user", targetKaryawanParam)
        .first();

      if (karyawanRec) {
        resolvedKodeKaryawan = karyawanRec.kode_karyawan;
        resolvedNoSip = karyawanRec.no_sip || "-";
      } else {
        resolvedNoSip = targetKaryawanParam;
      }
    }

    if (!existingHeaderRM) {
      const now = formatDateSystem();
      const [insertedHeaderId] = await DB("trx_rekam_medis").insert({
        kode_rekam_medis: `RKM-${Date.now()}`,
        kode_kunjungan,
        kode_antrian_layanan: kode_antrian_layanan || null,
        no_rm: no_rm || "RM-UNKNOWN",
        no_sip: resolvedNoSip,
        kode_karyawan: resolvedKodeKaryawan,
        created_by: username,
        created_at: now,
        updated_by: username,
        updated_at: now,
      });
      id_rekam_medis = insertedHeaderId;
    }

    if (!id_rekam_medis) {
      throw new Error("Gagal memperoleh id_rekam_medis header");
    }

    // Resolve nama_ruangan jika tidak terisi
    let resolvedNamaRuangan = nama_ruangan;
    if (!resolvedNamaRuangan && kode_ruangan) {
      const masterRoom = await DB("mst_ruangan").where("kode_ruangan", kode_ruangan).first();
      if (masterRoom) resolvedNamaRuangan = masterRoom.nama_ruangan;
    }
    resolvedNamaRuangan = resolvedNamaRuangan || "Ruangan Treatment";

    // 2. Extract foto (before/after) & pisahkan field non-foto untuk data_form
    let extractedFotos = [];
    let cleanDataForm = {};

    if (hasil_form && typeof hasil_form === "object") {
      Object.entries(hasil_form).forEach(([key, val]) => {
        if (val && typeof val === "object" && (val.before || val.after)) {
          if (val.before) extractedFotos.push({ tipe: "before", url_foto: val.before });
          if (val.after) extractedFotos.push({ tipe: "after", url_foto: val.after });
        } else if (key === "foto_before" && typeof val === "string" && val) {
          extractedFotos.push({ tipe: "before", url_foto: val });
        } else if (key === "foto_after" && typeof val === "string" && val) {
          extractedFotos.push({ tipe: "after", url_foto: val });
        } else {
          cleanDataForm[key] = val;
        }
      });
    }

    // 3. Cek apakah sudah ada baris `trx_rekam_medis_ruangan` untuk (id_rekam_medis, kode_ruangan)
    const roomCodeParam = kode_ruangan || "RNG-000";

    let existingRoomRM = await DB("trx_rekam_medis_ruangan")
      .where("id_rekam_medis", id_rekam_medis)
      .where("kode_ruangan", roomCodeParam)
      .first();

    if (!existingRoomRM && kode_antrian_layanan) {
      existingRoomRM = await DB("trx_rekam_medis_ruangan")
        .where("kode_antrian_layanan", kode_antrian_layanan)
        .first();
    }

    let id_rekam_medis_ruangan = existingRoomRM?.id;

    // Merge data_form yang ada jika update
    let mergedDataForm = cleanDataForm;
    if (existingRoomRM && existingRoomRM.data_form) {
      let existingFormObj = {};
      try {
        existingFormObj = typeof existingRoomRM.data_form === "string"
          ? JSON.parse(existingRoomRM.data_form)
          : existingRoomRM.data_form;
      } catch (_) {
        existingFormObj = {};
      }
      mergedDataForm = { ...existingFormObj, ...cleanDataForm };
    }

    const resolvedCatatanTindakan = catatan_tindakan !== undefined
      ? catatan_tindakan
      : (cleanDataForm.catatan_tindakan || existingRoomRM?.catatan_tindakan || null);

    const resolvedCatatanPetugas = catatan_petugas !== undefined
      ? catatan_petugas
      : (existingRoomRM?.catatan_petugas || null);

    const resolvedCatatanHasil = catatan_hasil_treatment !== undefined
      ? catatan_hasil_treatment
      : (existingRoomRM?.catatan_hasil_treatment || null);

    if (existingRoomRM) {
      // UPDATE baris ruangan yang sudah ada (OVERWRITE, bukan concat)
      await DB("trx_rekam_medis_ruangan")
        .where("id", existingRoomRM.id)
        .update({
          kode_antrian_layanan: kode_antrian_layanan || existingRoomRM.kode_antrian_layanan,
          nama_ruangan: resolvedNamaRuangan,
          kode_karyawan: kode_karyawan || existingRoomRM.kode_karyawan,
          data_form: JSON.stringify(mergedDataForm),
          catatan_tindakan: resolvedCatatanTindakan,
          catatan_petugas: resolvedCatatanPetugas,
          catatan_hasil_treatment: resolvedCatatanHasil,
          updated_by: username,
          updated_at: new Date(),
        });
    } else {
      // INSERT baris ruangan baru
      const kodeRMR = `RMR-${kode_kunjungan}-${roomCodeParam}-${Date.now().toString().slice(-4)}`;
      const [insertedRoomId] = await DB("trx_rekam_medis_ruangan").insert({
        kode_rekam_medis_ruangan: kodeRMR,
        id_rekam_medis: id_rekam_medis,
        kode_kunjungan: kode_kunjungan,
        kode_antrian_layanan: kode_antrian_layanan || null,
        kode_ruangan: roomCodeParam,
        nama_ruangan: resolvedNamaRuangan,
        kode_karyawan: kode_karyawan || null,
        data_form: JSON.stringify(mergedDataForm),
        catatan_tindakan: resolvedCatatanTindakan,
        catatan_petugas: resolvedCatatanPetugas,
        catatan_hasil_treatment: resolvedCatatanHasil,
        status: "berlangsung",
        created_by: username,
        created_at: new Date(),
        updated_by: username,
        updated_at: new Date(),
      });
      id_rekam_medis_ruangan = insertedRoomId;
    }

    // 4. Simpan/link foto ke trx_rekam_medis_foto dengan id_rekam_medis_ruangan (Upsert per tipe)
    if (id_rekam_medis_ruangan && extractedFotos.length > 0) {
      for (const foto of extractedFotos) {
        const existingFotoSameTipe = await DB("trx_rekam_medis_foto")
          .where("id_rekam_medis_ruangan", id_rekam_medis_ruangan)
          .where("tipe", foto.tipe)
          .first();

        if (existingFotoSameTipe) {
          await DB("trx_rekam_medis_foto")
            .where("id", existingFotoSameTipe.id)
            .update({ url_foto: foto.url_foto });
        } else {
          await DB("trx_rekam_medis_foto").insert({
            id_rekam_medis: id_rekam_medis,
            id_rekam_medis_ruangan: id_rekam_medis_ruangan,
            tipe: foto.tipe,
            url_foto: foto.url_foto,
          });
        }
      }
    }

    return {
      id_rekam_medis,
      id_rekam_medis_ruangan,
      kode_kunjungan,
      kode_ruangan: roomCodeParam,
    };
  } catch (err) {
    console.error("Error in syncRekamMedisPerAntrian:", err);
    throw err;
  }
}
