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

const router = express.Router();

/**
 * Helper untuk memproses penghangusan booking dan pemotongan sesi klaim paket
 */
async function processNoShowBooking(trx, booking, username, nowFormatted, todayYmd, prefixPpl, seqObj) {
  const newDpStatus = booking.dp_status === "sudah_bayar" ? "hangus" : booking.dp_status;

  // 1. Update status booking menjadi 'tidak_hadir'
  await trx("trx_booking")
    .where("id", booking.id)
    .update({
      status: "tidak_hadir",
      dp_status: newDpStatus,
      updated_by: username,
      updated_at: nowFormatted,
    });

  // 2. Periksa apakah booking memiliki item klaim paket
  const detailBookingRows = await trx("trx_detail_booking")
    .where("kode_booking", booking.kode_booking);

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
          hangus_sesi_items: processResult.hangusItems,
        };

        await ChangesLog(
          {
            description: `Menandai booking ${kodeBooking} tidak hadir (${processResult.hangusItems.length} sesi paket dihanguskan)`,
            tableName: "trx_booking",
            referenceCode: kodeBooking,
            action: "update",
            dataAfter: {
              kode_booking: kodeBooking,
              status: "tidak_hadir",
              dp_status: processResult.newDpStatus,
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

      return res.status(200).json({
        status: status.SUKSES,
        message: `Booking ${kodeBooking} berhasil ditandai tidak hadir.${dpMsg}${sesiMsg}`,
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
