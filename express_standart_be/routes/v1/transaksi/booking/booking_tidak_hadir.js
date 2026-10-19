/**
 * @copyright (c) 2026 PT Marstech Global (info@marstech.co.id)
 * @project Sistem Klinik
 * @file booking_tidak_hadir.js
 * @description Endpoint untuk menandai booking tidak hadir (manual per-booking atau scan otomatis yang kedaluwarsa)
 *              Mendukung penghangusan uang muka (DP) dan penghangusan 1 sesi paket untuk booking klaim paket.
 *
 * @author Antigravity
 * @created 2026-09-07
 * @updated 2026-10-15
 */

import express from "express";
import DB from "../../../../core/config/knex.js";
import { formatDateSystem } from "../../components/tools/date_tools.js";
import { Logging, ChangesLog } from "../../components/tools/servertool.js";
import { status } from "../../components/tools/general.js";
import { getBranchScope } from "../../components/tools/branch_scope.js";
import { cancelKasirDraftByBooking } from "../../master/kasir/kasir_sync_service.js";

const router = express.Router();

/**
 * Helper untuk memproses penghangusan booking:
 * 1. KASUS 1: Booking Beli Paket Baru (jenis_layanan === 'paket' / jenis_item === 'paket_baru')
 *    - Status booking: 'tidak_hadir'
 *    - DP: status otomatis 'hangus'
 *    - Kepemilikan paket: batal / tidak terbentuk di database (trx_kepemilikan_paket_layanan)
 *    - Kasir: Rp 0 (tidak ada transaksi kasir yang terbentuk)
 * 2. KASUS 2: Booking Klaim Sesi Paket Lanjutan (jenis_item === 'klaim_paket' / memiliki kode_detail_kepemilikan_paket_layanan)
 *    - Status booking: 'tidak_hadir'
 *    - Sesi: Sesi pertama yang tersedia otomatis hangus (sesi_terpakai + 1)
 *    - Riwayat pemakaian: Tercatat di trx_pemakaian_paket_layanan dengan status_pemakaian = 'hangus_no_show'
 *    - Kasir: Rp 0
 */
async function processNoShowBooking(trx, booking, username, nowFormatted, todayYmd, prefixPpl, seqObj) {
  let newDpStatus = booking.dp_status;
  if (booking.dp_status === "sudah_bayar" || parseFloat(booking.dp_nominal || 0) > 0) {
    newDpStatus = "hangus";
  }

  // 1. Update status booking menjadi 'tidak_hadir' & hanguskan DP jika ada
  await trx("trx_booking")
    .where("id", booking.id)
    .update({
      status: "tidak_hadir",
      dp_status: newDpStatus,
      updated_by: username,
      updated_at: nowFormatted,
    });

  // 1b. Batalkan draf kasir yang terikat dengan booking ini (agar tidak ada piutang menggantung)
  await cancelKasirDraftByBooking(trx, booking.kode_booking, username);

  // 2. Ambil detail booking untuk membedakan Kasus 1 vs Kasus 2
  const detailBookingRows = await trx("trx_detail_booking")
    .where("kode_booking", booking.kode_booking);

  let isBeliPaketBaru = booking.jenis_layanan === "paket";
  for (const item of detailBookingRows) {
    if (item.jenis_layanan === "paket" || item.jenis_item === "paket_baru") {
      isBeliPaketBaru = true;
    }
  }

  // --- KASUS 1: BELI PAKET BARU / SESI PERTAMA ---
  // Pasien no-show pada pembelian paket baru: DP hangus, paket batal diterbitkan / tidak terbentuk di DB
  if (isBeliPaketBaru) {
    const existingKpl = await trx("trx_kepemilikan_paket_layanan")
      .where("kode_transaksi", booking.kode_booking)
      .select("kode_kepemilikan_paket_layanan");

    if (existingKpl.length > 0) {
      const kplCodes = existingKpl.map((k) => k.kode_kepemilikan_paket_layanan);
      await trx("trx_detail_kepemilikan_paket_layanan")
        .whereIn("kode_kepemilikan_paket_layanan", kplCodes)
        .delete();
      await trx("trx_kepemilikan_paket_layanan")
        .whereIn("kode_kepemilikan_paket_layanan", kplCodes)
        .delete();
    }

    // Pastikan tidak ada log pemakaian paket yang tercatat untuk booking pembelian baru yang no-show
    await trx("trx_pemakaian_paket_layanan")
      .where("kode_booking", booking.kode_booking)
      .delete();

    return {
      newDpStatus,
      hangusItems: [],
      isBeliPaketBaru: true,
    };
  }

  // --- KASUS 2: KLAIM SESI LANJUTAN (KEDUA, KETIGA, DST.) ---
  // Pasien no-show pada klaim sesi dari paket yang sudah aktif: sesi pertama yang tersedia hangus (+1)
  const hangusItems = [];
  for (const item of detailBookingRows) {
    const isClaim =
      item.jenis_layanan === "klaim_paket" ||
      item.jenis_item === "klaim_paket" ||
      Boolean(item.kode_detail_kepemilikan_paket_layanan);

    if (!isClaim) continue;

    let dkpl = null;
    if (item.kode_detail_kepemilikan_paket_layanan) {
      dkpl = await trx("trx_detail_kepemilikan_paket_layanan")
        .where("kode_detail_kepemilikan_paket_layanan", item.kode_detail_kepemilikan_paket_layanan)
        .forUpdate()
        .first();
    } else if (item.kode_kepemilikan_paket_layanan) {
      dkpl = await trx("trx_detail_kepemilikan_paket_layanan")
        .where("kode_kepemilikan_paket_layanan", item.kode_kepemilikan_paket_layanan)
        .where("kode_layanan", item.kode_layanan)
        .whereRaw("sesi_total - sesi_terpakai > 0")
        .forUpdate()
        .first();
    }

    if (dkpl && dkpl.sesi_terpakai < dkpl.sesi_total) {
      // Sesi pertama yang masih tersedia dihanguskan
      const sesiKe = dkpl.sesi_terpakai + 1;

      // Update sesi_terpakai pada detail kepemilikan
      await trx("trx_detail_kepemilikan_paket_layanan")
        .where("id", dkpl.id)
        .update({
          sesi_terpakai: sesiKe,
          updated_at: nowFormatted,
        });

      // Insert baris log ke trx_pemakaian_paket_layanan
      const cKodePpl = `${prefixPpl}${String(seqObj.nextSeq).padStart(3, "0")}`;
      seqObj.nextSeq++;

      await trx("trx_pemakaian_paket_layanan").insert({
        kode_cabang: booking.kode_cabang || null,
        kode_pemakaian_paket_layanan: cKodePpl,
        kode_detail_kepemilikan_paket_layanan: dkpl.kode_detail_kepemilikan_paket_layanan,
        sesi_ke: sesiKe,
        kode_kunjungan: null,
        kode_booking: booking.kode_booking,
        tanggal_pakai: todayYmd,
        status_pemakaian: "hangus_no_show",
        keterangan: `Sesi hangus karena tidak hadir (No-Show) pada jadwal booking ${booking.kode_booking}`,
        tz: booking.tz || "Asia/Jakarta",
        created_by: username,
        created_at: nowFormatted,
        updated_by: username,
        updated_at: nowFormatted,
      });

      hangusItems.push({
        kode_detail_kepemilikan_paket_layanan: dkpl.kode_detail_kepemilikan_paket_layanan,
        sesi_ke: sesiKe,
      });

      // Cek apakah seluruh detail sesi pada paket sudah habis
      const kplCode = dkpl.kode_kepemilikan_paket_layanan;
      const allDetails = await trx("trx_detail_kepemilikan_paket_layanan")
        .where("kode_kepemilikan_paket_layanan", kplCode)
        .select("sesi_total", "sesi_terpakai");

      const totalRemaining = allDetails.reduce(
        (sum, d) => sum + Math.max(0, parseInt(d.sesi_total || 0, 10) - parseInt(d.sesi_terpakai || 0, 10)),
        0
      );

      if (totalRemaining <= 0) {
        await trx("trx_kepemilikan_paket_layanan")
          .where("kode_kepemilikan_paket_layanan", kplCode)
          .update({
            status: "habis",
            updated_at: nowFormatted,
          });
      }
    }
  }

  return {
    newDpStatus,
    hangusItems,
    isBeliPaketBaru: false,
  };
}

router.post("/", async (req, res) => {
  const { body } = req;
  const oPayload = body || {};
  const username = req?.auth?.username || "system";
  const branchCode = getBranchScope(req, oPayload.kode_cabang);

  try {
    const kodeBooking = (oPayload.kode_booking || "").trim();
    const isAutoScan = oPayload.auto_scan === true || !kodeBooking;

    const nowFormatted = formatDateSystem();
    const now = new Date();
    const todayYmd = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
    const todayStr = todayYmd.replace(/-/g, "");
    const nowTimeStr = `${String(now.getHours()).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}:${String(now.getSeconds()).padStart(2, "0")}`;

    // Ambil konfigurasi toleransi keterlambatan dari tabel config (default: 30 menit)
    const cfgToleransi = await DB("config")
      .where("kode", "toleransi_keterlambatan_menit")
      .first();
    const toleransiMenit = parseInt(cfgToleransi?.keterangan || "30", 10) || 30;

    const prefixPpl = `PPL-${todayStr}-`;

    if (!isAutoScan && kodeBooking) {
      // 1. MODE SINGLE (MANUAL): Tandai 1 booking spesifik dalam database transaction
      let resultData = null;

      await DB.transaction(async (trx) => {
        let singleQuery = trx("trx_booking").where("kode_booking", kodeBooking);
        if (branchCode) singleQuery = singleQuery.where("kode_cabang", branchCode);
        const booking = await singleQuery.forUpdate().first();

        if (!booking) {
          const err = new Error(`Booking ${kodeBooking} tidak ditemukan`);
          err.statusCode = 404;
          throw err;
        }

        // GUARD IDEMPOTENSI: Jika booking sudah 'tidak_hadir', jangan potong sesi lagi
        if (booking.status === "tidak_hadir") {
          resultData = {
            idempotent: true,
            kode_booking: kodeBooking,
            status: "tidak_hadir",
            dp_status: booking.dp_status,
            message: `Booking ${kodeBooking} sudah ditandai tidak hadir sebelumnya (tidak ada pemotongan sesi ganda).`,
          };
          return;
        }

        if (booking.status === "selesai") {
          const err = new Error("Booking sudah selesai (check-in), tidak dapat ditandai tidak hadir");
          err.statusCode = 422;
          throw err;
        }

        if (booking.status === "dibatalkan") {
          const err = new Error("Booking sudah dibatalkan, tidak dapat ditandai tidak hadir");
          err.statusCode = 422;
          throw err;
        }

        if (booking.status !== "dikonfirmasi") {
          const err = new Error(`Booking dengan status '${booking.status}' tidak dapat ditandai tidak hadir`);
          err.statusCode = 422;
          throw err;
        }

        // Cari nomor sequence PPL berikutnya
        const lastPpl = await trx("trx_pemakaian_paket_layanan")
          .where("kode_pemakaian_paket_layanan", "like", `${prefixPpl}%`)
          .orderBy("id", "desc")
          .first();

        let nextSeq = 1;
        if (lastPpl && lastPpl.kode_pemakaian_paket_layanan) {
          const parts = lastPpl.kode_pemakaian_paket_layanan.split("-");
          const num = parseInt(parts[parts.length - 1], 10);
          if (!isNaN(num)) nextSeq = num + 1;
        }
        const seqObj = { nextSeq };

        // Eksekusi penghangusan booking & klaim sesi
        const processResult = await processNoShowBooking(
          trx,
          booking,
          username,
          nowFormatted,
          todayYmd,
          prefixPpl,
          seqObj
        );

        resultData = {
          idempotent: false,
          kode_booking: kodeBooking,
          status: "tidak_hadir",
          dp_status: processResult.newDpStatus,
          is_beli_paket_baru: processResult.isBeliPaketBaru,
          hangus_sesi_items: processResult.hangusItems,
        };

        const logDesc = processResult.isBeliPaketBaru
          ? `Menandai booking ${kodeBooking} tidak hadir (Beli Paket Baru batal diterbitkan, DP ${processResult.newDpStatus})`
          : `Menandai booking ${kodeBooking} tidak hadir (${processResult.hangusItems.length} sesi paket dihanguskan)`;

        await ChangesLog(
          {
            description: logDesc,
            tableName: "trx_booking",
            referenceCode: kodeBooking,
            action: "update",
            dataAfter: {
              kode_booking: kodeBooking,
              status: "tidak_hadir",
              dp_status: processResult.newDpStatus,
              is_beli_paket_baru: processResult.isBeliPaketBaru,
              hangus_sesi_count: processResult.hangusItems.length,
            },
            user: username,
          },
          trx
        );
      });

      if (resultData?.idempotent) {
        return res.status(200).json({
          status: status.SUKSES,
          message: resultData.message,
          datetime: formatDateSystem(),
          data: resultData,
        });
      }

      const dpMsg = resultData.dp_status === "hangus" ? " Uang muka (DP) dinyatakan hangus." : "";
      const sesiMsg =
        resultData.hangus_sesi_items?.length > 0
          ? ` Sebanyak ${resultData.hangus_sesi_items.length} sesi paket klaim dinyatakan hangus.`
          : "";
      const paketBatalMsg = resultData.is_beli_paket_baru
        ? " Kepemilikan paket baru batal diterbitkan."
        : "";

      return res.status(200).json({
        status: status.SUKSES,
        message: `Booking ${kodeBooking} berhasil ditandai tidak hadir.${dpMsg}${sesiMsg}${paketBatalMsg}`,
        datetime: formatDateSystem(),
        data: resultData,
      });
    } else {
      // 2. MODE AUTO SCAN: Scan semua booking berstatus 'dikonfirmasi' yang telah melewati batas toleransi
      const hours = Math.floor(toleransiMenit / 60);
      const mins = toleransiMenit % 60;
      const addTimeStr = `${String(hours).padStart(2, "0")}:${String(mins).padStart(2, "0")}:00`;

      let autoQuery = DB("trx_booking")
        .where("status", "dikonfirmasi")
        .where(function () {
          this.where("tanggal_booking", "<", todayYmd).orWhere(function () {
            this.where("tanggal_booking", todayYmd).whereRaw("ADDTIME(jam_booking, ?) < ?", [
              addTimeStr,
              nowTimeStr,
            ]);
          });
        });

      if (branchCode) autoQuery = autoQuery.where("kode_cabang", branchCode);
      const expiredBookings = await autoQuery.select(
        "id",
        "kode_booking",
        "kode_cabang",
        "dp_status",
        "tanggal_booking",
        "jam_booking",
        "tz"
      );

      if (expiredBookings.length === 0) {
        return res.status(200).json({
          status: status.SUKSES,
          message: "Tidak ada booking kedaluwarsa yang perlu diperbarui",
          datetime: formatDateSystem(),
          data: {
            total_updated: 0,
            updated_codes: [],
          },
        });
      }

      let updatedCount = 0;
      const updatedCodes = [];

      await DB.transaction(async (trx) => {
        // Ambil sequence PPL awal
        const lastPpl = await trx("trx_pemakaian_paket_layanan")
          .where("kode_pemakaian_paket_layanan", "like", `${prefixPpl}%`)
          .orderBy("id", "desc")
          .first();

        let nextSeq = 1;
        if (lastPpl && lastPpl.kode_pemakaian_paket_layanan) {
          const parts = lastPpl.kode_pemakaian_paket_layanan.split("-");
          const num = parseInt(parts[parts.length - 1], 10);
          if (!isNaN(num)) nextSeq = num + 1;
        }
        const seqObj = { nextSeq };

        for (const b of expiredBookings) {
          // Kunci baris booking agar aman dari concurrent scan
          const lockedBooking = await trx("trx_booking")
            .where("id", b.id)
            .where("status", "dikonfirmasi")
            .forUpdate()
            .first();

          if (!lockedBooking) continue;

          const processResult = await processNoShowBooking(
            trx,
            lockedBooking,
            username,
            nowFormatted,
            todayYmd,
            prefixPpl,
            seqObj
          );

          updatedCodes.push({
            kode_booking: lockedBooking.kode_booking,
            dp_status: processResult.newDpStatus,
            is_beli_paket_baru: processResult.isBeliPaketBaru,
            hangus_sesi_count: processResult.hangusItems.length,
          });
          updatedCount++;
        }
      });

      return res.status(200).json({
        status: status.SUKSES,
        message: `Berhasil memperbarui ${updatedCount} booking kedaluwarsa menjadi tidak hadir`,
        datetime: formatDateSystem(),
        data: {
          total_updated: updatedCount,
          updated_codes: updatedCodes,
        },
      });
    }
  } catch (error) {
    const statusCode = error.statusCode || 500;
    const oResult = {
      status: status.BAD_REQUEST,
      message: error.message || "Gagal memproses booking tidak hadir",
      datetime: formatDateSystem(),
    };

    Logging(error, {
      file: "/transaksi/booking/booking_tidak_hadir.js",
      func: "mark_no_show",
      request: oPayload,
      response: oResult,
      user: username,
    });

    return res.status(statusCode).json(oResult);
  }
});

export default router;
