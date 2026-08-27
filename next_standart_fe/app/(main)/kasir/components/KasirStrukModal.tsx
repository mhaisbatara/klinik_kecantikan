'use client';

import React, { useRef } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import type { BayarResult, CartItem } from '../page';

const formatRupiah = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(val || 0);

const METODE_LABEL: Record<string, string> = {
  tunai: '💵 Tunai',
  debit: '💳 Debit',
  kredit: '💳 Kredit',
  qris: '📱 QRIS',
  transfer: '🏦 Transfer',
};

interface KasirStrukModalProps {
  visible: boolean;
  result: BayarResult | null;
  onHide: () => void;
}

export const KasirStrukModal: React.FC<KasirStrukModalProps> = ({ visible, result, onHide }) => {
  const printRef = useRef<HTMLDivElement>(null);

  const handlePrint = () => {
    const el = printRef.current;
    if (!el) return;
    const printWindow = window.open('', '_blank', 'width=400,height=700');
    if (!printWindow) return;
    printWindow.document.write(`
      <html>
        <head>
          <title>Struk Transaksi ${result?.kode_transaksi}</title>
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Courier New', monospace; font-size: 12px; padding: 10px; background: white; }
            .title { text-align: center; font-size: 16px; font-weight: 900; margin-bottom: 4px; }
            .sub { text-align: center; font-size: 11px; color: #555; margin-bottom: 12px; }
            .divider { border-top: 1px dashed #999; margin: 8px 0; }
            .row { display: flex; justify-content: space-between; margin-bottom: 4px; }
            .row .label { color: #555; }
            .row .value { font-weight: 700; text-align: right; }
            .item { margin-bottom: 6px; }
            .item-name { font-weight: 700; }
            .item-detail { color: #666; font-size: 11px; }
            .total { font-size: 14px; font-weight: 900; }
            .lunas { text-align: center; font-size: 18px; font-weight: 900; color: green; margin: 8px 0; }
            .thanks { text-align: center; font-size: 11px; color: #555; margin-top: 10px; }
          </style>
        </head>
        <body>${el.innerHTML}</body>
      </html>
    `);
    printWindow.document.close();
    printWindow.focus();
    printWindow.print();
    printWindow.close();
  };

  if (!result) return null;

  const now = new Date();
  const tanggalStr = now.toLocaleDateString('id-ID', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' });
  const jamStr = now.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit', second: '2-digit' });

  return (
    <Dialog
      visible={visible}
      onHide={onHide}
      header={null}
      style={{ width: '440px', borderRadius: '16px', overflow: 'hidden' }}
      contentStyle={{ padding: 0 }}
    >
      {/* Header modal */}
      <div style={{ background: 'linear-gradient(135deg,#0d9488,#059669)', padding: '24px', textAlign: 'center' }}>
        <div style={{ width: '56px', height: '56px', borderRadius: '50%', background: 'rgba(255,255,255,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 12px' }}>
          <i className="pi pi-check-circle text-white" style={{ fontSize: '28px' }} />
        </div>
        <div style={{ fontSize: '20px', fontWeight: 900, color: '#ffffff', marginBottom: '4px' }}>Pembayaran Berhasil!</div>
        <div style={{ fontSize: '13px', color: 'rgba(255,255,255,0.8)' }}>{result.kode_transaksi}</div>
      </div>

      {/* Struk printable */}
      <div style={{ padding: '20px 24px', maxHeight: '55vh', overflowY: 'auto' }}>
        <div ref={printRef}>
          <div className="title">🌸 Klinik Kecantikan</div>
          <div className="sub">Struk Transaksi</div>

          <div className="divider" />

          <div className="row"><span className="label">No. Transaksi</span><span className="value">{result.kode_transaksi}</span></div>
          <div className="row"><span className="label">Pasien</span><span className="value">{result.nama_pasien}</span></div>
          <div className="row"><span className="label">No. RM</span><span className="value">{result.no_rm}</span></div>
          <div className="row"><span className="label">Tanggal</span><span className="value">{tanggalStr}</span></div>
          <div className="row"><span className="label">Jam</span><span className="value">{jamStr}</span></div>

          <div className="divider" />

          {(result.items || []).map((item: CartItem, i: number) => (
            <div key={i} className="item">
              <div className="item-name">{item.nama} {item.is_promo ? '🔥' : ''}</div>
              <div className="item-detail">
                {item.qty} × {formatRupiah(item.harga_satuan)} = <strong>{formatRupiah(item.subtotal)}</strong>
              </div>
            </div>
          ))}

          <div className="divider" />

          <div className="row"><span className="label">Subtotal</span><span className="value">{formatRupiah(result.total_bayar + (result.total_diskon || 0))}</span></div>
          {result.total_diskon != null && result.total_diskon > 0 && (
            <div className="row" style={{ color: '#e11d48' }}>
              <span className="label">Diskon {result.nama_promo ? `(${result.nama_promo})` : ''}</span>
              <span className="value">- {formatRupiah(result.total_diskon)}</span>
            </div>
          )}
          <div className="row total">
            <span>Total Bayar</span>
            <span>{formatRupiah(result.total_bayar)}</span>
          </div>

          <div className="divider" />

          <div className="row"><span className="label">Metode</span><span className="value">{METODE_LABEL[result.metode_bayar] || result.metode_bayar}</span></div>
          {result.metode_bayar === 'tunai' && (
            <>
              <div className="row"><span className="label">Dibayar</span><span className="value">{formatRupiah(result.nominal_bayar)}</span></div>
              <div className="row"><span className="label">Kembalian</span><span className="value">{formatRupiah(result.kembalian)}</span></div>
            </>
          )}

          <div className="lunas">✓ LUNAS</div>
          <div className="thanks">Terima kasih atas kunjungan Anda!<br />Semoga lekas sembuh &amp; cantik selalu 🌸</div>
        </div>
      </div>

      {/* Actions */}
      <div style={{ padding: '12px 24px 20px', display: 'flex', gap: '10px', borderTop: '1px solid #f1f5f9' }}>
        <Button
          label="Cetak Struk"
          icon="pi pi-print"
          className="flex-1"
          onClick={handlePrint}
          style={{ background: 'linear-gradient(135deg,#0d9488,#059669)', border: 'none', fontWeight: 700 }}
        />
        <Button
          label="Tutup"
          icon="pi pi-times"
          className="p-button-outlined p-button-secondary flex-1"
          onClick={onHide}
          style={{ fontWeight: 700 }}
        />
      </div>
    </Dialog>
  );
};
