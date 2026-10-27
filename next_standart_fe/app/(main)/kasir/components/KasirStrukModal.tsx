'use client';

import React, { useRef, useState, useEffect } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import type { BayarResult, CartItem } from '../page';
import { getStoredPrinterSettings } from './KasirPrinterModal';
import { useConfig } from '@/layout/context/configcontext';

const formatRupiah = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(val || 0);

const formatAngka = (val: number) =>
  new Intl.NumberFormat('id-ID', { minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(val || 0);

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
  const printerSettings = getStoredPrinterSettings();
  const { config } = useConfig();
  const [logoError, setLogoError] = useState(false);

  // Header struk: Mengikuti format kop institusi (Nama Induk -> Nama Unit/Cabang -> Alamat -> No. Telepon)
  const clinicName = config?.msNamaPerusahaan?.trim() || 'Klinik Kecantikan';
  const branchName = (result?.nama_cabang && result.nama_cabang.trim() !== '' && result.nama_cabang !== 'null' && result.nama_cabang !== 'undefined')
    ? result.nama_cabang.trim()
    : '';
  const clinicAddress = (result?.alamat_cabang && result.alamat_cabang.trim() !== '' && result.alamat_cabang !== 'null' && result.alamat_cabang !== 'undefined')
    ? result.alamat_cabang.trim()
    : (config?.msAlamatPerusahaan?.trim() || printerSettings.headerAddress?.trim() || '');
  const rawBranchPhone = (result?.no_telp_cabang && result.no_telp_cabang.trim() !== '' && result.no_telp_cabang !== 'null' && result.no_telp_cabang !== 'undefined')
    ? result.no_telp_cabang.trim()
    : (config?.msTeleponPerusahaan?.trim() || '');
  const clinicPhone = rawBranchPhone;
  const logoUrl = config?.msLogoPerusahaan?.trim() || '';

  const hasDistinctBranch = Boolean(
    branchName &&
    branchName.trim() !== '' &&
    branchName.trim().toLowerCase() !== clinicName.trim().toLowerCase()
  );

  const isExplicitDpItem = (result?.items || []).some((item) =>
    item.jenis_diskon === 'dp_booking' ||
    (item.nama || '').toLowerCase().includes('uang muka') ||
    (item.nama || '').toLowerCase().includes('(dp)')
  );

  const isDpTransaction = Boolean(
    isExplicitDpItem ||
    (!result?.kode_kunjungan && result?.is_dp_booking) ||
    (!result?.kode_kunjungan && result?.kode_booking && (result.total_bayar || 0) > 0 && !result?.items?.some(it => it.is_klaim || it.is_klaim_paket || it.jenis_diskon === 'klaim_paket' || (it.nama_promo || '').toLowerCase().includes('klaim')))
  );

  const isKlaimTransaction = Boolean(
    !isDpTransaction &&
    (result?.items || []).some((item) =>
      item.is_klaim ||
      item.is_klaim_paket ||
      (item.jenis as string) === 'klaim_paket' ||
      item.jenis_diskon === 'klaim_paket' ||
      (item.nama || '').toLowerCase().includes('klaim') ||
      (item.nama_promo || '').toLowerCase().includes('klaim') ||
      (Number(item.harga_satuan || 0) === 0 && Number(item.subtotal || 0) === 0 && !item.is_free_include && item.jenis_diskon !== 'include_treatment')
    )
  );

  // Footer message: bersihkan dari emoji dan gunakan dari profil klinik sistem jika ada
  const rawFooter = config?.msCatatanKasir?.trim() || printerSettings.footerMessage || 'Terima kasih atas kunjungan Anda';
  const footerMsg = rawFooter.replace(/[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/gu, '').trim();

  const paperWidthPx =
    printerSettings.paperSize === '58mm' ? '280px' : printerSettings.paperSize === '80mm' ? '340px' : '100%';

  useEffect(() => {
    if (visible) {
      setLogoError(false);
    }
  }, [visible, logoUrl]);

  React.useEffect(() => {
    if (visible && result && printerSettings.autoPrint) {
      const timer = setTimeout(() => {
        handlePrint();
      }, 500);
      return () => clearTimeout(timer);
    }
  }, [visible, result]);

  const handlePrint = () => {
    const el = printRef.current;
    if (!el) return;

    // Ambil semua tag style & link stylesheet agar CSS PrimeFlex/Tailwind terbawa ke popup cetak
    const styleTags = Array.from(document.querySelectorAll('style, link[rel="stylesheet"]'))
      .map((s) => s.outerHTML)
      .join('\n');

    const printWindow = window.open('', '_blank', 'width=450,height=750');
    if (!printWindow) return;

    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>${isDpTransaction ? 'Struk Pembayaran DP' : (isKlaimTransaction && (result?.total_bayar || 0) === 0 ? 'Struk Klaim Sesi' : 'Struk Transaksi')} ${result?.kode_transaksi}</title>
          ${styleTags}
          <style>
            @page { size: auto; margin: 0; }
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
              font-family: 'Courier New', Courier, monospace;
              font-size: 13px;
              line-height: 1.4;
              color: #000000 !important;
              background: #ffffff !important;
              padding: 8px;
            }
            .receipt-print-wrapper {
              max-width: ${paperWidthPx};
              margin: 0 auto;
            }
            /* Hilangkan border & shadow kartu saat dicetak */
            .receipt-print-wrapper > div {
              box-shadow: none !important;
              border: none !important;
              padding: 0 4px !important;
              max-width: 100% !important;
            }
            .receipt-header-brand {
              font-family: 'Times New Roman', Times, Georgia, serif !important;
              text-align: center !important;
              margin-bottom: 10px !important;
            }
            .receipt-clinic-parent {
              font-family: 'Times New Roman', Times, Georgia, serif !important;
              font-size: 13px !important;
              font-weight: 700 !important;
              line-height: 1.25 !important;
              text-transform: uppercase !important;
              letter-spacing: 0.5px !important;
              color: #000000 !important;
            }
            .receipt-clinic-name {
              font-family: 'Times New Roman', Times, Georgia, serif !important;
              font-size: 19px !important;
              font-weight: 900 !important;
              line-height: 1.2 !important;
              text-transform: uppercase !important;
              letter-spacing: 0.5px !important;
              margin-top: 2px !important;
              color: #000000 !important;
            }
            .receipt-branch-name {
              font-family: 'Times New Roman', Times, Georgia, serif !important;
              font-size: 19px !important;
              font-weight: 900 !important;
              line-height: 1.2 !important;
              text-transform: uppercase !important;
              letter-spacing: 0.5px !important;
              margin-top: 2px !important;
              color: #000000 !important;
            }
            .receipt-clinic-address {
              font-family: 'Times New Roman', Times, Georgia, serif !important;
              font-size: 11.5px !important;
              font-weight: 400 !important;
              line-height: 1.3 !important;
              margin-top: 4px !important;
              color: #000000 !important;
            }
            .receipt-clinic-phone {
              font-family: 'Times New Roman', Times, Georgia, serif !important;
              font-size: 12px !important;
              font-weight: 700 !important;
              line-height: 1.3 !important;
              margin-top: 2px !important;
              color: #000000 !important;
            }
            .receipt-clinic-meta {
              font-family: 'Times New Roman', Times, Georgia, serif !important;
              font-size: 11.5px !important;
              font-weight: 400 !important;
              line-height: 1.3 !important;
              color: #000000 !important;
            }
            .receipt-title {
              font-size: 13px !important;
              font-weight: 700 !important;
              line-height: 1.4 !important;
            }
            .receipt-grid-header {
              display: grid !important;
              grid-template-columns: minmax(0, 1fr) 28px 64px 74px !important;
              column-gap: 4px !important;
              font-size: 11px !important;
              line-height: 1.4 !important;
              font-weight: 600 !important;
              text-transform: uppercase !important;
              border-bottom: 1px dashed #000000 !important;
              border-top: none !important;
              border-left: none !important;
              border-right: none !important;
              outline: none !important;
              font-family: 'Courier New', Courier, monospace !important;
            }
            .receipt-grid-row {
              display: grid !important;
              grid-template-columns: minmax(0, 1fr) 28px 64px 74px !important;
              column-gap: 4px !important;
              font-size: 13px !important;
              line-height: 1.4 !important;
              font-family: 'Courier New', Courier, monospace !important;
            }
            .receipt-body-text {
              font-size: 13px !important;
              line-height: 1.4 !important;
              font-family: 'Courier New', Courier, monospace !important;
            }
            .receipt-total-large {
              font-size: 16px !important;
              font-weight: 700 !important;
              line-height: 1.4 !important;
            }
            .receipt-tabular {
              font-variant-numeric: tabular-nums !important;
            }
            .receipt-lunas-badge {
              font-size: 12px !important;
              font-weight: 700 !important;
              border: 1px solid #000000 !important;
              color: #000000 !important;
              background: transparent !important;
            }
            .receipt-footer {
              font-size: 13px !important;
              line-height: 1.4 !important;
            }
            table {
              width: 100% !important;
              border-collapse: collapse !important;
              table-layout: fixed !important;
              font-family: 'Courier New', Courier, monospace !important;
            }
            th, td {
              font-variant-numeric: tabular-nums !important;
            }
            .flex { display: flex !important; }
            .flex-column { flex-direction: column !important; }
            .justify-content-between { justify-content: space-between !important; }
            .justify-content-center { justify-content: center !important; }
            .align-items-center { align-items: center !important; }
            .align-items-start { align-items: flex-start !important; }
            .flex-1 { flex: 1 !important; }
            .flex-shrink-0 { flex-shrink: 0 !important; }
            .font-normal { font-weight: 400 !important; }
            .font-medium { font-weight: 500 !important; }
            .font-semibold { font-weight: 600 !important; }
            .font-bold { font-weight: 700 !important; }
            .font-black { font-weight: 900 !important; }
            .text-center { text-align: center !important; }
            .text-right { text-align: right !important; }
            .border-top-1 { border-top: 1px solid #000000 !important; }
            .border-bottom-1 { border-bottom: 1px solid #000000 !important; }
            .border-dashed { border-style: dashed !important; }
            @media print {
              * { color: #000000 !important; }
              .receipt-discount-text, .receipt-total-text, .receipt-item-discount { color: #000000 !important; }
              .receipt-dp-note { border: 1px dashed #000000 !important; background: transparent !important; }
            }
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

  if (!result) return null;

  const now = new Date();
  const tanggalStr = now.toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
  const jamStr = now.toLocaleTimeString('id-ID', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  }).replace(':', '.');
  const waktuStr = `${tanggalStr}, ${jamStr}`;

  const totalGrossSubtotal = (result.items || []).length > 0
    ? (result.items || []).reduce((sum, item) => {
        const isDp = isDpTransaction && Boolean(
          item.jenis_diskon === 'dp_booking' ||
          (item.nama || '').toLowerCase().includes('uang muka') ||
          (item.nama || '').toLowerCase().includes('(dp)') ||
          (!result?.kode_kunjungan && result?.is_dp_booking)
        );
        if (isDp) {
          return sum + (item.harga_satuan * item.qty);
        }
        const isFree = Boolean(
          item.is_free_include ||
          item.jenis_diskon === 'include_treatment' ||
          (item.nama_promo && item.nama_promo.toLowerCase().includes('include')) ||
          ((item.nama || '').toLowerCase().includes('konsul') && (Number(item.harga_satuan || 0) === 0 || Number(item.subtotal || 0) === 0 || Number(item.nilai_diskon || 0) === 100))
        );
        const isKlaim = !isFree && Boolean(
          item.is_klaim ||
          item.is_klaim_paket ||
          (item.jenis as string) === 'klaim_paket' ||
          item.jenis_diskon === 'klaim_paket' ||
          (item.nama || '').toLowerCase().includes('klaim') ||
          (item.nama_promo || '').toLowerCase().includes('klaim') ||
          (Number(item.harga_satuan || 0) === 0 && Number(item.subtotal || 0) === 0)
        );
        const grossPrice = isFree
          ? (item.harga_master || (item.harga_satuan > 0 ? item.harga_satuan : 30000))
          : isKlaim
            ? (item.harga_master && item.harga_master > 0 ? item.harga_master : (item.harga_satuan || 0))
            : (item.harga_master && item.harga_master > item.harga_satuan
                ? item.harga_master
                : (item.diskon && item.diskon > 0 ? item.harga_satuan + (item.diskon / item.qty) : item.harga_satuan));
        return sum + (grossPrice * item.qty);
      }, 0)
    : (result.total_harga !== undefined && result.total_harga > 0 ? result.total_harga : result.total_bayar);

  const totalDiskonAll = isDpTransaction ? 0 : ((result.items || []).length > 0
    ? (result.items || []).reduce((sum, item) => {
        const isDp = Boolean(
          item.jenis_diskon === 'dp_booking' ||
          (item.nama || '').toLowerCase().includes('uang muka') ||
          (item.nama || '').toLowerCase().includes('(dp)')
        );
        if (isDp) return sum;

        const isFree = Boolean(
          item.is_free_include ||
          item.jenis_diskon === 'include_treatment' ||
          (item.nama_promo && item.nama_promo.toLowerCase().includes('include')) ||
          ((item.nama || '').toLowerCase().includes('konsul') && (Number(item.harga_satuan || 0) === 0 || Number(item.subtotal || 0) === 0 || Number(item.nilai_diskon || 0) === 100))
        );
        if (isFree) {
          const grossPrice = item.harga_master || (item.harga_satuan > 0 ? item.harga_satuan : 30000);
          return sum + (grossPrice * item.qty);
        }
        const isKlaim = Boolean(
          item.is_klaim ||
          item.is_klaim_paket ||
          (item.jenis as string) === 'klaim_paket' ||
          item.jenis_diskon === 'klaim_paket' ||
          (item.nama || '').toLowerCase().includes('klaim') ||
          (item.nama_promo || '').toLowerCase().includes('klaim') ||
          (Number(item.harga_satuan || 0) === 0 && Number(item.subtotal || 0) === 0)
        );
        if (isKlaim) {
          const grossPrice = item.harga_master && item.harga_master > 0 ? item.harga_master : 0;
          return sum + (grossPrice * item.qty);
        }
        if (item.harga_master && item.harga_master > item.harga_satuan) {
          return sum + ((item.harga_master - item.harga_satuan) * item.qty);
        }
        return sum + parseFloat(String(item.diskon || 0));
      }, 0)
    : (result.total_diskon !== undefined ? result.total_diskon : 0));

  return (
    <Dialog
      visible={visible}
      onHide={onHide}
      showHeader={false}
      style={{ width: '460px', borderRadius: '20px', overflow: 'hidden' }}
      contentStyle={{ padding: 0, borderRadius: '20px' }}
    >
      {/* Top Banner Header */}
      <div style={{ background: '#0d9488', padding: '24px 16px', textAlign: 'center', color: '#ffffff', position: 'relative' }}>
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

        <div style={{
          width: '52px',
          height: '52px',
          borderRadius: '50%',
          background: 'rgba(255, 255, 255, 0.2)',
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          margin: '0 auto 10px'
        }}>
          <i className="pi pi-check-circle text-white" style={{ fontSize: '28px' }} />
        </div>
        <h3 style={{ fontSize: '20px', fontWeight: 900, margin: '0 0 4px 0', color: '#ffffff' }}>
          {isDpTransaction ? 'Pembayaran DP Berhasil!' : (isKlaimTransaction && (result.total_bayar || 0) === 0 ? 'Klaim Sesi Berhasil!' : 'Pembayaran Berhasil!')}
        </h3>
        <p style={{ fontSize: '13px', margin: 0, opacity: 0.85, fontFamily: 'monospace' }}>{result.kode_transaksi}</p>
      </div>

      {/* Paper Receipt Preview Body */}
      <div className="p-4 surface-ground max-h-[55vh] overflow-y-auto">
        <div
          ref={printRef}
          style={{
            maxWidth: '380px',
            margin: '0 auto',
            padding: '18px 14px',
            boxSizing: 'border-box',
          }}
          className="bg-white border-round-xl border-1 surface-border shadow-2 text-slate-800 font-mono"
        >
          {/* Receipt Brand Header / Kop Institusi */}
          <div className="receipt-header-brand text-center mb-3" style={{ fontFamily: "'Times New Roman', Times, Georgia, serif" }}>
            {logoUrl && !logoError && (
              <div className="flex justify-content-center mb-2">
                <img
                  src={logoUrl}
                  alt={clinicName}
                  style={{
                    maxHeight: '44px',
                    maxWidth: '140px',
                    objectFit: 'contain',
                    display: 'block',
                  }}
                  onError={() => setLogoError(true)}
                />
              </div>
            )}

            {hasDistinctBranch ? (
              <>
                <div
                  className="receipt-clinic-parent font-bold text-slate-900 uppercase tracking-wide"
                  style={{
                    fontFamily: "'Times New Roman', Times, Georgia, serif",
                    fontSize: '13px',
                    lineHeight: '1.25',
                    letterSpacing: '0.5px',
                  }}
                >
                  {clinicName}
                </div>
                <div
                  className="receipt-clinic-name font-black text-slate-950 uppercase tracking-wide mt-0.5"
                  style={{
                    fontFamily: "'Times New Roman', Times, Georgia, serif",
                    fontSize: '19px',
                    fontWeight: 900,
                    lineHeight: '1.2',
                    letterSpacing: '0.5px',
                  }}
                >
                  {branchName}
                </div>
              </>
            ) : (
              <div
                className="receipt-clinic-name font-black text-slate-950 uppercase tracking-wide"
                style={{
                  fontFamily: "'Times New Roman', Times, Georgia, serif",
                  fontSize: '19px',
                  fontWeight: 900,
                  lineHeight: '1.2',
                  letterSpacing: '0.5px',
                }}
              >
                {clinicName}
              </div>
            )}

            {clinicAddress && (
              <div
                className="receipt-clinic-address text-slate-800 font-normal leading-tight mt-1"
                style={{
                  fontFamily: "'Times New Roman', Times, Georgia, serif",
                  fontSize: '11.5px',
                  lineHeight: '1.3',
                }}
              >
                {clinicAddress}
              </div>
            )}

            {clinicPhone && (
              <div
                className="receipt-clinic-phone text-slate-950 font-bold leading-tight mt-0.5"
                style={{
                  fontFamily: "'Times New Roman', Times, Georgia, serif",
                  fontSize: '12px',
                  fontWeight: 700,
                  lineHeight: '1.3',
                }}
              >
                {clinicPhone}
              </div>
            )}

            <div className="receipt-title text-slate-700 font-bold uppercase tracking-wider mt-2.5" style={{ fontSize: '13px', lineHeight: '1.4' }}>
              {isDpTransaction ? 'BUKTI PEMBAYARAN UANG MUKA (DP)' : (isKlaimTransaction && (result.total_bayar || 0) === 0 ? 'STRUK TRANSAKSI (KLAIM SESI)' : 'STRUK TRANSAKSI')}
            </div>
          </div>

          <div className="border-top-1 border-dashed surface-border my-2.5" />

          {/* Meta Info */}
          <div className="receipt-body-text flex flex-column gap-1.5 my-2" style={{ fontSize: '13px', lineHeight: '1.4' }}>
            <div className="flex justify-content-between">
              <span className="text-slate-500 font-normal">No. Transaksi</span>
              <span className="font-bold text-slate-900">{result.kode_transaksi}</span>
            </div>
            {result.kode_booking && (
              <div className="flex justify-content-between">
                <span className="text-slate-500 font-normal">No. Booking</span>
                <span className="font-bold text-slate-900">{result.kode_booking}</span>
              </div>
            )}
            <div className="flex justify-content-between">
              <span className="text-slate-500 font-normal">Pasien</span>
              <span className="font-semibold text-slate-800">{result.nama_pasien || '-'}</span>
            </div>
            {result.no_rm && (
              <div className="flex justify-content-between">
                <span className="text-slate-500 font-normal">No. RM</span>
                <span className="font-semibold text-slate-800">{result.no_rm}</span>
              </div>
            )}
            <div className="flex justify-content-between">
              <span className="text-slate-500 font-normal">Waktu</span>
              <span className="font-semibold text-slate-800">{waktuStr}</span>
            </div>
          </div>

          <div className="border-top-1 border-dashed surface-border my-2.5" />

          {/* Header Kolom (Gaya Minimarket: ITEM | QTY | HARGA | JUMLAH) */}
          <div
            className="receipt-grid-header text-slate-500 font-semibold tracking-wider uppercase pb-1 mb-1.5"
            style={{
              display: 'grid',
              gridTemplateColumns: 'minmax(0, 1fr) 28px 64px 74px',
              columnGap: '4px',
              fontSize: '11px',
              lineHeight: '1.4',
              alignItems: 'center',
              borderBottom: '1px dashed #cbd5e1',
            }}
          >
            <div style={{ textAlign: 'left', minWidth: 0 }}>Item</div>
            <div style={{ textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>Qty</div>
            <div style={{ textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>Harga</div>
            <div style={{ textAlign: 'right', fontVariantNumeric: 'tabular-nums' }}>Jumlah</div>
          </div>

          {/* Cart Item Details (Gaya Minimarket: Item, Qty, Harga, Jumlah) */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', margin: '3px 0' }}>
            {(result.items || []).map((item: CartItem, i: number) => {
              const isDpItem = isDpTransaction && Boolean(
                item.jenis_diskon === 'dp_booking' ||
                (item.nama || '').toLowerCase().includes('uang muka') ||
                (item.nama || '').toLowerCase().includes('(dp)') ||
                (!result?.kode_kunjungan && result?.is_dp_booking)
              );
              const isFreeInclude = !isDpItem && Boolean(
                item.is_free_include ||
                item.jenis_diskon === 'include_treatment' ||
                (item.nama_promo && item.nama_promo.toLowerCase().includes('include')) ||
                ((item.nama || '').toLowerCase().includes('konsul') && (Number(item.harga_satuan || 0) === 0 || Number(item.subtotal || 0) === 0 || Number(item.nilai_diskon || 0) === 100))
              );
              const isKlaim = !isDpItem && !isFreeInclude && Boolean(
                item.is_klaim ||
                item.is_klaim_paket ||
                (item.jenis as string) === 'klaim_paket' ||
                item.jenis_diskon === 'klaim_paket' ||
                (item.nama || '').toLowerCase().includes('klaim') ||
                (item.nama_promo || '').toLowerCase().includes('klaim') ||
                item.kode_kepemilikan_paket_layanan ||
                (Number(item.harga_satuan || 0) === 0 && Number(item.subtotal || 0) === 0)
              );
              const grossUnitPrice = isDpItem
                ? item.harga_satuan
                : (isFreeInclude
                    ? (item.harga_master || (item.harga_satuan > 0 ? item.harga_satuan : 30000))
                    : isKlaim
                      ? (item.harga_master && item.harga_master > 0 ? item.harga_master : (item.harga_satuan || 0))
                      : (item.harga_master && item.harga_master > item.harga_satuan
                          ? item.harga_master
                          : (item.diskon && item.diskon > 0
                              ? item.harga_satuan + (item.diskon / item.qty)
                              : item.harga_satuan)));
              const grossSubtotal = grossUnitPrice * item.qty;

              let itemDisc = 0;
              let itemDiscName = item.nama_promo || 'Diskon';

              if (isDpItem) {
                itemDisc = 0;
              } else if (isFreeInclude) {
                itemDisc = grossSubtotal;
                itemDiscName = 'Gratis (Include Tindakan) (100%)';
              } else if (isKlaim) {
                itemDisc = grossSubtotal;
                itemDiscName = 'Klaim Sesi Paket (100%)';
              } else if (item.harga_master && item.harga_master > item.harga_satuan) {
                itemDisc = (item.harga_master - item.harga_satuan) * item.qty;
                if (item.nilai_diskon && Number(item.nilai_diskon) > 0) {
                  const discVal = item.jenis_diskon === 'nominal'
                    ? `-${formatRupiah(Number(item.nilai_diskon))}`
                    : `${Math.round(Number(item.nilai_diskon))}%`;
                  itemDiscName = item.nama_promo ? `${item.nama_promo} (${discVal})` : `Diskon (${discVal})`;
                } else {
                  const pct = Math.round(((item.harga_master - item.harga_satuan) / item.harga_master) * 100);
                  itemDiscName = item.nama_promo ? `${item.nama_promo} (${pct}%)` : `Diskon (${pct}%)`;
                }
              } else if (item.diskon && item.diskon > 0) {
                itemDisc = parseFloat(String(item.diskon));
                if (item.nilai_diskon && Number(item.nilai_diskon) > 0) {
                  const discVal = item.jenis_diskon === 'nominal'
                    ? `-${formatRupiah(Number(item.nilai_diskon))}`
                    : `${Math.round(Number(item.nilai_diskon))}%`;
                  itemDiscName = item.nama_promo ? `${item.nama_promo} (${discVal})` : `Diskon (${discVal})`;
                }
              }

              const hasDiscount = itemDisc > 0;

              return (
                <div key={i} style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
                  {/* Baris Utama Item: Harga Asli Gross */}
                  <div
                    className="receipt-grid-row text-slate-900"
                    style={{
                      display: 'grid',
                      gridTemplateColumns: 'minmax(0, 1fr) 28px 64px 74px',
                      columnGap: '4px',
                      fontSize: '13px',
                      lineHeight: '1.4',
                      alignItems: 'flex-start',
                    }}
                  >
                    <div
                      className="font-medium"
                      style={{
                        textAlign: 'left',
                        minWidth: 0,
                        wordBreak: 'normal',
                        overflowWrap: 'break-word',
                      }}
                    >
                      <div>{item.nama}</div>
                      {isKlaim && (
                        <div style={{ fontSize: '11px', color: '#1d4ed8', fontWeight: 700, marginTop: '2px' }}>
                          ✓ Klaim Sesi Paket
                        </div>
                      )}
                      {isFreeInclude && (
                        <div style={{ fontSize: '11px', color: '#0f766e', fontWeight: 600, marginTop: '2px' }}>
                          ✓ Gratis (Include Tindakan)
                        </div>
                      )}
                    </div>
                    <div
                      className="text-slate-700 font-normal"
                      style={{
                        textAlign: 'right',
                        fontVariantNumeric: 'tabular-nums',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {item.qty}
                    </div>
                    <div
                      className="text-slate-700 font-normal"
                      style={{
                        textAlign: 'right',
                        fontVariantNumeric: 'tabular-nums',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {formatAngka(grossUnitPrice)}
                    </div>
                    <div
                      className="font-medium"
                      style={{
                        textAlign: 'right',
                        fontVariantNumeric: 'tabular-nums',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      {formatAngka(grossSubtotal)}
                    </div>
                  </div>

                  {/* Baris Diskon / Promo Per Item */}
                  {hasDiscount && (
                    <div
                      className="receipt-grid-row text-slate-500 font-normal"
                      style={{
                        display: 'grid',
                        gridTemplateColumns: 'minmax(0, 1fr) 28px 64px 74px',
                        columnGap: '4px',
                        fontSize: '12px',
                        lineHeight: '1.3',
                        alignItems: 'center',
                      }}
                    >
                      <div
                        style={{
                          gridColumn: '1 / 4',
                          textAlign: 'left',
                          minWidth: 0,
                        }}
                      >
                        {itemDiscName}
                      </div>
                      <div
                        style={{
                          gridColumn: '4 / 5',
                          textAlign: 'right',
                          fontVariantNumeric: 'tabular-nums',
                          whiteSpace: 'nowrap',
                        }}
                      >
                        -{formatAngka(itemDisc)}
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          <div className="border-top-1 border-dashed surface-border my-2.5" />

          {/* Financial Totals */}
          <div className="receipt-body-text flex flex-column gap-1.5 my-2" style={{ fontSize: '13px', lineHeight: '1.4' }}>
            <div className="flex justify-content-between font-normal">
              <span className="text-slate-600">Subtotal</span>
              <span className="text-slate-800 receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                {formatRupiah(totalGrossSubtotal)}
              </span>
            </div>

            {totalDiskonAll > 0 && (
              <div className="flex justify-content-between font-normal text-emerald-700 receipt-discount-text">
                <span>Diskon / Potongan</span>
                <span className="receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                  -{formatRupiah(totalDiskonAll)}
                </span>
              </div>
            )}

            {isDpTransaction ? (
              <div className="receipt-total-large flex justify-content-between font-bold text-slate-900 pt-1 border-top-1 border-slate-200 mt-0.5" style={{ fontSize: '16px', lineHeight: '1.4' }}>
                <span>TOTAL DP DIBAYAR</span>
                <span className="text-teal-700 receipt-total-text receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                  {formatRupiah(result.total_bayar)}
                </span>
              </div>
            ) : result.dp_nominal != null && result.dp_nominal > 0 ? (
              <>
                <div className="flex justify-content-between text-slate-600 font-normal">
                  <span>Total Biaya</span>
                  <span className="text-slate-800 receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                    {formatRupiah(result.total_bayar)}
                  </span>
                </div>
                <div className="flex justify-content-between text-teal-700 font-normal">
                  <span>Uang Muka (DP {result.metode_pembayaran_dp ? result.metode_pembayaran_dp.toUpperCase() : 'Terbayar'})</span>
                  <span className="receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                    -{formatRupiah(result.dp_nominal)}
                  </span>
                </div>
                <div className="border-top-1 border-dashed surface-border my-1" />
                <div className="receipt-total-large flex justify-content-between font-bold text-slate-900 pt-0.5" style={{ fontSize: '16px', lineHeight: '1.4' }}>
                  <span>Sisa Pelunasan</span>
                  <span className="text-teal-700 receipt-total-text receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                    {formatRupiah(result.sisa_bayar !== undefined ? result.sisa_bayar : Math.max(0, result.total_bayar - result.dp_nominal))}
                  </span>
                </div>
              </>
            ) : (
              <div className="receipt-total-large flex justify-content-between font-bold text-slate-900 pt-1 border-top-1 border-slate-200 mt-0.5" style={{ fontSize: '16px', lineHeight: '1.4' }}>
                <span>TOTAL BAYAR</span>
                <span className="text-teal-700 receipt-total-text receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                  {formatRupiah(result.total_bayar)}
                </span>
              </div>
            )}
          </div>

          <div className="border-top-1 border-dashed surface-border my-2.5" />

          {/* Payment Method details */}
          <div className="receipt-body-text flex flex-column gap-1.5 my-2" style={{ fontSize: '13px', lineHeight: '1.4' }}>
            <div className="flex justify-content-between">
              <span className="text-slate-600 font-normal">Metode</span>
              <div className="text-right">
                <span className="font-semibold text-slate-800">{METODE_LABEL[result.metode_bayar] || result.metode_bayar}</span>
                {result.metode_bayar === 'transfer' && (result as any).nama_bank && (
                  <div className="text-[11px] text-slate-600 font-normal mt-0.5">
                    {(result as any).nama_bank}
                    {(result as any).no_rekening ? ` • ${(result as any).no_rekening}` : ''}
                    {(result as any).atas_nama ? ` (a.n. ${(result as any).atas_nama})` : ''}
                  </div>
                )}
                {result.metode_bayar === 'qris' && (
                  <div className="text-[11px] text-slate-600 font-normal mt-0.5">
                    QRIS Klinik {(result as any).kode_metode_pembayaran ? `(${(result as any).kode_metode_pembayaran})` : ''}
                  </div>
                )}
              </div>
            </div>
            {result.metode_bayar === 'tunai' && (
              <>
                <div className="flex justify-content-between">
                  <span className="text-slate-600 font-normal">Dibayar</span>
                  <span className="font-semibold text-slate-800 receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                    {formatRupiah(result.nominal_bayar)}
                  </span>
                </div>
                <div className="flex justify-content-between">
                  <span className="text-slate-600 font-normal">Kembalian</span>
                  <span className="font-semibold text-slate-800 receipt-tabular" style={{ fontVariantNumeric: 'tabular-nums' }}>
                    {formatRupiah(result.kembalian)}
                  </span>
                </div>
              </>
            )}
          </div>

          {/* Lunas Status Badge */}
          <div className="my-2.5 text-center">
            <span
              className="receipt-lunas-badge inline-block py-1 px-3 border-1 border-emerald-300 text-emerald-800 font-bold tracking-wider uppercase bg-emerald-50 border-round-md"
              style={{ fontSize: '12px', lineHeight: '1.4' }}
            >
              ✓ {isDpTransaction ? 'DP LUNAS' : (isKlaimTransaction && (result.total_bayar || 0) === 0 ? 'LUNAS (KLAIM SESI)' : 'LUNAS')}
            </span>
          </div>

          {/* Catatan Khusus Bukti Pembayaran DP Booking */}
          {isDpTransaction && (
            <div
              className="receipt-dp-note text-center text-slate-600 my-2.5 p-2.5 border-round-md bg-teal-50 border-1 border-teal-200"
              style={{ fontSize: '11px', lineHeight: '1.4' }}
            >
              <div className="font-bold text-teal-800 mb-0.5">BUKTI PEMBAYARAN DP RESERVASI</div>
              <div>Simpan struk ini sebagai bukti pembayaran uang muka booking.</div>
              <div className="font-medium text-slate-700 mt-0.5">Sisa biaya tindakan dilunasi saat kedatangan di klinik.</div>
            </div>
          )}

          {/* Catatan Khusus Klaim Sesi Paket */}
          {isKlaimTransaction && (
            <div
              className="receipt-dp-note text-center text-slate-600 my-2.5 p-2.5 border-round-md bg-blue-50 border-1 border-blue-200"
              style={{ fontSize: '11px', lineHeight: '1.4' }}
            >
              <div className="font-bold text-blue-800 mb-0.5">BUKTI KLAIM SESI PAKET</div>
              <div>Layanan telah berhasil diklaim dan dikurangi dari paket aktif pasien.</div>
            </div>
          )}

          {/* Footer message */}
          {footerMsg && (
            <div
              className="receipt-footer text-center text-slate-400 mt-2 whitespace-pre-line"
              style={{ fontSize: '13px', lineHeight: '1.4' }}
            >
              {footerMsg}
            </div>
          )}
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
