'use client';

import React, { useRef } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import {
  CalendarCheck,
  Printer,
  User,
  Calendar,
  Clock,
  MapPin,
  FileText,
  Sparkles,
  UserCheck,
  CreditCard,
  Wallet,
  Info,
} from 'lucide-react';

interface Props {
  visible: boolean;
  booking: any;
  onHide: () => void;
}

export const DialogDetailBooking: React.FC<Props> = ({
  visible,
  booking,
  onHide,
}) => {
  const printRef = useRef<HTMLDivElement>(null);

  if (!booking) return null;

  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
    }).format(val || 0);
  };

  const handlePrint = () => {
    const printContent = printRef.current;
    if (!printContent) return;

    const win = window.open('', '', 'height=700,width=800');
    if (!win) return;

    win.document.write('<html><head><title>Bukti Reservasi - ' + booking.kode_booking + '</title>');
    win.document.write('<style>');
    win.document.write(`
      body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 24px; color: #1e293b; background: #fff; }
      .ticket { border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; max-width: 500px; margin: 0 auto; }
      .header { text-align: center; border-bottom: 2px dashed #cbd5e1; padding-bottom: 16px; margin-bottom: 16px; }
      .clinic-name { font-size: 11px; font-weight: bold; color: #64748b; letter-spacing: 1px; text-transform: uppercase; }
      .code { font-size: 26px; font-weight: 800; color: #059669; margin: 6px 0; letter-spacing: 1px; }
      .instruction { font-size: 12px; color: #64748b; }
      .block { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px 16px; margin-bottom: 16px; }
      .row { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; font-size: 13px; }
      .row-border { border-bottom: 1px solid #edf2f7; }
      .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; padding: 8px 0; }
      .label { color: #64748b; font-size: 12px; }
      .val { font-weight: 600; color: #0f172a; }
      .badge { display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 11px; font-weight: bold; }
      .badge-purple { background: #f3e8ff; color: #7e22ce; border: 1px solid #d8b4fe; }
      .badge-green { background: #059669; color: #ffffff; border-radius: 6px; }
      .badge-blue { background: #2563eb; color: #ffffff; border-radius: 6px; }
      .footer { margin-top: 20px; text-align: center; font-size: 11px; color: #94a3b8; border-top: 1px dashed #cbd5e1; padding-top: 12px; }
    `);
    win.document.write('</style></head><body>');
    win.document.write(printContent.innerHTML);
    win.document.write('</body></html>');
    win.document.close();
    win.focus();
    setTimeout(() => {
      win.print();
      win.close();
    }, 300);
  };

  return (
    <Dialog
      header={
        <div className="flex align-items-center gap-2.5">
          <div
            className="border-round-lg bg-emerald-600 text-white flex align-items-center justify-content-center flex-shrink-0"
            style={{ width: '32px', height: '32px' }}
          >
            <CalendarCheck size={18} />
          </div>
          <span className="font-bold text-lg text-900">Bukti Reservasi Booking</span>
        </div>
      }
      visible={visible}
      style={{ width: '520px', maxWidth: '95vw' }}
      onHide={onHide}
      modal
      contentClassName="p-3"
      footer={
        <div className="flex justify-content-between align-items-center pt-3 border-top-1 surface-border">
          <Button
            type="button"
            label="Cetak Bukti"
            icon={<Printer size={15} style={{ marginRight: '8px' }} />}
            className="p-button-outlined p-button-secondary font-semibold text-xs px-3 py-2"
            onClick={handlePrint}
          />
          <Button
            type="button"
            label="Tutup"
            icon="pi pi-times"
            className="font-bold text-xs px-4 py-2 bg-emerald-600 border-emerald-600 hover:bg-emerald-700 text-white shadow-1"
            onClick={onHide}
          />
        </div>
      }
    >
      <div ref={printRef} className="py-1">
        {/* 1. HEADER TIKET RESERVASI */}
        <div
          className="surface-50 border-1 border-200 border-round-xl text-center shadow-none"
          style={{ padding: '16px', marginBottom: '16px' }}
        >
          <div
            className="text-500 font-bold uppercase tracking-wider"
            style={{ fontSize: '11px', letterSpacing: '1px' }}
          >
            KLINIK KECANTIKAN ESTETIKA
          </div>
          <div
            className="font-black text-emerald-500 font-mono tracking-wide"
            style={{ fontSize: '26px', margin: '4px 0 6px 0', fontWeight: 800 }}
          >
            {booking.kode_booking}
          </div>
          <div className="text-500 font-medium" style={{ fontSize: '12px' }}>
            Tunjukkan kode ini kepada staf saat kedatangan
          </div>
        </div>

        {/* 2. BLOK 1: INFO PASIEN & LAYANAN (LABEL KIRI - VALUE KANAN) */}
        <div
          className="surface-50 border-1 border-200 border-round-xl"
          style={{ padding: '4px 16px', marginBottom: '16px' }}
        >
          {/* Baris Pasien */}
          <div
            className="flex align-items-center justify-content-between border-bottom-1 surface-border flex-wrap gap-2"
            style={{ padding: '10px 0' }}
          >
            <div className="flex align-items-center text-500 font-medium" style={{ fontSize: '13px', gap: '8px' }}>
              <User size={15} className="text-400 flex-shrink-0" />
              <span>Pasien</span>
            </div>
            <div className="flex align-items-center gap-2">
              <span className="font-bold text-900" style={{ fontSize: '14px' }}>
                {booking.nama_pasien || '-'}
              </span>
              {booking.no_rm && (
                <span
                  className="px-2 py-0.5 border-round-md bg-teal-50 text-teal-700 dark:bg-teal-950 dark:text-teal-300 border-1 border-teal-200 dark:border-teal-800 font-mono font-bold"
                  style={{ fontSize: '11px' }}
                >
                  {booking.no_rm}
                </span>
              )}
            </div>
          </div>

          {/* Baris Layanan / Paket */}
          <div style={{ padding: '10px 0' }}>
            <div className="flex align-items-center justify-content-between flex-wrap gap-2">
              <div className="flex align-items-center text-500 font-medium" style={{ fontSize: '13px', gap: '8px' }}>
                <Sparkles size={15} className="text-400 flex-shrink-0" />
                <span>Layanan / Paket</span>
              </div>
              <span className="font-bold text-900" style={{ fontSize: '14px' }}>
                {booking.nama_layanan || booking.kode_layanan || '-'}
              </span>
            </div>

            {/* Sub-item jika multi items */}
            {Array.isArray(booking.items) && booking.items.length > 1 && (
              <div className="pl-3 sm:pl-4 mt-2 pt-2 border-top-1 surface-border flex flex-column gap-2">
                {booking.items.map((it: any, idx: number) => {
                  const isKlaim =
                    it.jenis_layanan === 'klaim_paket' ||
                    it.jenis === 'klaim_paket' ||
                    it.jenis_item === 'klaim_paket';
                  return (
                    <div key={idx} className="flex justify-content-between align-items-center text-xs text-600">
                      <span>• {it.nama || it.nama_layanan} {it.durasi_menit ? `(${it.durasi_menit}m)` : ''}</span>
                      <span className="font-semibold">
                        {isKlaim ? (
                          <span className="text-amber-700 font-bold bg-amber-50 px-1.5 py-0.5 border-round">
                            Klaim Paket (Rp 0)
                          </span>
                        ) : (
                          formatCurrency(it.harga_asal ?? it.harga)
                        )}
                      </span>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        </div>

        {/* 3. BLOK 2: JADWAL & LOKASI (LABEL ATAS DENGAN GAP 8PX + VALUE INDENTASI 22PX) */}
        <div
          className="surface-50 border-1 border-200 border-round-xl"
          style={{ padding: '4px 16px', marginBottom: '16px' }}
        >
          {/* Row 1: Tanggal & Jam Rencana */}
          <div className="grid m-0 border-bottom-1 surface-border" style={{ padding: '10px 0' }}>
            <div className="col-6 p-0 pr-2">
              <div className="flex align-items-center text-500 mb-1" style={{ fontSize: '12px', gap: '8px' }}>
                <Calendar size={14} className="text-400 flex-shrink-0" />
                <span>Tanggal</span>
              </div>
              <div className="font-bold text-900" style={{ fontSize: '14px', paddingLeft: '22px' }}>
                {booking.tanggal_booking || '-'}
              </div>
            </div>

            <div className="col-6 p-0 pl-2">
              <div className="flex align-items-center text-500 mb-1" style={{ fontSize: '12px', gap: '8px' }}>
                <Clock size={14} className="text-400 flex-shrink-0" />
                <span>Jam Rencana</span>
              </div>
              <div className="font-bold text-900" style={{ fontSize: '14px', paddingLeft: '22px' }}>
                {booking.jam_booking ? `${booking.jam_booking} WIB` : '-'}
              </div>
            </div>
          </div>

          {/* Row 2: Ruangan & Petugas / Dokter */}
          <div className="grid m-0 border-bottom-1 surface-border" style={{ padding: '10px 0' }}>
            <div className="col-6 p-0 pr-2">
              <div className="flex align-items-center text-500 mb-1" style={{ fontSize: '12px', gap: '8px' }}>
                <MapPin size={14} className="text-400 flex-shrink-0" />
                <span>Ruangan</span>
              </div>
              <div className="font-bold text-900" style={{ fontSize: '14px', paddingLeft: '22px' }}>
                {booking.nama_ruangan || booking.kode_ruangan || '-'}
              </div>
            </div>

            <div className="col-6 p-0 pl-2">
              <div className="flex align-items-center text-500 mb-1" style={{ fontSize: '12px', gap: '8px' }}>
                <UserCheck size={14} className="text-400 flex-shrink-0" />
                <span>Petugas / Dokter</span>
              </div>
              <div className="font-bold text-900" style={{ fontSize: '14px', paddingLeft: '22px' }}>
                {booking.nama_petugas || '-'}
              </div>
            </div>
          </div>

          {/* Row 3: Alur Kunjungan (Simetris: Label Kiri, Badge Ungu Kanan) */}
          <div
            className="flex align-items-center justify-content-between flex-wrap gap-2"
            style={{ padding: '10px 0' }}
          >
            <div className="flex align-items-center text-500 font-medium" style={{ fontSize: '13px', gap: '8px' }}>
              <Clock size={14} className="text-400 flex-shrink-0" />
              <span>Alur Kunjungan</span>
            </div>
            <div>
              {Number(booking.butuh_konsul) === 1 ? (
                <span
                  className="inline-flex align-items-center font-bold px-3 py-1 border-round-3xl bg-purple-50 text-purple-700 dark:bg-purple-950 dark:text-purple-300 border-1 border-purple-200 dark:border-purple-800"
                  style={{ fontSize: '12px' }}
                >
                  Konsultasi Dokter Dulu
                </span>
              ) : (
                <span
                  className="inline-flex align-items-center font-bold px-3 py-1 border-round-3xl bg-green-50 text-green-700 dark:bg-green-950 dark:text-green-300 border-1 border-green-200 dark:border-green-800"
                  style={{ fontSize: '12px' }}
                >
                  Langsung Tindakan
                </span>
              )}
            </div>
          </div>
        </div>

        {/* 4. BLOK 3: PEMBAYARAN & STATUS (2 KOLOM SEJAJAR) */}
        <div
          className="surface-50 border-1 border-200 border-round-xl"
          style={{ padding: '4px 16px', marginBottom: '16px' }}
        >
          {/* Row 1: Uang Muka & Metode Bayar DP */}
          <div className="grid m-0 border-bottom-1 surface-border" style={{ padding: '10px 0' }}>
            <div className="col-6 p-0 pr-2">
              <div className="flex align-items-center text-500 mb-1" style={{ fontSize: '12px', gap: '8px' }}>
                <CreditCard size={14} className="text-400 flex-shrink-0" />
                <span>Uang Muka (DP)</span>
              </div>
              <div
                className="font-bold text-emerald-500"
                style={{ fontSize: '14px', paddingLeft: '22px' }}
              >
                {formatCurrency(booking.dp_nominal || 0)}
              </div>
            </div>

            <div className="col-6 p-0 pl-2">
              <div className="flex align-items-center text-500 mb-1" style={{ fontSize: '12px', gap: '8px' }}>
                <Wallet size={14} className="text-400 flex-shrink-0" />
                <span>Metode Bayar DP</span>
              </div>
              <div className="font-bold text-900" style={{ fontSize: '14px', paddingLeft: '22px' }}>
                {booking.dp_nominal > 0 ? (
                  booking.metode_pembayaran_dp === 'cash'
                    ? 'Tunai (Cash)'
                    : booking.metode_pembayaran_dp === 'transfer'
                    ? 'Transfer Bank'
                    : booking.metode_pembayaran_dp === 'qris'
                    ? 'QRIS'
                    : booking.metode_pembayaran_dp || '-'
                ) : (
                  <span className="text-amber-700 dark:text-amber-300 text-xs font-semibold bg-amber-50 dark:bg-amber-950 px-2 py-0.5 border-round">
                    {booking.alasan_bebas_dp || 'Bebas DP'}
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Row 2: Status DP & Status Booking (2 Kolom Sejajar) */}
          <div className="grid m-0" style={{ padding: '10px 0' }}>
            <div className="col-6 p-0 pr-2">
              <div className="text-500 font-medium mb-1.5" style={{ fontSize: '12px' }}>
                Status DP
              </div>
              <div>
                <span
                  className={`inline-block font-bold text-white px-3 py-1.5 border-round-md tracking-wider uppercase ${
                    booking.dp_status === 'sudah_bayar'
                      ? 'bg-emerald-600'
                      : booking.dp_status === 'belum_bayar'
                      ? 'bg-amber-600'
                      : 'bg-red-600'
                  }`}
                  style={{ fontSize: '11px', fontWeight: 800 }}
                >
                  {(booking.dp_status || 'belum_bayar').replace(/_/g, ' ').toUpperCase()}
                </span>
              </div>
            </div>

            <div className="col-6 p-0 pl-2">
              <div className="text-500 font-medium mb-1.5" style={{ fontSize: '12px' }}>
                Status Booking
              </div>
              <div>
                <span
                  className={`inline-block font-bold text-white px-3 py-1.5 border-round-md tracking-wider uppercase ${
                    booking.status === 'selesai'
                      ? 'bg-emerald-600'
                      : booking.status === 'dikonfirmasi'
                      ? 'bg-blue-600'
                      : booking.status === 'dibatalkan'
                      ? 'bg-red-600'
                      : 'bg-gray-600'
                  }`}
                  style={{ fontSize: '11px', fontWeight: 800 }}
                >
                  {(booking.status || 'dikonfirmasi').toUpperCase()}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* 5. BANNER CATATAN ALUR / INSTRUKSI */}
        {Number(booking.butuh_konsul) === 1 ? (
          <div
            className="p-3 bg-purple-50 dark:bg-purple-950 dark:bg-opacity-30 border-1 border-purple-200 dark:border-purple-800 border-round-xl flex align-items-start gap-2.5 text-xs text-purple-900 dark:text-purple-200 leading-normal"
            style={{ marginBottom: '12px' }}
          >
            <Info size={16} className="text-purple-600 dark:text-purple-400 flex-shrink-0 mt-0.5" />
            <div>
              <strong className="font-bold text-purple-950 dark:text-purple-100">Catatan Alur:</strong> Pasien dijadwalkan untuk{' '}
              <strong>Konsultasi Dokter</strong> terlebih dahulu saat check-in di klinik sebelum tindakan treatment. Harap datang 15–20 menit lebih awal.
            </div>
          </div>
        ) : (
          <div
            className="p-3 bg-blue-50 dark:bg-blue-950 dark:bg-opacity-30 border-1 border-blue-200 dark:border-blue-800 border-round-xl flex align-items-start gap-2.5 text-xs text-blue-900 dark:text-blue-200 leading-normal"
            style={{ marginBottom: '12px' }}
          >
            <Info size={16} className="text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5" />
            <div>
              Harap datang 15 menit sebelum waktu janji temu. Keterlambatan lebih dari 30 menit dapat menyebabkan reservasi dibatalkan otomatis dan uang muka hangus.
            </div>
          </div>
        )}

        {/* 6. CATATAN PASIEN JIKA ADA */}
        {booking.catatan_pasien && (
          <div className="p-2.5 surface-100 border-1 surface-border border-round-xl flex align-items-start gap-2 text-xs text-700 dark:text-300">
            <FileText size={15} className="text-500 flex-shrink-0 mt-0.5" />
            <div>
              <strong className="text-800 dark:text-100">Catatan Pasien:</strong> <em>{booking.catatan_pasien}</em>
            </div>
          </div>
        )}
      </div>
    </Dialog>
  );
};


