'use client';

import React, { useRef } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import { Tag } from 'primereact/tag';
import {
  CalendarCheck,
  Printer,
  User,
  Calendar,
  Clock,
  MapPin,
  Stethoscope,
  CreditCard,
  FileText,
  Sparkles,
  UserCheck,
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
      .block { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; margin-bottom: 12px; }
      .row { display: flex; justify-content: space-between; align-items: center; padding: 5px 0; font-size: 13px; }
      .row-border { border-bottom: 1px solid #edf2f7; margin-bottom: 6px; padding-bottom: 6px; }
      .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
      .label { color: #64748b; font-size: 12px; }
      .val { font-weight: 600; color: #0f172a; }
      .badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }
      .badge-purple { background: #f3e8ff; color: #7e22ce; }
      .badge-green { background: #dcfce7; color: #15803d; }
      .badge-blue { background: #e0f2fe; color: #0369a1; }
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
        <div className="flex align-items-center gap-2">
          <CalendarCheck className="text-teal-600" size={22} />
          <span className="font-bold text-lg text-900">Bukti Reservasi Booking</span>
        </div>
      }
      visible={visible}
      style={{ width: '540px', maxWidth: '95vw' }}
      onHide={onHide}
      modal
      contentClassName="p-3"
      footer={
        <div className="flex justify-content-between align-items-center pt-3 border-top-1 surface-border">
          <Button
            type="button"
            label="Cetak Bukti"
            icon={<Printer size={15} className="mr-1.5" />}
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
        <div className="text-center p-3 surface-50 border-1 border-200 border-round-xl mb-3 shadow-none">
          <div className="text-xs text-500 font-bold uppercase tracking-wider">
            KLINIK KECANTIKAN ESTETIKA
          </div>
          <div className="text-2xl sm:text-3xl font-black text-emerald-600 my-1 font-mono tracking-wide">
            {booking.kode_booking}
          </div>
          <div className="text-xs text-500 font-medium">
            Tunjukkan kode ini kepada staf saat kedatangan
          </div>
        </div>

        {/* 2. BLOK A: INFO PASIEN & LAYANAN */}
        <div className="surface-50 border-1 border-200 border-round-xl p-3 mb-3">
          {/* Baris Pasien */}
          <div
            className="flex align-items-center justify-content-between border-bottom-1 surface-border flex-wrap gap-2"
            style={{ paddingBottom: '12px', marginBottom: '12px' }}
          >
            <div className="flex align-items-center text-xs text-500 font-medium" style={{ gap: '8px' }}>
              <User size={14} className="text-400 flex-shrink-0" />
              <span>Pasien</span>
            </div>
            <div className="flex align-items-center gap-2">
              <span className="font-bold text-900 text-sm">{booking.nama_pasien || '-'}</span>
              {booking.no_rm && (
                <span className="px-2 py-0.5 border-round-md bg-teal-50 text-teal-700 border-1 border-teal-200 font-mono font-bold text-xs">
                  {booking.no_rm}
                </span>
              )}
            </div>
          </div>

          {/* Baris Layanan / Paket */}
          <div>
            <div className="flex align-items-center justify-content-between flex-wrap gap-2">
              <div className="flex align-items-center text-xs text-500 font-medium" style={{ gap: '8px' }}>
                <Sparkles size={14} className="text-400 flex-shrink-0" />
                <span>Layanan / Paket</span>
              </div>
              <span className="font-semibold text-900 text-sm text-right">
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

        {/* 3. BLOK B: JADWAL & LOKASI (GRID 2 KOLOM) */}
        <div className="surface-50 border-1 border-200 border-round-xl p-3 mb-3">
          <div className="grid text-sm m-0">
            {/* Tanggal Booking */}
            <div className="col-12 sm:col-6 p-2">
              <div className="flex align-items-center text-xs text-500 mb-1" style={{ gap: '8px' }}>
                <Calendar size={14} className="text-400 flex-shrink-0" />
                <span>Tanggal</span>
              </div>
              <div className="font-bold text-900 text-sm">{booking.tanggal_booking || '-'}</div>
            </div>

            {/* Jam Rencana */}
            <div className="col-12 sm:col-6 p-2">
              <div className="flex align-items-center text-xs text-500 mb-1" style={{ gap: '8px' }}>
                <Clock size={14} className="text-400 flex-shrink-0" />
                <span>Jam Rencana</span>
              </div>
              <div className="font-bold text-emerald-700 text-sm">
                {booking.jam_booking ? `${booking.jam_booking} WIB` : '-'}
              </div>
            </div>

            {/* Ruangan */}
            <div className="col-12 sm:col-6 p-2 pt-3 border-top-1 surface-border">
              <div className="flex align-items-center text-xs text-500 mb-1" style={{ gap: '8px' }}>
                <MapPin size={14} className="text-400 flex-shrink-0" />
                <span>Ruangan</span>
              </div>
              <div className="font-semibold text-800 text-sm">
                {booking.nama_ruangan || booking.kode_ruangan || '-'}
              </div>
            </div>

            {/* Petugas / Dokter */}
            <div className="col-12 sm:col-6 p-2 pt-3 border-top-1 surface-border">
              <div className="flex align-items-center text-xs text-500 mb-1" style={{ gap: '8px' }}>
                <UserCheck size={14} className="text-400 flex-shrink-0" />
                <span>Petugas / Dokter</span>
              </div>
              <div className="font-semibold text-800 text-sm">
                {booking.nama_petugas || '-'}
              </div>
            </div>

            {/* Alur Kunjungan (Badge sejajar tepat di sebelah label) */}
            <div
              className="col-12 p-2 border-top-1 surface-border flex align-items-center flex-wrap"
              style={{ paddingTop: '12px', gap: '12px' }}
            >
              <div className="flex align-items-center text-xs text-500 font-medium" style={{ gap: '8px' }}>
                <Stethoscope size={14} className="text-400 flex-shrink-0" />
                <span>Alur Kunjungan:</span>
              </div>
              <div>
                {Number(booking.butuh_konsul) === 1 ? (
                  <span className="inline-flex align-items-center font-bold text-xs px-2.5 py-1 border-round bg-purple-50 text-purple-700 border-1 border-purple-200">
                    Konsultasi Dokter Dulu
                  </span>
                ) : (
                  <span className="inline-flex align-items-center font-bold text-xs px-2.5 py-1 border-round bg-green-50 text-green-700 border-1 border-green-200">
                    Langsung Tindakan
                  </span>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* 4. BLOK C: PEMBAYARAN & STATUS */}
        <div className="surface-50 border-1 border-200 border-round-xl p-3 mb-3">
          {/* Uang Muka & Metode Bayar Sejajar */}
          <div
            className="grid text-sm m-0 border-bottom-1 surface-border"
            style={{ paddingBottom: '12px', marginBottom: '12px' }}
          >
            <div className="col-6 p-1">
              <div className="flex align-items-center text-xs text-500 mb-1" style={{ gap: '8px' }}>
                <CreditCard size={14} className="text-400 flex-shrink-0" />
                <span>Uang Muka (DP)</span>
              </div>
              <div className="font-bold text-base text-teal-700">
                {formatCurrency(booking.dp_nominal || 0)}
              </div>
            </div>

            <div className="col-6 p-1">
              <div className="flex align-items-center text-xs text-500 mb-1" style={{ gap: '8px' }}>
                <Wallet size={14} className="text-400 flex-shrink-0" />
                <span>Metode Bayar DP</span>
              </div>
              <div className="font-semibold text-800 text-sm">
                {booking.dp_nominal > 0 ? (
                  booking.metode_pembayaran_dp === 'cash'
                    ? 'Tunai (Cash)'
                    : booking.metode_pembayaran_dp === 'transfer'
                    ? 'Transfer Bank'
                    : booking.metode_pembayaran_dp === 'qris'
                    ? 'QRIS'
                    : booking.metode_pembayaran_dp || '-'
                ) : (
                  <span className="text-amber-700 text-xs font-semibold bg-amber-50 px-2 py-0.5 border-round">
                    {booking.alasan_bebas_dp || 'Bebas DP'}
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Status DP & Status Booking: 2 Badge Besar Berdampingan */}
          <div className="grid text-sm m-0">
            <div className="col-6 p-1 flex flex-column gap-1.5">
              <span className="text-xs text-500 font-medium">Status DP</span>
              <div>
                <Tag
                  value={(booking.dp_status || 'belum_bayar').replace(/_/g, ' ').toUpperCase()}
                  severity={
                    booking.dp_status === 'sudah_bayar'
                      ? 'success'
                      : booking.dp_status === 'belum_bayar'
                      ? 'warning'
                      : 'danger'
                  }
                  className="font-bold text-xs px-2.5 py-1"
                />
              </div>
            </div>

            <div className="col-6 p-1 flex flex-column gap-1.5">
              <span className="text-xs text-500 font-medium">Status Booking</span>
              <div>
                <Tag
                  value={(booking.status || 'dikonfirmasi').toUpperCase()}
                  severity={
                    booking.status === 'selesai'
                      ? 'success'
                      : booking.status === 'dikonfirmasi'
                      ? 'info'
                      : booking.status === 'dibatalkan'
                      ? 'danger'
                      : 'secondary'
                  }
                  className="font-bold text-xs px-2.5 py-1"
                />
              </div>
            </div>
          </div>
        </div>

        {/* 5. BANNER CATATAN ALUR / INSTRUKSI */}
        {Number(booking.butuh_konsul) === 1 ? (
          <div className="p-3 bg-purple-50 border-1 border-purple-200 border-round-xl flex align-items-start gap-2.5 text-xs text-purple-900 leading-normal">
            <Info size={16} className="text-purple-600 flex-shrink-0 mt-0.5" style={{ marginRight: '4px' }} />
            <div>
              <strong className="font-bold text-purple-950">Catatan Alur:</strong> Pasien dijadwalkan untuk{' '}
              <strong>Konsultasi Dokter</strong> terlebih dahulu saat check-in di klinik sebelum tindakan treatment. Harap datang 15–20 menit lebih awal.
            </div>
          </div>
        ) : (
          <div className="p-3 bg-blue-50 border-1 border-blue-200 border-round-xl flex align-items-start gap-2.5 text-xs text-blue-900 leading-normal">
            <Info size={16} className="text-blue-600 flex-shrink-0 mt-0.5" style={{ marginRight: '4px' }} />
            <div>
              Harap datang 15 menit sebelum waktu janji temu. Keterlambatan lebih dari 30 menit dapat menyebabkan reservasi dibatalkan otomatis dan uang muka hangus.
            </div>
          </div>
        )}

        {/* 6. CATATAN PASIEN JIKA ADA */}
        {booking.catatan_pasien && (
          <div className="mt-2.5 p-2.5 surface-100 border-1 surface-border border-round-xl flex align-items-start gap-2 text-xs text-700">
            <FileText size={15} className="text-500 flex-shrink-0 mt-0.5" style={{ marginRight: '4px' }} />
            <div>
              <strong className="text-800">Catatan Pasien:</strong> <em>{booking.catatan_pasien}</em>
            </div>
          </div>
        )}
      </div>
    </Dialog>
  );
};

