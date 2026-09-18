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

    const win = window.open('', '', 'height=800,width=850');
    if (!win) return;

    const styles = Array.from(document.querySelectorAll('link[rel="stylesheet"], style'))
      .map((el) => el.outerHTML)
      .join('\n');

    win.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Bukti Reservasi - ${booking.kode_booking || 'Booking'}</title>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          ${styles}
          <style>
            @page {
              size: auto;
              margin: 10mm;
            }
            * {
              -webkit-print-color-adjust: exact !important;
              print-color-adjust: exact !important;
              color-adjust: exact !important;
              box-sizing: border-box !important;
            }
            body {
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif !important;
              padding: 16px !important;
              color: #1e293b !important;
              background: #ffffff !important;
              margin: 0 !important;
            }
            .print-container {
              max-width: 480px;
              margin: 0 auto;
            }
            .surface-50 { background-color: #f8fafc !important; }
            .surface-100 { background-color: #f1f5f9 !important; }
            .border-1 { border: 1px solid #e2e8f0 !important; }
            .border-200 { border-color: #e2e8f0 !important; }
            .border-round-xl { border-radius: 12px !important; }
            .border-round-md { border-radius: 6px !important; }
            .border-round-3xl { border-radius: 24px !important; }
            .border-bottom-1 { border-bottom: 1px solid #e2e8f0 !important; }
            .border-top-1 { border-top: 1px solid #e2e8f0 !important; }
            .surface-border { border-color: #e2e8f0 !important; }
            .flex { display: flex !important; }
            .flex-column { display: flex !important; flex-direction: column !important; }
            .align-items-center { align-items: center !important; }
            .align-items-start { align-items: flex-start !important; }
            .justify-content-between { justify-content: space-between !important; }
            .justify-content-center { justify-content: center !important; }
            .flex-wrap { flex-wrap: wrap !important; }
            .flex-shrink-0 { flex-shrink: 0 !important; }
            .grid { display: flex !important; flex-wrap: wrap !important; margin: 0 !important; }
            .col-6 { width: 50% !important; flex: 0 0 50% !important; max-width: 50% !important; box-sizing: border-box !important; }
            .col-12 { width: 100% !important; flex: 0 0 100% !important; max-width: 100% !important; box-sizing: border-box !important; }
            .p-0 { padding: 0 !important; }
            .pr-2 { padding-right: 8px !important; }
            .pl-2 { padding-left: 8px !important; }
            .p-3 { padding: 12px !important; }
            .p-2\\.5 { padding: 10px !important; }
            .m-0 { margin: 0 !important; }
            .mb-1 { margin-bottom: 4px !important; }
            .mb-1\\.5 { margin-bottom: 6px !important; }
            .mb-3 { margin-bottom: 16px !important; }
            .text-500 { color: #64748b !important; }
            .text-400 { color: #94a3b8 !important; }
            .text-600 { color: #475569 !important; }
            .text-700 { color: #334155 !important; }
            .text-800 { color: #1e293b !important; }
            .text-900 { color: #0f172a !important; }
            .text-emerald-500 { color: #10b981 !important; }
            .text-emerald-600 { color: #059669 !important; }
            .text-teal-700 { color: #0f766e !important; }
            .text-purple-700 { color: #7e22ce !important; }
            .text-purple-900 { color: #581c87 !important; }
            .text-purple-950 { color: #3b0764 !important; }
            .text-blue-900 { color: #1e3a8a !important; }
            .text-amber-700 { color: #b45309 !important; }
            .font-bold { font-weight: 700 !important; }
            .font-black { font-weight: 900 !important; }
            .font-medium { font-weight: 500 !important; }
            .font-semibold { font-weight: 600 !important; }
            .font-mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important; }
            .uppercase { text-transform: uppercase !important; }
            .tracking-wider { letter-spacing: 0.05em !important; }
            .tracking-wide { letter-spacing: 0.025em !important; }
            .bg-emerald-600 { background-color: #059669 !important; }
            .bg-blue-600 { background-color: #2563eb !important; }
            .bg-amber-600 { background-color: #d97706 !important; }
            .bg-red-600 { background-color: #dc2626 !important; }
            .bg-purple-50 { background-color: #faf5ff !important; }
            .bg-blue-50 { background-color: #eff6ff !important; }
            .bg-teal-50 { background-color: #f0fdfa !important; }
            .bg-amber-50 { background-color: #fffbeb !important; }
            .border-purple-200 { border-color: #e9d5ff !important; }
            .border-blue-200 { border-color: #bfdbfe !important; }
            .border-teal-200 { border-color: #99f6e4 !important; }
            .text-white { color: #ffffff !important; }
            svg { display: inline-block !important; vertical-align: middle !important; }
          </style>
        </head>
        <body>
          <div class="print-container">
            ${printContent.innerHTML}
          </div>
        </body>
      </html>
    `);
    win.document.close();
    win.focus();
    setTimeout(() => {
      win.print();
      win.close();
    }, 400);
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


