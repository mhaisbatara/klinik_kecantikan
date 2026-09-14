'use client';

import React from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import { Tag } from 'primereact/tag';
import { Calendar, Clock, User, Sparkles, Building, Info, AlertCircle } from 'lucide-react';
import { RuanganGroup, BookingItemDetail } from '../../components/shared/LayananCard';

interface Props {
  visible: boolean;
  onHide: () => void;
  ruangan: RuanganGroup | null;
  todayDateStr?: string;
  todayDayName?: string;
}

export const DialogSemuaBookingRuangan: React.FC<Props> = ({
  visible,
  onHide,
  ruangan,
  todayDateStr,
  todayDayName,
}) => {
  const bookings: BookingItemDetail[] = React.useMemo(() => {
    if (!ruangan?.daftar_booking_hari_ini) return [];
    // Urutkan secara kronologis berdasarkan jam_booking
    return [...ruangan.daftar_booking_hari_ini].sort((a, b) =>
      (a.jam_booking || '').localeCompare(b.jam_booking || '')
    );
  }, [ruangan]);

  const totalBookings = bookings.length;
  const upcomingCount = bookings.filter((b) => b.is_upcoming).length;

  return (
    <Dialog
      visible={visible}
      onHide={onHide}
      style={{ width: '640px', maxWidth: '95vw' }}
      header={
        <div className="flex align-items-center gap-2">
          <div className="flex align-items-center justify-content-center bg-amber-100 text-amber-700 border-round-lg p-2 flex-shrink-0">
            <Calendar size={20} />
          </div>
          <div>
            <div className="font-bold text-lg text-900 leading-tight">
              Daftar Jadwal Booking Terkonfirmasi Hari Ini
            </div>
            <div className="text-xs text-500 font-normal flex align-items-center gap-1 mt-0.5">
              <Building size={12} className="text-400" />
              <span>{ruangan?.nama_ruangan || 'Ruangan'}</span>
              {(todayDayName || todayDateStr) && (
                <>
                  <span className="text-300">•</span>
                  <span>
                    {todayDayName ? `${todayDayName.toUpperCase()}, ` : ''}
                    {todayDateStr || ''}
                  </span>
                </>
              )}
            </div>
          </div>
        </div>
      }
      footer={
        <div className="flex justify-content-between align-items-center pt-2">
          <div className="text-xs text-600 flex align-items-center gap-1">
            <Info size={14} className="text-amber-600 flex-shrink-0" />
            <span>
              Total <strong>{totalBookings} booking</strong> terdaftar di ruangan ini hari ini
              {upcomingCount > 0 ? ` (${upcomingCount} sesi belum lewat)` : ''}
            </span>
          </div>
          <Button
            label="Tutup"
            icon="pi pi-times"
            className="p-button-secondary p-button-sm px-3 border-round-lg"
            onClick={onHide}
          />
        </div>
      }
    >
      <div className="py-2">
        {/* Info Banner Pemandu Staf */}
        <div className="p-3 mb-3 bg-amber-50 border-round-xl border-1 border-amber-200 flex align-items-start gap-2">
          <AlertCircle size={16} className="text-amber-700 mt-0.5 flex-shrink-0" />
          <div className="text-xs text-amber-900 line-height-2">
            Berikut seluruh pasien yang telah mengonfirmasi reservasi di <strong>{ruangan?.nama_ruangan}</strong> untuk hari ini. Pastikan estimasi tindakan walk-in yang didaftarkan tidak menyebabkan keterlambatan penanganan bagi pasien booking.
          </div>
        </div>

        {/* Empty State */}
        {bookings.length === 0 ? (
          <div className="p-5 text-center surface-50 border-1 surface-border border-round-xl">
            <i className="pi pi-calendar-times text-400 text-3xl mb-2" />
            <div className="text-sm font-bold text-700">Tidak Ada Booking Terkonfirmasi</div>
            <div className="text-xs text-500 mt-1">
              Belum ada pasien yang melakukan reservasi terkonfirmasi di ruangan ini untuk hari ini.
            </div>
          </div>
        ) : (
          <div className="flex flex-column gap-3 pr-1" style={{ maxHeight: '440px', overflowY: 'auto' }}>
            {bookings.map((b, idx) => {
              const isNearestUpcoming = b.is_upcoming && b.jam_booking === ruangan?.jam_booking_terdekat;

              return (
                <div
                  key={b.kode_booking || idx}
                  className={`p-3 border-round-xl border-1 transition-all flex align-items-stretch ${
                    isNearestUpcoming
                      ? 'bg-amber-50/70 border-amber-300 shadow-1'
                      : 'surface-card surface-border hover:surface-50'
                  }`}
                  style={{ gap: '14px' }}
                >
                  {/* Kotak Jam (Kiri, Sejajar Tinggi Penuh) */}
                  <div
                    className={`flex flex-column align-items-center justify-content-center border-1 border-round-lg px-2.5 py-2 text-center flex-shrink-0 align-self-stretch ${
                      isNearestUpcoming
                        ? 'bg-amber-100 text-amber-900 border-amber-300'
                        : b.is_upcoming
                        ? 'bg-blue-50 text-blue-900 border-blue-200'
                        : 'surface-100 text-600 surface-border'
                    }`}
                    style={{ minWidth: '78px', alignSelf: 'stretch' }}
                  >
                    <span className="text-base font-bold leading-none font-mono">
                      {b.jam_booking}
                    </span>
                    <span className="text-[10px] text-500 font-semibold tracking-wider mt-1">
                      WIB
                    </span>
                  </div>

                  {/* Konten Utama (Kanan) */}
                  <div className="flex-1 min-w-0 flex flex-column justify-content-between" style={{ gap: '8px' }}>
                    {/* Baris 1: Identitas Pasien (Kiri) ... Status Badge & Kode Booking (Kanan) */}
                    <div className="flex align-items-center justify-content-between gap-2 flex-wrap">
                      {/* Identitas: Nama Pasien + No. RM */}
                      <div className="flex align-items-center min-w-0" style={{ gap: '8px' }}>
                        <span className="font-bold text-sm text-900 truncate">
                          {b.nama_pasien}
                        </span>
                        {b.no_rm && (
                          <span className="text-[11px] font-mono bg-blue-50 text-blue-700 border-1 border-blue-200 px-2 py-0.5 border-round font-semibold flex-shrink-0">
                            {b.no_rm}
                          </span>
                        )}
                      </div>

                      {/* Status Badge + Kode Booking */}
                      <div className="flex align-items-center flex-shrink-0" style={{ gap: '8px' }}>
                        {isNearestUpcoming ? (
                          <Tag
                            value="Sesi Terdekat"
                            severity="warning"
                            icon="pi pi-clock"
                            className="text-[11px] py-0.5 px-2 font-bold"
                          />
                        ) : b.is_upcoming ? (
                          <Tag
                            value="Akan Datang"
                            severity="info"
                            className="text-[11px] py-0.5 px-2 font-semibold"
                          />
                        ) : (
                          <Tag
                            value="Sesi Lewat"
                            severity="secondary"
                            className="text-[11px] py-0.5 px-2 font-normal"
                          />
                        )}

                        {b.kode_booking && (
                          <span className="text-[11px] font-mono text-500 bg-surface-100 border-1 surface-border px-2 py-0.5 border-round inline-flex align-items-center">
                            <span className="text-400 mr-1">Kode:</span>
                            {b.kode_booking}
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Baris 2: Layanan & Estimasi Durasi */}
                    <div className="flex align-items-center text-xs text-700 flex-wrap" style={{ rowGap: '4px' }}>
                      {/* Item Layanan */}
                      <div className="flex align-items-center font-medium text-800">
                        <Sparkles size={14} className="text-amber-600 flex-shrink-0" style={{ marginRight: '6px' }} />
                        <span className="truncate">{b.layanan_summary || 'Layanan / Paket'}</span>
                      </div>

                      {/* Titik Pemisah Tebal */}
                      <span className="text-400 font-bold" style={{ margin: '0 10px' }}>•</span>

                      {/* Item Estimasi */}
                      <div className="flex align-items-center text-600">
                        <Clock size={14} className="text-blue-600 flex-shrink-0" style={{ marginRight: '6px' }} />
                        <span>
                          Estimasi <strong className="text-800 font-semibold">{b.durasi_menit || 30} menit</strong>
                        </span>
                      </div>
                    </div>

                    {/* Baris 3: Petugas Bertugas */}
                    <div className="flex align-items-center text-xs text-600">
                      <User size={14} className="text-teal-600 flex-shrink-0" style={{ marginRight: '6px' }} />
                      <span>
                        Petugas: <strong className="text-800 font-semibold">{b.nama_petugas || '-'}</strong>
                        {b.jabatan_petugas ? (
                          <span className="text-500 font-normal"> ({b.jabatan_petugas})</span>
                        ) : null}
                      </span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </Dialog>
  );
};
