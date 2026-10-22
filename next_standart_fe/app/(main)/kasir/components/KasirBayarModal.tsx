'use client';

import React, { useState, useEffect } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import { InputNumber } from 'primereact/inputnumber';
import { Dropdown } from 'primereact/dropdown';
import postData from '@/lib/axios/postData';

const METODE_LIST = [
  { value: 'tunai', label: 'Tunai', icon: 'pi-wallet', color: '#0d9488', bg: '#f0fdfa' },
  { value: 'debit', label: 'Debit', icon: 'pi-credit-card', color: '#0ea5e9', bg: '#f0f9ff' },
  { value: 'kredit', label: 'Kredit', icon: 'pi-credit-card', color: '#8b5cf6', bg: '#faf5ff' },
  { value: 'qris', label: 'QRIS', icon: 'pi-qrcode', color: '#f59e0b', bg: '#fffbeb' },
  { value: 'transfer', label: 'Transfer', icon: 'pi-arrow-right-arrow-left', color: '#6366f1', bg: '#eef2ff' },
];

const formatRupiah = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(val || 0);

export interface MetodePembayaranMaster {
  id: number;
  kode_metode: string;
  tipe: 'rekening' | 'qris';
  nama_bank?: string | null;
  no_rekening?: string | null;
  atas_nama?: string | null;
  urutan: number;
  status: string;
  kode_cabang?: string | null;
  nama_cabang?: string | null;
  gambar_qris?: string | null;
  gambar_qris_url?: string | null;
  gambar_qris_full_url?: string | null;
}

interface KasirBayarModalProps {
  visible: boolean;
  totalBayar: number; // Ini adalah Sisa Pelunasan yang harus diterima kasir
  totalTagihanAsli?: number;
  dpNominal?: number;
  metodeDp?: string | null;
  buktiDp?: string | null;
  is_dp_booking?: boolean;
  onHide: () => void;
  onConfirm: (metode: string, nominal: number, kodeMetode?: string | null) => Promise<void>;
}

export const KasirBayarModal: React.FC<KasirBayarModalProps> = ({
  visible,
  totalBayar,
  totalTagihanAsli,
  dpNominal = 0,
  metodeDp,
  buktiDp,
  is_dp_booking = false,
  onHide,
  onConfirm,
}) => {
  const [selectedMetode, setSelectedMetode] = useState('tunai');
  const [nominal, setNominal] = useState<number>(0);
  const [loading, setLoading] = useState(false);
  const [showPreviewBukti, setShowPreviewBukti] = useState(false);
  const [showQrisEnlarged, setShowQrisEnlarged] = useState(false);

  // Master metode pembayaran
  const [metodeList, setMetodeList] = useState<MetodePembayaranMaster[]>([]);
  const [loadingMetode, setLoadingMetode] = useState(false);
  const [selectedKodeMetode, setSelectedKodeMetode] = useState<string | null>(null);
  const [copiedKode, setCopiedKode] = useState<string | null>(null);

  const rekeningList = metodeList.filter((m) => m.tipe === 'rekening');
  const qrisList = metodeList.filter((m) => m.tipe === 'qris');

  const activeQris = qrisList.find((q) => q.kode_metode === selectedKodeMetode) || qrisList[0] || null;
  const activeRekening = rekeningList.find((r) => r.kode_metode === selectedKodeMetode) || rekeningList[0] || null;

  // Fetch daftar metode pembayaran aktif
  const fetchMetodePembayaran = async () => {
    setLoadingMetode(true);
    try {
      const res = await postData('/master/kasir-metode-pembayaran', {});
      if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
        setMetodeList(res.data.data || []);
      }
    } catch {
      // fallback silent
    } finally {
      setLoadingMetode(false);
    }
  };

  useEffect(() => {
    if (visible) {
      fetchMetodePembayaran();
      // Default metode jika DP booking sudah ditentukan
      if (is_dp_booking && metodeDp) {
        const dpMethodLower = metodeDp.toLowerCase();
        if (METODE_LIST.some((m) => m.value === dpMethodLower)) {
          setSelectedMetode(dpMethodLower);
        }
      }
    }
  }, [visible, is_dp_booking, metodeDp]);

  // Sinkronisasi selectedKodeMetode saat selectedMetode berganti atau metodeList terisi
  useEffect(() => {
    if (selectedMetode === 'qris') {
      if (qrisList.length > 0 && (!selectedKodeMetode || !qrisList.some((q) => q.kode_metode === selectedKodeMetode))) {
        setSelectedKodeMetode(qrisList[0].kode_metode);
      }
    } else if (selectedMetode === 'transfer') {
      if (rekeningList.length > 0 && (!selectedKodeMetode || !rekeningList.some((r) => r.kode_metode === selectedKodeMetode))) {
        setSelectedKodeMetode(rekeningList[0].kode_metode);
      }
    } else {
      setSelectedKodeMetode(null);
    }
  }, [selectedMetode, metodeList]);

  const hasDp = dpNominal > 0;
  const kembalian = selectedMetode === 'tunai' ? Math.max(0, (nominal || 0) - totalBayar) : 0;
  const nominalValid = selectedMetode !== 'tunai' || (nominal || 0) >= totalBayar;

  // Quick nominal buttons for tunai
  const quickAmounts = [totalBayar, Math.ceil(totalBayar / 50000) * 50000, Math.ceil(totalBayar / 100000) * 100000];
  const uniqueAmounts = [...new Set(quickAmounts)].filter((a) => a >= totalBayar);

  const handleCopy = (text: string, kode: string) => {
    if (navigator?.clipboard) {
      navigator.clipboard.writeText(text);
      setCopiedKode(kode);
      setTimeout(() => setCopiedKode(null), 2000);
    }
  };

  const handleConfirm = async () => {
    if (!nominalValid) return;
    setLoading(true);
    try {
      const codeToSend = (selectedMetode === 'qris' || selectedMetode === 'transfer') ? selectedKodeMetode : null;
      await onConfirm(selectedMetode, selectedMetode === 'tunai' ? (nominal || totalBayar) : totalBayar, codeToSend);
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Dialog
        visible={visible}
        onHide={onHide}
        showHeader={false}
        header={null}
        style={{ width: '470px', maxWidth: '95vw', borderRadius: '20px', overflow: 'hidden', border: 'none' }}
        contentStyle={{ padding: 0, borderRadius: '20px', overflow: 'hidden', display: 'flex', flexDirection: 'column', maxHeight: '92vh' }}
        closable={false}
        pt={{
          header: { style: { display: 'none' } },
          root: { style: { borderRadius: '20px', overflow: 'hidden', border: 'none' } },
          content: { style: { padding: 0, borderRadius: '20px', overflow: 'hidden' } },
        }}
      >
        <style>{`
          .p-dialog-header {
            display: none !important;
          }
          .custom-thin-scrollbar {
            scrollbar-width: thin;
            scrollbar-color: #cbd5e1 transparent;
          }
          .custom-thin-scrollbar::-webkit-scrollbar {
            width: 5px;
            height: 5px;
          }
          .custom-thin-scrollbar::-webkit-scrollbar-track {
            background: transparent;
          }
          .custom-thin-scrollbar::-webkit-scrollbar-thumb {
            background-color: #cbd5e1;
            border-radius: 9999px;
          }
          .custom-thin-scrollbar::-webkit-scrollbar-thumb:hover {
            background-color: #94a3b8;
          }
        `}</style>

        {/* 1. HEADER: Dark Navy Banner TOTAL TAGIHAN (Persis Foto) */}
        <div
          style={{
            position: 'relative',
            flexShrink: 0,
            background: '#0f172a',
            padding: '24px 20px 22px',
            textAlign: 'center',
          }}
        >
          <button
            type="button"
            onClick={onHide}
            disabled={loading}
            style={{
              position: 'absolute',
              top: '14px',
              right: '16px',
              background: 'transparent',
              border: 'none',
              borderRadius: '6px',
              width: '28px',
              height: '28px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#64748b',
              cursor: 'pointer',
              transition: 'all 0.15s ease',
            }}
            title="Tutup Modal"
            onMouseEnter={(e) => { e.currentTarget.style.color = '#ffffff'; }}
            onMouseLeave={(e) => { e.currentTarget.style.color = '#64748b'; }}
          >
            <i className="pi pi-times text-xs" />
          </button>

          {hasDp && !is_dp_booking && (
            <div className="flex justify-content-between align-items-center text-xs text-slate-400 mb-2 pb-2 border-bottom-1 border-white-alpha-10" style={{ maxWidth: '360px', margin: '0 auto' }}>
              <span>Total Tindakan: <strong className="text-white">{formatRupiah(totalTagihanAsli || (totalBayar + dpNominal))}</strong></span>
              <span className="text-teal-300 font-bold">DP {metodeDp ? `(${metodeDp.toUpperCase()})` : ''}: -{formatRupiah(dpNominal)}</span>
            </div>
          )}

          <div
            style={{
              fontSize: '11px',
              fontWeight: 600,
              color: '#94a3b8',
              letterSpacing: '0.12em',
              textTransform: 'uppercase',
              marginBottom: '6px',
            }}
          >
            {is_dp_booking ? 'Nominal Uang Muka (DP)' : (hasDp ? 'Sisa Pelunasan Wajib Dibayar' : 'Total Tagihan')}
          </div>
          <div
            style={{
              fontSize: '34px',
              fontWeight: 800,
              color: '#10b981',
              lineHeight: 1.1,
              letterSpacing: '-0.02em',
            }}
          >
            {formatRupiah(totalBayar)}
          </div>
        </div>

        {/* 2. BODY AREA: Metode Pembayaran + Konten + Tombol Konfirmasi */}
        <div
          className="custom-thin-scrollbar"
          style={{
            flex: '1 1 auto',
            overflowY: 'auto',
            padding: '20px 22px',
            background: '#ffffff',
          }}
        >
          {/* Banner Bukti DP Pasien (Jika ada dari mobile) */}
          {buktiDp && (
            <div className="mb-3 p-2 bg-teal-50 border-1 border-teal-200 border-round-xl flex align-items-center justify-content-between">
              <div className="flex align-items-center gap-2">
                <div
                  style={{
                    width: '28px',
                    height: '28px',
                    borderRadius: '6px',
                    background: '#ccfbf1',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <i className="pi pi-image text-teal-700 text-xs" />
                </div>
                <div>
                  <div className="text-xs font-bold text-teal-900">Bukti Transfer DP Pasien</div>
                  <div className="text-[10px] text-teal-700">Diunggah via Mobile</div>
                </div>
              </div>
              <Button
                type="button"
                label="Lihat Foto"
                icon="pi pi-eye"
                size="small"
                className="text-xs font-bold bg-teal-600 text-white border-none py-1 px-2.5 hover:bg-teal-700"
                onClick={() => setShowPreviewBukti(true)}
              />
            </div>
          )}

          {/* Baris Tombol Metode Pembayaran (Persis Foto) */}
          <div>
            <div
              style={{
                fontSize: '11px',
                fontWeight: 700,
                color: '#334155',
                textTransform: 'uppercase',
                letterSpacing: '0.04em',
                marginBottom: '10px',
              }}
            >
              Metode Pembayaran
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: '8px' }}>
              {METODE_LIST.map((m) => {
                const isActive = selectedMetode === m.value;
                return (
                  <button
                    key={m.value}
                    type="button"
                    onClick={() => { setSelectedMetode(m.value); setNominal(0); }}
                    style={{
                      padding: '12px 4px 10px',
                      borderRadius: '12px',
                      border: isActive ? '1.5px solid #6366f1' : '1px solid #e2e8f0',
                      background: isActive ? '#f4f6ff' : '#ffffff',
                      cursor: 'pointer',
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      gap: '6px',
                      transition: 'all 0.15s ease',
                    }}
                  >
                    <i
                      className={`pi ${m.icon}`}
                      style={{
                        fontSize: '18px',
                        color: isActive ? '#4f46e5' : '#475569',
                      }}
                    />
                    <span
                      style={{
                        fontSize: '11.5px',
                        fontWeight: isActive ? 700 : 600,
                        color: isActive ? '#4338ca' : '#334155',
                      }}
                    >
                      {m.label}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* ═════════════════════════════════════════════════════════════ */}
          {/* TAMPILAN DINAMIS: QRIS                                      */}
          {/* ═════════════════════════════════════════════════════════════ */}
          {selectedMetode === 'qris' && (
            <div className="mt-3">
              {qrisList.length === 0 ? (
                <div className="p-3 bg-amber-50 border-1 border-amber-200 border-round-xl text-amber-900 text-xs">
                  <div className="font-bold flex align-items-center gap-1.5 mb-1 text-amber-800">
                    <i className="pi pi-exclamation-triangle text-amber-600" />
                    Belum Ada QRIS Aktif
                  </div>
                  <div className="text-slate-600 text-[11px] line-height-2">
                    Belum ada QRIS aktif untuk cabang ini. Silakan hubungi Super Admin untuk menambahkan master QRIS klinik.
                  </div>
                </div>
              ) : (
                <div className="p-3 bg-white border-1 border-slate-200 border-round-xl shadow-1 text-center flex flex-column align-items-center">
                  {/* Dropdown jika QRIS lebih dari 1 */}
                  {qrisList.length > 1 && (
                    <div className="w-full text-left mb-2.5">
                      <label className="text-[11px] font-bold text-slate-600 block mb-1">Pilih Rekening QRIS:</label>
                      <Dropdown
                        value={selectedKodeMetode}
                        options={qrisList.map((q) => ({
                          label: `${q.kode_metode} - QRIS Klinik`,
                          value: q.kode_metode,
                        }))}
                        optionValue="value"
                        onChange={(e) => setSelectedKodeMetode(e.value)}
                        className="w-full p-inputtext-sm text-xs"
                      />
                    </div>
                  )}

                  <div className="text-xs text-slate-500 font-medium mb-1">
                    Nominal Pembayaran QRIS:
                  </div>
                  <div className="text-2xl font-black text-amber-600 mb-2">
                    {formatRupiah(totalBayar)}
                  </div>

                  {activeQris?.gambar_qris_full_url || activeQris?.gambar_qris_url || activeQris?.gambar_qris ? (
                    <div
                      className="p-2 border-1 border-slate-200 border-round-xl bg-white shadow-1 cursor-pointer transition-all hover:shadow-3 inline-flex align-items-center justify-content-center"
                      style={{ width: '190px', height: '190px' }}
                      onClick={() => setShowQrisEnlarged(true)}
                      title="Klik untuk memperbesar QRIS"
                    >
                      <img
                        src={activeQris.gambar_qris_full_url || activeQris.gambar_qris_url || activeQris.gambar_qris || ''}
                        alt="QRIS Klinik"
                        style={{ maxWidth: '100%', maxHeight: '100%', objectFit: 'contain' }}
                      />
                    </div>
                  ) : (
                    <div className="py-4 text-slate-400 text-xs italic">
                      Gambar QRIS tidak ditemukan
                    </div>
                  )}

                  <div className="flex align-items-center justify-content-center gap-2 mt-2 w-full">
                    <Button
                      type="button"
                      label="Perbesar QRIS"
                      icon="pi pi-search-plus"
                      size="small"
                      outlined
                      severity="warning"
                      className="text-xs py-1.5 px-3 border-round-lg font-bold"
                      onClick={() => setShowQrisEnlarged(true)}
                    />
                  </div>

                  <div style={{ fontSize: '12px', color: '#64748b', marginTop: '8px' }} className="font-medium">
                    Gunakan aplikasi perbankan atau e-wallet (BCA, Mandiri, GoPay, OVO, Dana, ShopeePay) untuk scan kode di atas.
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ═════════════════════════════════════════════════════════════ */}
          {/* TAMPILAN DINAMIS: TRANSFER BANK                              */}
          {/* ═════════════════════════════════════════════════════════════ */}
          {selectedMetode === 'transfer' && (
            <div>
              {rekeningList.length === 0 ? (
                <div className="p-3 bg-blue-50 border-1 border-blue-200 border-round-xl text-blue-900 text-xs mt-3">
                  <div className="font-bold flex align-items-center gap-1.5 mb-1 text-blue-800">
                    <i className="pi pi-exclamation-triangle text-blue-600" />
                    Belum Ada Rekening Bank Aktif
                  </div>
                  <div className="text-slate-600 text-[11px] line-height-2">
                    Belum ada nomor rekening bank aktif untuk cabang ini. Silakan hubungi Super Admin untuk menambahkan master rekening.
                  </div>
                </div>
              ) : (
                <div>
                  {/* Header satu baris: judul di kiri, jumlah di kanan */}
                  <div className="flex justify-content-between align-items-center" style={{ margin: '16px 0 10px' }}>
                    <span style={{ fontSize: '12px', fontWeight: 700, color: '#1e293b' }}>
                      Pilih Rekening Tujuan Transfer:
                    </span>
                    <span style={{ fontSize: '11.5px', fontWeight: 700, color: '#4338ca' }}>
                      {rekeningList.length} Rekening Aktif
                    </span>
                  </div>

                  {/* Daftar kartu rekening (Persis Foto) */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                    {rekeningList.map((rek) => {
                      const isSelected = selectedKodeMetode === rek.kode_metode;
                      return (
                        <div
                          key={rek.kode_metode}
                          onClick={() => setSelectedKodeMetode(rek.kode_metode)}
                          style={{
                            padding: '12px 16px',
                            borderRadius: '12px',
                            border: isSelected ? '1.5px solid #818cf8' : '1px solid #e2e8f0',
                            background: isSelected ? '#f4f6ff' : '#ffffff',
                            cursor: 'pointer',
                            transition: 'all 0.15s ease',
                            display: 'flex',
                            flexDirection: 'column',
                          }}
                        >
                          {/* Baris 1: Kotak ikon gedung & info bank di kiri, badge Dipilih di kanan */}
                          <div className="flex justify-content-between align-items-start">
                            <div className="flex align-items-center" style={{ gap: '10px' }}>
                              <div
                                style={{
                                  width: '32px',
                                  height: '32px',
                                  borderRadius: '8px',
                                  background: isSelected ? '#4338ca' : '#e0e7ff',
                                  color: isSelected ? '#ffffff' : '#4f46e5',
                                  display: 'flex',
                                  alignItems: 'center',
                                  justifyContent: 'center',
                                  flexShrink: 0,
                                }}
                              >
                                <i className="pi pi-building" style={{ fontSize: '14px' }} />
                              </div>
                              <div>
                                <div style={{ fontSize: '11.5px', fontWeight: 700, color: '#1e293b', lineHeight: 1.2 }}>
                                  {rek.nama_bank}
                                </div>
                                <div style={{ fontSize: '12.5px', fontWeight: 600, color: '#0f172a', lineHeight: 1.25, marginTop: '2px' }}>
                                  a.n. {rek.atas_nama || '-'}
                                </div>
                              </div>
                            </div>
                            {isSelected && (
                              <span
                                style={{
                                  background: '#e0e7ff',
                                  color: '#3730a3',
                                  fontSize: '10.5px',
                                  fontWeight: 700,
                                  padding: '3px 9px',
                                  borderRadius: '6px',
                                }}
                              >
                                Dipilih
                              </span>
                            )}
                          </div>

                          {/* Baris 2: Nomor rekening di kiri, Tombol Salin di kanan */}
                          <div className="flex justify-content-between align-items-center" style={{ marginTop: '10px' }}>
                            <div
                              style={{
                                fontSize: '15px',
                                fontWeight: 800,
                                letterSpacing: '0.02em',
                                color: '#0f172a',
                                lineHeight: 1.1,
                              }}
                            >
                              {rek.no_rekening}
                            </div>

                            <button
                              type="button"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleCopy(rek.no_rekening || '', rek.kode_metode);
                              }}
                              style={{
                                height: '28px',
                                padding: '0 14px',
                                borderRadius: '6px',
                                border: copiedKode === rek.kode_metode ? '1.5px solid #10b981' : '1px solid #cbd5e1',
                                background: copiedKode === rek.kode_metode ? '#ecfdf5' : '#ffffff',
                                color: copiedKode === rek.kode_metode ? '#059669' : '#334155',
                                fontSize: '11.5px',
                                fontWeight: 600,
                                display: 'inline-flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                cursor: 'pointer',
                                transition: 'all 0.15s ease',
                                flexShrink: 0,
                              }}
                            >
                              <span>{copiedKode === rek.kode_metode ? 'Tersalin!' : 'Salin'}</span>
                            </button>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>
          )}

          {/* ═════════════════════════════════════════════════════════════ */}
          {/* TAMPILAN: TUNAI (Nominal Diterima & Kembalian)               */}
          {/* ═════════════════════════════════════════════════════════════ */}
          {selectedMetode === 'tunai' && (
            <div style={{ marginTop: '16px' }}>
              <div style={{ fontSize: '12px', fontWeight: 700, color: '#64748b', marginBottom: '8px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                Nominal Diterima
              </div>
              <InputNumber
                value={nominal}
                onValueChange={(e) => setNominal(e.value || 0)}
                mode="currency"
                currency="IDR"
                locale="id-ID"
                minFractionDigits={0}
                className="w-full"
                inputStyle={{ fontSize: '18px', fontWeight: 800, textAlign: 'right', padding: '10px 14px' }}
                min={0}
              />
              {/* Quick amount buttons */}
              <div className="flex gap-2 mt-2 flex-wrap">
                {uniqueAmounts.map((amt) => (
                  <button
                    key={amt}
                    type="button"
                    onClick={() => setNominal(amt)}
                    style={{
                      flex: 1,
                      padding: '6px 8px',
                      borderRadius: '8px',
                      border: nominal === amt ? '1.5px solid #0d9488' : '1.5px solid #e2e8f0',
                      background: nominal === amt ? '#f0fdfa' : '#f8fafc',
                      fontSize: '11px',
                      fontWeight: 700,
                      color: nominal === amt ? '#0d9488' : '#64748b',
                      cursor: 'pointer',
                      whiteSpace: 'nowrap',
                    }}
                  >
                    {formatRupiah(amt)}
                  </button>
                ))}
              </div>

              {/* Kembalian */}
              {nominal > 0 && (
                <div
                  style={{
                    marginTop: '12px',
                    padding: '10px 14px',
                    borderRadius: '10px',
                    background: kembalian > 0 ? '#f0fdfa' : '#fff1f2',
                    border: `1.5px solid ${kembalian >= 0 ? '#5eead4' : '#fca5a5'}`,
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                  }}
                >
                  <span style={{ fontSize: '13px', fontWeight: 700, color: '#64748b' }}>
                    {kembalian >= 0 ? '💵 Kembalian' : '⚠️ Kurang'}
                  </span>
                  <span style={{ fontSize: '16px', fontWeight: 900, color: kembalian >= 0 ? '#0d9488' : '#e11d48' }}>
                    {formatRupiah(Math.abs(kembalian))}
                  </span>
                </div>
              )}
            </div>
          )}

          {/* ═════════════════════════════════════════════════════════════ */}
          {/* TAMPILAN: DEBIT / KREDIT                                     */}
          {/* ═════════════════════════════════════════════════════════════ */}
          {(selectedMetode === 'debit' || selectedMetode === 'kredit') && (
            <div className="p-3 bg-slate-50 border-1 border-slate-200 border-round-xl text-center mt-3">
              <i className="pi pi-credit-card text-slate-400 text-3xl mb-2" />
              <div className="text-xs font-bold text-slate-700">
                Pembayaran via Mesin EDC ({selectedMetode.toUpperCase()})
              </div>
              <div className="text-xs text-slate-500 mt-1">
                Silakan gesek / tap kartu pasien pada mesin EDC kasir sebesar:
              </div>
              <div className="text-lg font-bold text-teal-700 mt-1">
                {formatRupiah(totalBayar)}
              </div>
            </div>
          )}

          {/* ═════════════════════════════════════════════════════════════ */}
          {/* TOMBOL KONFIRMASI BAYAR (Persis Foto)                        */}
          {/* ═════════════════════════════════════════════════════════════ */}
          <div style={{ marginTop: '16px' }}>
            <Button
              type="button"
              label={`Konfirmasi Bayar • ${formatRupiah(selectedMetode === 'tunai' ? (nominal || totalBayar) : totalBayar)}`}
              icon="pi pi-check"
              className="w-full"
              onClick={handleConfirm}
              loading={loading}
              disabled={!nominalValid}
              style={{
                background: nominalValid ? '#047857' : '#cbd5e1',
                border: 'none',
                fontSize: '14px',
                fontWeight: 700,
                padding: '12px',
                borderRadius: '10px',
                color: '#ffffff',
                boxShadow: nominalValid ? '0 2px 8px rgba(4,120,87,0.2)' : 'none',
                height: '46px',
              }}
            />
          </div>
        </div>
      </Dialog>

      {/* Dialog Preview Foto Bukti DP */}
      <Dialog
        visible={showPreviewBukti}
        onHide={() => setShowPreviewBukti(false)}
        header="Foto Bukti Pembayaran DP (Mobile)"
        style={{ width: '440px', maxWidth: '95vw', borderRadius: '16px' }}
        modal
        dismissableMask
      >
        <div className="text-center bg-slate-900 border-round-xl p-2 overflow-hidden">
          <img
            src={buktiDp?.startsWith('http') || buktiDp?.startsWith('/') ? buktiDp : `/uploads/${buktiDp}`}
            alt="Bukti Transfer DP"
            className="w-full border-round-lg shadow-2"
            style={{ maxHeight: '420px', objectFit: 'contain' }}
            onError={(e: any) => {
              e.target.onerror = null;
              e.target.src = 'https://placehold.co/400x300?text=Gambar+Bukti+DP+Tidak+Ditemukan';
            }}
          />
          <div className="flex justify-content-end w-full mt-2">
            <a
              href={buktiDp?.startsWith('http') || buktiDp?.startsWith('/') ? buktiDp : `/uploads/${buktiDp}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-teal-300 font-semibold no-underline hover:underline flex align-items-center gap-1"
            >
              <i className="pi pi-external-link text-[10px]" />
              Buka Gambar Penuh
            </a>
          </div>
        </div>
      </Dialog>

      {/* Dialog Perbesar Gambar QRIS */}
      <Dialog
        visible={showQrisEnlarged}
        onHide={() => setShowQrisEnlarged(false)}
        header={`QRIS Pembayaran Klinik • ${activeQris?.kode_metode || ''}`}
        style={{ width: '420px', maxWidth: '95vw', borderRadius: '16px' }}
        modal
        dismissableMask
      >
        <div className="text-center p-3">
          <div className="text-xs text-slate-500 font-semibold mb-1">
            Scan QRIS untuk pembayaran tagihan:
          </div>
          <div className="text-2xl font-black text-amber-600 mb-3">
            {formatRupiah(totalBayar)}
          </div>
          {activeQris && (
            <div className="p-3 bg-white border-1 border-slate-200 border-round-2xl inline-block shadow-2">
              <img
                src={activeQris.gambar_qris_full_url || activeQris.gambar_qris_url || activeQris.gambar_qris || ''}
                alt="QRIS Detail"
                style={{ width: '280px', height: '280px', objectFit: 'contain' }}
              />
            </div>
          )}
          <div className="text-xs text-slate-500 mt-3 font-medium">
            Gunakan aplikasi mobile banking (BCA, Mandiri, BRI, BNI) atau dompet digital (GoPay, OVO, Dana, ShopeePay) untuk scan kode di atas.
          </div>
        </div>
      </Dialog>
    </>
  );
};
