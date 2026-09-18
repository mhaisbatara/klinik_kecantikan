'use client';

import React, { useRef } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';

const formatRupiah = (val: number) =>
  new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(val || 0);

const METODE_LABEL: Record<string, string> = {
  tunai: '💵 Tunai (Cash)',
  cash: '💵 Tunai (Cash)',
  transfer: '🏦 Transfer Bank',
  qris: '📱 QRIS',
  debit: '💳 Debit',
  kredit: '💳 Kredit',
};

const getPrinterSettings = () => {
  const defaults = {
    paperSize: '58mm',
    headerAddress: 'Jl. Utama Klinik Kecantikan No. 88, Telp: (021) 555-0199',
    footerMessage: 'Terima kasih atas kunjungan Anda!\nSemoga lekas sembuh & cantik selalu 🌸',
  };
  if (typeof window === 'undefined') return defaults;
  try {
    const raw = localStorage.getItem('kasir_printer_settings');
    if (!raw) return defaults;
    return { ...defaults, ...JSON.parse(raw) };
  } catch {
    return defaults;
  }
};

const formatTanggalIndo = (tanggalStr?: string) => {
  if (!tanggalStr) return '-';
  try {
    const d = new Date(tanggalStr);
    if (isNaN(d.getTime())) return tanggalStr;
    return d.toLocaleDateString('id-ID', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
  } catch {
    return tanggalStr;
  }
};

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

  const printerSettings = getPrinterSettings();
  const paperWidthPx =
    printerSettings.paperSize === '58mm'
      ? '280px'
      : printerSettings.paperSize === '80mm'
      ? '340px'
      : '100%';

  const handlePrint = () => {
    const el = printRef.current;
    if (!el) return;

    const styleTags = Array.from(document.querySelectorAll('style, link[rel="stylesheet"]'))
      .map((s) => s.outerHTML)
      .join('\n');

    const printWindow = window.open('', '_blank', 'width=450,height=750');
    if (!printWindow) return;

    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Struk Booking ${booking.kode_booking || ''}</title>
          ${styleTags}
          <style>
            @page { size: auto; margin: 0; }
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
              font-family: 'Courier New', Courier, monospace;
              font-size: 12px;
              color: #1e293b;
              background: #ffffff !important;
              padding: 12px;
            }
            .receipt-print-wrapper {
              max-width: ${paperWidthPx};
              margin: 0 auto;
            }
            .receipt-print-wrapper > div {
              box-shadow: none !important;
              border: none !important;
              padding: 0 !important;
            }
            .flex { display: flex !important; }
            .flex-column { flex-direction: column !important; }
            .justify-content-between { justify-content: space-between !important; }
            .align-items-center { align-items: center !important; }
            .font-bold { font-weight: 700 !important; }
            .font-black { font-weight: 900 !important; }
            .font-semibold { font-weight: 600 !important; }
            .text-center { text-align: center !important; }
            .text-teal-700 { color: #0f766e !important; }
            .text-slate-500 { color: #64748b !important; }
            .text-slate-600 { color: #475569 !important; }
            .text-slate-800 { color: #1e293b !important; }
            .text-slate-900 { color: #0f172a !important; }
            .border-top-1 { border-top: 1px solid #cbd5e1 !important; }
            .border-dashed { border-top: 1px dashed #94a3b8 !important; }
            .my-2 { margin-top: 8px !important; margin-bottom: 8px !important; }
            .mb-1 { margin-bottom: 4px !important; }
            .mb-2 { margin-bottom: 8px !important; }
            .mb-3 { margin-bottom: 12px !important; }
          </style>
        </head>
        <body>
          <div class="receipt-print-wrapper">
            ${el.innerHTML}
          </div>
        </body>
      </html>
    `);
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => {
      printWindow.print();
      printWindow.close();
    }, 300);
  };

  // Calculate items and total
  const hasItems = Array.isArray(booking.items) && booking.items.length > 0;
  const items = hasItems
    ? booking.items
    : [
        {
          nama: booking.nama_layanan || booking.kode_layanan || 'Treatment / Layanan',
          qty: 1,
          harga_asal: booking.dp_nominal || 0,
          harga: booking.dp_nominal || 0,
          subtotal: booking.dp_nominal || 0,
        },
      ];

  const subtotal = items.reduce(
    (acc: number, item: any) =>
      acc + (item.subtotal ?? (item.harga_asal ?? item.harga ?? 0) * (item.qty ?? 1)),
    0
  );

  const totalBayar = booking.dp_nominal ?? subtotal;

  return (
    <Dialog
      visible={visible}
      onHide={onHide}
      showHeader={false}
      style={{ width: '460px', borderRadius: '20px', overflow: 'hidden' }}
      contentStyle={{ padding: 0, borderRadius: '20px' }}
    >
      {/* Top Banner Header */}
      <div
        style={{
          background: '#0d9488',
          padding: '24px 16px',
          textAlign: 'center',
          color: '#ffffff',
          position: 'relative',
        }}
      >
        <button
          onClick={onHide}
          style={{
            position: 'absolute',
            top: '12px',
            right: '12px',
            background: 'transparent',
            border: 'none',
            color: '#ffffff',
            opacity: 0.8,
            cursor: 'pointer',
            padding: '4px 8px',
            fontSize: '18px',
            lineHeight: 1,
          }}
          title="Tutup Modal"
        >
          <i className="pi pi-times" />
        </button>

        <div
          style={{
            width: '52px',
            height: '52px',
            borderRadius: '50%',
            background: 'rgba(255, 255, 255, 0.2)',
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 10px',
          }}
        >
          <i className="pi pi-check-circle text-white" style={{ fontSize: '28px' }} />
        </div>
        <h3 style={{ fontSize: '20px', fontWeight: 900, margin: '0 0 4px 0', color: '#ffffff' }}>
          Bukti Reservasi Booking
        </h3>
        <p style={{ fontSize: '13px', margin: 0, opacity: 0.85, fontFamily: 'monospace' }}>
          {booking.kode_booking}
        </p>
      </div>

      {/* Paper Receipt Preview Body */}
      <div className="p-4 surface-ground max-h-[60vh] overflow-y-auto">
        <div
          ref={printRef}
          style={{ maxWidth: paperWidthPx, margin: '0 auto' }}
          className="bg-white p-4 border-round-xl border-1 surface-border shadow-2 text-slate-800 text-xs font-mono"
        >
          {/* Receipt Brand Header */}
          <div className="text-center mb-3">
            <div className="text-base font-black text-slate-900 tracking-tight">🌸 Klinik Kecantikan</div>
            {printerSettings.headerAddress && (
              <div className="text-[10px] text-slate-500 font-semibold mt-0.5">
                {printerSettings.headerAddress}
              </div>
            )}
            <div className="text-[11px] text-slate-500 font-semibold uppercase tracking-wider mt-1">
              STRUK TRANSAKSI
            </div>
          </div>

          <div className="border-top-1 border-dashed surface-border my-2" />

          {/* Meta Info */}
          <div className="flex justify-content-between mb-1">
            <span className="text-slate-500">No. Transaksi</span>
            <span className="font-bold text-slate-900">{booking.kode_booking}</span>
          </div>
          <div className="flex justify-content-between mb-1">
            <span className="text-slate-500">Pasien</span>
            <span className="font-bold text-slate-900">{booking.nama_pasien || '-'}</span>
          </div>
          <div className="flex justify-content-between mb-1">
            <span className="text-slate-500">No. RM</span>
            <span className="font-bold text-slate-900">{booking.no_rm || '-'}</span>
          </div>
          <div className="flex justify-content-between mb-1">
            <span className="text-slate-500">Tanggal</span>
            <span className="font-semibold text-slate-800">
              {formatTanggalIndo(booking.tanggal_booking)}
            </span>
          </div>
          <div className="flex justify-content-between mb-1">
            <span className="text-slate-500">Jam</span>
            <span className="font-semibold text-slate-800">
              {booking.jam_booking ? `${booking.jam_booking} WIB` : '-'}
            </span>
          </div>
          {booking.nama_ruangan && (
            <div className="flex justify-content-between mb-1">
              <span className="text-slate-500">Ruangan</span>
              <span className="font-semibold text-slate-800">{booking.nama_ruangan}</span>
            </div>
          )}
          {booking.nama_petugas && (
            <div className="flex justify-content-between mb-1">
              <span className="text-slate-500">Petugas/Dokter</span>
              <span className="font-semibold text-slate-800">{booking.nama_petugas}</span>
            </div>
          )}
          {booking.butuh_konsul !== undefined && (
            <div className="flex justify-content-between mb-1">
              <span className="text-slate-500">Alur</span>
              <span className="font-semibold text-slate-800">
                {Number(booking.butuh_konsul) === 1 ? 'Konsultasi Dokter Dulu' : 'Langsung Tindakan'}
              </span>
            </div>
          )}

          <div className="border-top-1 border-dashed surface-border my-2" />

          {/* Item Details */}
          <div className="flex flex-column gap-2.5 my-2">
            {items.map((item: any, i: number) => {
              const itemHarga = item.harga_asal ?? item.harga ?? booking.dp_nominal ?? 0;
              const itemQty = item.qty ?? 1;
              const itemSub = item.subtotal ?? itemHarga * itemQty;
              return (
                <div key={i} className="flex flex-column gap-0.5">
                  <div className="font-bold text-slate-900 flex justify-content-between">
                    <span>{item.nama || item.nama_layanan}</span>
                  </div>
                  <div className="flex justify-content-between text-slate-600 text-[11px]">
                    <span>
                      {itemQty} × {formatRupiah(itemHarga)}
                    </span>
                    <span className="font-bold text-slate-900">{formatRupiah(itemSub)}</span>
                  </div>
                </div>
              );
            })}
          </div>

          <div className="border-top-1 border-dashed surface-border my-2" />

          {/* Financial Totals */}
          <div className="flex justify-content-between mb-1">
            <span className="text-slate-600">Subtotal</span>
            <span className="font-bold text-slate-800">{formatRupiah(subtotal)}</span>
          </div>

          <div className="flex justify-content-between pt-1 border-top-1 border-slate-200 mt-1 mb-2 font-bold text-sm text-slate-900">
            <span>Total Bayar</span>
            <span className="text-teal-700">{formatRupiah(totalBayar)}</span>
          </div>

          <div className="border-top-1 border-dashed surface-border my-2" />

          {/* Payment Method details */}
          <div className="flex justify-content-between mb-1">
            <span className="text-slate-600">Metode</span>
            <span className="font-bold text-slate-900">
              {METODE_LABEL[booking.metode_pembayaran_dp] ||
                (booking.dp_nominal === 0
                  ? booking.alasan_bebas_dp || 'Bebas DP'
                  : booking.metode_pembayaran_dp || 'Tunai (Cash)')}
            </span>
          </div>

          {/* Lunas / Status Pill Badge */}
          <div className="my-3 text-center py-1.5 px-3 border-round-3xl border-2 border-slate-700 text-slate-800 font-bold text-xs tracking-wider uppercase">
            ✓ {booking.dp_status === 'sudah_bayar' ? 'LUNAS' : (booking.status || 'DIKONFIRMASI').toUpperCase()}
          </div>

          {/* Footer message */}
          <div className="text-center text-[11px] text-slate-500 line-height-2 mt-2 whitespace-pre-line">
            {printerSettings.footerMessage ||
              'Terima kasih atas kunjungan Anda!\nSemoga lekas sembuh & cantik selalu 🌸'}
          </div>
        </div>
      </div>

      {/* Modal Actions Footer */}
      <div className="p-3 bg-white border-top-1 surface-border flex gap-2">
        <Button
          label="Cetak Struk"
          icon="pi pi-print"
          onClick={handlePrint}
          className="flex-1 font-bold text-xs bg-teal-600 hover:bg-teal-700 border-none border-round-lg text-white shadow-2 py-2.5"
        />
        <Button
          label="Tutup"
          icon="pi pi-times"
          outlined
          severity="secondary"
          onClick={onHide}
          className="flex-1 font-bold text-xs border-round-lg py-2.5"
        />
      </div>
    </Dialog>
  );
};



