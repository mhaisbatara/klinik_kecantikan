'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Toast } from 'primereact/toast';
import { InputText } from 'primereact/inputtext';
import { Button } from 'primereact/button';
import { Tag } from 'primereact/tag';
import { ProgressSpinner } from 'primereact/progressspinner';
import postData from '@/lib/axios/postData';
import { showError } from '@/lib/tools/generalTools';
import type { TransaksiListItem } from '../page';
import { useSession } from 'next-auth/react';

import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { OverlayPanel } from 'primereact/overlaypanel';

const METODE_ICON: Record<string, string> = {
  tunai: 'pi-wallet',
  debit: 'pi-credit-card',
  kredit: 'pi-credit-card',
  qris: 'pi-qrcode',
  transfer: 'pi-arrow-right-arrow-left',
};

interface KasirSidebarProps {
  toast: React.RefObject<Toast>;
  selectedKodeTrx: string | null;
  refreshKey: number;
  onSelectTrx: (kode: string) => void;
  onNewTrx?: () => void;
  onListChange: (list: TransaksiListItem[]) => void;
  isShiftOpen?: boolean;
  activeShift?: any;
}

const formatRupiah = (val: number | string | null | undefined) => {
  const num = parseFloat(String(val || 0));
  return `Rp ${num.toLocaleString('id-ID')}`;
};

export const KasirSidebar: React.FC<KasirSidebarProps> = ({
  toast,
  selectedKodeTrx,
  refreshKey,
  onSelectTrx,
  onNewTrx,
  onListChange,
  isShiftOpen = true,
  activeShift,
}) => {
  const { data: session } = useSession();
  const [shiftData, setShiftData] = useState<any>(activeShift || null);
  const [list, setList] = useState<TransaksiListItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('semua');
  const todayStr = new Date().toISOString().slice(0, 10);

  useEffect(() => {
    if (activeShift !== undefined) {
      setShiftData(activeShift);
    }
  }, [activeShift]);

  useEffect(() => {
    if (!activeShift && isShiftOpen) {
      postData('/master/kasir-shift/active', {})
        .then((res) => {
          if (res?.data?.data) {
            setShiftData(res.data.data);
          }
        })
        .catch(() => {});
    }
  }, [activeShift, isShiftOpen]);



  const onListChangeRef = useRef(onListChange);
  useEffect(() => {
    onListChangeRef.current = onListChange;
  }, [onListChange]);

  useEffect(() => {
    fetchList();
  }, [refreshKey]);

  const fetchList = async () => {
    setLoading(true);
    try {
      const res = await postData('/master/kasir-list', { tanggal: todayStr, perPage: 100 });
      if (['00', '0000'].includes(res?.data?.status)) {
        const data = res.data.data || [];
        setList(data);
        onListChangeRef.current?.(data);
      } else {
        showError(toast, res?.data?.message || 'Gagal memuat daftar transaksi');
      }
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || err?.message || 'Gagal terhubung ke server');
    } finally {
      setLoading(false);
    }
  };

  const filteredList = list.filter((item) => {
    const statusMatch = filterStatus === 'semua' || item.status === filterStatus;
    const searchMatch =
      !search ||
      item.kode_transaksi?.toLowerCase().includes(search.toLowerCase()) ||
      item.nama_pasien?.toLowerCase().includes(search.toLowerCase()) ||
      item.no_rm?.toLowerCase().includes(search.toLowerCase());
    return statusMatch && searchMatch;
  });

  const getEffectiveNominalLunas = (item: TransaksiListItem) => {
    const isDpDraft = Boolean(item.kode_booking && !item.kode_kunjungan);
    const totalBayar = parseFloat(String(item.total_bayar || 0));
    const dp = parseFloat(String(item.dp_nominal || 0));
    if (isDpDraft) {
      return totalBayar;
    }
    if (dp > 0) {
      return item.sisa_bayar !== undefined && item.sisa_bayar !== null
        ? Math.min(parseFloat(String(item.sisa_bayar)), Math.max(0, totalBayar - dp))
        : Math.max(0, totalBayar - dp);
    }
    return totalBayar;
  };

  const detailPendapatanOp = useRef<OverlayPanel>(null);

  // Akumulasi rincian per metode bayar dari transaksi lunas
  const lunasList = list.filter((item) => item.status === 'lunas');

  const tunaiFromList = lunasList
    .filter((i) => (i.metode_bayar || '').toLowerCase() === 'tunai')
    .reduce((acc, curr) => acc + getEffectiveNominalLunas(curr), 0);

  const qrisFromList = lunasList
    .filter((i) => (i.metode_bayar || '').toLowerCase() === 'qris')
    .reduce((acc, curr) => acc + getEffectiveNominalLunas(curr), 0);

  const transferFromList = lunasList
    .filter((i) => (i.metode_bayar || '').toLowerCase() === 'transfer')
    .reduce((acc, curr) => acc + getEffectiveNominalLunas(curr), 0);

  const debitFromList = lunasList
    .filter((i) => (i.metode_bayar || '').toLowerCase() === 'debit')
    .reduce((acc, curr) => acc + getEffectiveNominalLunas(curr), 0);

  const kreditFromList = lunasList
    .filter((i) => (i.metode_bayar || '').toLowerCase() === 'kredit')
    .reduce((acc, curr) => acc + getEffectiveNominalLunas(curr), 0);

  const otherFromList = lunasList
    .filter((i) => !['tunai', 'qris', 'transfer', 'debit', 'kredit'].includes((i.metode_bayar || '').toLowerCase()))
    .reduce((acc, curr) => acc + getEffectiveNominalLunas(curr), 0);

  // Sinkronisasi data shift aktif dan list transaksi
  const sumTunai = Math.max(parseFloat(String(shiftData?.total_penjualan_tunai || 0)), tunaiFromList);
  const sumQris = Math.max(parseFloat(String(shiftData?.total_qris || 0)), qrisFromList);
  const sumTransfer = Math.max(parseFloat(String(shiftData?.total_transfer || 0)), transferFromList);
  const sumDebit = Math.max(parseFloat(String(shiftData?.total_debit || 0)), debitFromList);
  const sumKredit = Math.max(parseFloat(String(shiftData?.total_kredit || 0)), kreditFromList);

  const totalPendapatan = sumTunai + sumQris + sumTransfer + sumDebit + sumKredit + otherFromList;

  return (
    <div className="flex flex-column h-full w-full user-select-none surface-card border-right-1 surface-border" style={{ minHeight: 0, minWidth: 0 }}>
      {/* Header Stat Bar */}
      <div className="p-3 bg-teal-50 border-bottom-1 surface-border flex-shrink-0">
        <div className="flex align-items-center gap-2 mb-3">
          <div
            style={{
              width: '36px',
              height: '36px',
              borderRadius: '10px',
              background: 'linear-gradient(135deg, #0d9488 0%, #059669 100%)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 2px 6px rgba(13,148,136,0.3)',
              flexShrink: 0,
            }}
          >
            <i className="pi pi-calculator text-white text-base" />
          </div>
          <div className="flex-1 min-w-0 flex flex-column gap-1">
            <div className="flex align-items-center">
              <span
                style={{
                  fontFamily: 'monospace',
                  fontWeight: 800,
                  fontSize: '13px',
                  color: '#0f766e',
                  letterSpacing: '-0.02em',
                  whiteSpace: 'nowrap',
                }}
              >
                {shiftData?.kode_shift || '-'}
              </span>
            </div>
            <div style={{ fontSize: '12px', color: '#475569', lineHeight: 1.25 }}>
              Kasir:{' '}
              <strong
                title={shiftData?.nama_kasir || session?.user?.name || '-'}
                style={{
                  color: '#1e293b',
                  fontWeight: 700,
                  maxWidth: '180px',
                  display: 'inline-block',
                  verticalAlign: 'bottom',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                }}
              >
                {shiftData?.nama_kasir || session?.user?.name || '-'}
              </strong>
            </div>
          </div>
        </div>

        {/* Ringkasan Kas Cepat (Widget Terpadu Sesuai Foto) */}
        <div
          style={{
            padding: '6px 10px',
            height: '52px',
            minHeight: '52px',
            borderRadius: '8px',
            backgroundColor: '#f0fdfa',
            border: '1px solid #ccfbf1',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            width: '100%',
            boxSizing: 'border-box',
          }}
        >
          {/* Konten Widget: Kas Fisik Laci & Pendapatan (Ukuran 50-50 Presisi) */}
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: '1fr 1px 1fr',
              alignItems: 'center',
              gap: '12px',
              width: '100%',
              boxSizing: 'border-box',
            }}
          >
            {/* Kolom Kas Fisik Laci */}
            <div style={{ display: 'flex', flexDirection: 'column', width: '100%', minWidth: 0 }}>
              <span style={{ fontSize: '10px', fontWeight: 800, color: '#0f766e', textTransform: 'uppercase', letterSpacing: '0.04em', lineHeight: 1.15, whiteSpace: 'nowrap' }}>
                Kas Fisik Laci
              </span>
              <span style={{ fontSize: '13.5px', fontWeight: 900, fontFamily: 'monospace', color: '#0f172a', lineHeight: 1.2, marginTop: '2px', whiteSpace: 'nowrap' }}>
                {formatRupiah(shiftData?.kas_diharapkan || 0)}
              </span>
            </div>

            {/* Divider vertikal tipis di tengah */}
            <div style={{ width: '1px', height: '28px', backgroundColor: '#ccfbf1', justifySelf: 'center' }} />

            {/* Kolom Pendapatan (Semua Metode Pembayaran) */}
            <div style={{ display: 'flex', flexDirection: 'column', width: '100%', minWidth: 0, position: 'relative' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%' }}>
                <span style={{ fontSize: '10px', fontWeight: 800, color: '#0f766e', textTransform: 'uppercase', letterSpacing: '0.04em', lineHeight: 1.15, whiteSpace: 'nowrap' }}>
                  Pendapatan
                </span>
                <button
                  type="button"
                  onClick={(e) => detailPendapatanOp.current?.toggle(e)}
                  style={{
                    background: 'none',
                    border: 'none',
                    padding: 0,
                    cursor: 'pointer',
                    display: 'inline-flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    lineHeight: 1,
                  }}
                  className="hover:scale-110 transition-transform"
                  title="Lihat rincian metode pembayaran"
                >
                  <i className="pi pi-exclamation-circle text-xs" style={{ color: '#0f766e', fontSize: '11px' }} />
                </button>
              </div>
              <span style={{ fontSize: '13.5px', fontWeight: 900, fontFamily: 'monospace', color: '#0f172a', lineHeight: 1.2, marginTop: '2px', whiteSpace: 'nowrap' }}>
                {formatRupiah(totalPendapatan)}
              </span>
            </div>
          </div>
        </div>

        {/* OverlayPanel Pop-up Detail Rincian Pendapatan */}
        <OverlayPanel ref={detailPendapatanOp} className="shadow-4 border-round-xl p-0" style={{ width: '280px', maxWidth: '90vw' }}>
          <div className="p-3">
            <div className="flex align-items-center justify-content-between mb-2 pb-2 border-bottom-1 surface-border">
              <div className="flex align-items-center gap-2">
                <div
                  style={{
                    width: '24px',
                    height: '24px',
                    borderRadius: '6px',
                    backgroundColor: '#ccfbf1',
                    color: '#0f766e',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <i className="pi pi-wallet text-xs" />
                </div>
                <span className="font-bold text-xs text-900">Rincian Pembayaran</span>
              </div>
              <span className="text-[10px] text-500 font-medium">Semua Transaksi</span>
            </div>

            <div className="flex flex-column gap-1.5 text-xs">
              {/* Tunai */}
              <div className="flex align-items-center justify-content-between p-2 border-round-lg bg-teal-50 border-1 border-teal-100">
                <span className="flex align-items-center gap-2 font-semibold text-teal-900">
                  <i className="pi pi-wallet text-teal-600 text-xs" />
                  Tunai (Cash)
                </span>
                <strong className="font-mono text-teal-950 font-bold">{formatRupiah(sumTunai)}</strong>
              </div>

              {/* QRIS */}
              <div className="flex align-items-center justify-content-between p-2 border-round-lg bg-purple-50 border-1 border-purple-100">
                <span className="flex align-items-center gap-2 font-semibold text-purple-900">
                  <i className="pi pi-qrcode text-purple-600 text-xs" />
                  QRIS
                </span>
                <strong className="font-mono text-purple-950 font-bold">{formatRupiah(sumQris)}</strong>
              </div>

              {/* Transfer */}
              <div className="flex align-items-center justify-content-between p-2 border-round-lg bg-blue-50 border-1 border-blue-100">
                <span className="flex align-items-center gap-2 font-semibold text-blue-900">
                  <i className="pi pi-arrow-right-arrow-left text-blue-600 text-xs" />
                  Transfer Bank
                </span>
                <strong className="font-mono text-blue-950 font-bold">{formatRupiah(sumTransfer)}</strong>
              </div>

              {/* Kartu Debit */}
              <div className="flex align-items-center justify-content-between p-2 border-round-lg bg-indigo-50 border-1 border-indigo-100">
                <span className="flex align-items-center gap-2 font-semibold text-indigo-900">
                  <i className="pi pi-credit-card text-indigo-600 text-xs" />
                  Kartu Debit
                </span>
                <strong className="font-mono text-indigo-950 font-bold">{formatRupiah(sumDebit)}</strong>
              </div>

              {/* Kartu Kredit */}
              <div className="flex align-items-center justify-content-between p-2 border-round-lg bg-orange-50 border-1 border-orange-100">
                <span className="flex align-items-center gap-2 font-semibold text-orange-900">
                  <i className="pi pi-credit-card text-orange-600 text-xs" />
                  Kartu Kredit
                </span>
                <strong className="font-mono text-orange-950 font-bold">{formatRupiah(sumKredit)}</strong>
              </div>

              {/* Metode Lain jika ada */}
              {otherFromList > 0 && (
                <div className="flex align-items-center justify-content-between p-2 border-round-lg surface-50 border-1 surface-border">
                  <span className="flex align-items-center gap-2 font-semibold text-700">
                    <i className="pi pi-ellipsis-h text-500 text-xs" />
                    Lainnya
                  </span>
                  <strong className="font-mono text-800 font-bold">{formatRupiah(otherFromList)}</strong>
                </div>
              )}
            </div>

            <div className="mt-2.5 pt-2 border-top-1 surface-border flex align-items-center justify-content-between">
              <span className="font-bold text-xs text-800">Total Pendapatan</span>
              <strong className="font-mono text-sm text-teal-800 font-extrabold">{formatRupiah(totalPendapatan)}</strong>
            </div>
          </div>
        </OverlayPanel>

        {/* Tombol Aksi Shift: Catat Kas & Tutup Shift */}
        <div className="flex align-items-center gap-2" style={{ gap: '8px', marginTop: '10px' }}>
          <Button
            label="Catat Kas"
            icon="pi pi-plus-circle"
            size="small"
            outlined
            disabled={!isShiftOpen}
            onClick={() => {
              if (typeof window !== 'undefined') {
                window.dispatchEvent(new Event('trigger-catat-kas-modal'));
              }
            }}
            className="border-round-lg text-[11px] font-bold px-2 py-1.5 text-700 hover:text-900 border-300 flex-1 surface-card shadow-1 justify-content-center"
            style={{ whiteSpace: 'nowrap' }}
          />
          <Button
            label="Tutup Shift"
            icon="pi pi-lock"
            size="small"
            severity="danger"
            disabled={!isShiftOpen}
            onClick={() => {
              if (typeof window !== 'undefined') {
                window.dispatchEvent(new Event('trigger-tutup-shift-modal'));
              }
            }}
            className="border-round-lg font-bold text-[11px] px-2 py-1.5 shadow-1 bg-red-600 border-red-600 hover:bg-red-700 text-white flex-1 justify-content-center"
            style={{ whiteSpace: 'nowrap' }}
          />
        </div>
      </div>

      {/* Filter & Search */}
      <div className="p-3 border-bottom-1 surface-border flex-shrink-0 bg-white">
        <IconField iconPosition="left" className="w-full mb-2">
          <InputIcon className="pi pi-search text-xs text-400" />
          <InputText
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Cari transaksi / pasien / RM..."
            className="p-inputtext-sm w-full border-round-lg text-xs"
          />
        </IconField>

        {/* Status Filter Tabs */}
        <div className="flex gap-1 p-1 bg-slate-100 border-round-lg">
          {[
            { key: 'semua', label: 'Semua' },
            { key: 'draft', label: 'Draft' },
            { key: 'lunas', label: 'Lunas' },
            { key: 'batal', label: 'Batal' },
          ].map((t) => {
            const isActive = filterStatus === t.key;
            return (
              <button
                key={t.key}
                onClick={() => setFilterStatus(t.key)}
                className={`flex-1 py-1 text-xs border-round-md font-bold transition-all border-none cursor-pointer ${
                  isActive ? 'bg-teal-600 text-white shadow-1' : 'bg-transparent text-slate-600 hover:text-slate-900'
                }`}
              >
                {t.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Transaction Cards List */}
      <div
        className="flex-1 overflow-y-auto p-3 surface-ground kasir-scroll-area"
        style={{ minHeight: 0, overscrollBehavior: 'contain' }}
      >
        {loading ? (
          <div className="flex align-items-center justify-content-center py-5">
            <ProgressSpinner style={{ width: '28px', height: '28px' }} />
          </div>
        ) : filteredList.length === 0 ? (
          <div className="flex flex-column align-items-center justify-content-center py-5 text-center">
            <i className="pi pi-inbox text-3xl text-300 mb-2" />
            <span className="text-xs text-500 font-medium">Belum ada transaksi hari ini</span>
          </div>
        ) : (
          <div className="flex flex-column gap-2">
            {filteredList.map((item) => {
              const isSelected = selectedKodeTrx === item.kode_transaksi;
              const isLunas = item.status === 'lunas';
              const isBatal = item.status === 'batal';

              return (
                <div
                  key={item.kode_transaksi}
                  onClick={() => onSelectTrx(item.kode_transaksi)}
                  className={`surface-card p-3 border-round-xl border-1 transition-all cursor-pointer shadow-1 hover:shadow-2 ${
                    isSelected ? 'border-2 border-teal-500 bg-teal-50/50' : 'surface-border'
                  }`}
                >
                  <div className="flex align-items-center justify-content-between mb-1">
                    <span className="font-extrabold text-xs text-teal-900">{item.kode_transaksi}</span>
                    <div className="flex align-items-center gap-1">
                      {item.kode_booking && !item.kode_kunjungan && (
                        <Tag
                          value="DP BOOKING"
                          severity="warning"
                          className="text-[9px] font-bold px-1.5 py-0.5"
                        />
                      )}
                      {parseFloat(String(item.total_bayar || 0)) === 0 && (
                        (item.nama_promo || '').toLowerCase().includes('klaim') ||
                        Boolean(item.kode_kunjungan)
                      ) && (
                        <Tag
                          value="KLAIM SESI"
                          severity="info"
                          className="text-[9px] font-bold px-1.5 py-0.5"
                        />
                      )}
                      <Tag
                        value={item.status.toUpperCase()}
                        severity={isLunas ? 'success' : isBatal ? 'danger' : 'info'}
                        className="text-[10px] font-bold px-2 py-0.5"
                      />
                    </div>
                  </div>

                  <div className="font-bold text-sm text-slate-800 mb-1 overflow-hidden text-ellipsis white-space-nowrap">
                    {item.nama_pasien || item.no_rm}
                  </div>

                  <div className="flex align-items-center justify-content-between text-xs pt-1 border-top-1 surface-border">
                    <span className="text-[11px] text-500">
                      RM: {item.no_rm}
                      {item.kode_booking && <span className="text-teal-600 font-semibold ml-1">({item.kode_booking})</span>}
                    </span>
                    <div className="text-right">
                      {(() => {
                        const isDpDraft = Boolean(item.kode_booking && !item.kode_kunjungan);
                        const totalBayar = parseFloat(String(item.total_bayar || 0));
                        const dp = parseFloat(String(item.dp_nominal || 0));
                        
                        // Jika draf DP booking, nominal yang ditagih kasir adalah total_bayar DP itu sendiri
                        if (isDpDraft) {
                          return (
                            <span className="font-black text-teal-700 block">
                              {formatRupiah(totalBayar)}
                            </span>
                          );
                        }

                        const sisa = dp > 0
                          ? (item.sisa_bayar !== undefined && item.sisa_bayar !== null
                              ? Math.min(parseFloat(String(item.sisa_bayar)), Math.max(0, totalBayar - dp))
                              : Math.max(0, totalBayar - dp))
                          : totalBayar;
                        return (
                          <>
                            <span className="font-black text-teal-700 block">
                              {formatRupiah(dp > 0 ? sisa : totalBayar)}
                            </span>
                            {dp > 0 && (
                              <span className="text-[10px] text-teal-600 font-bold block">
                                DP: -{formatRupiah(dp)}
                              </span>
                            )}
                          </>
                        );
                      })()}
                    </div>
                  </div>

                  {item.metode_bayar && isLunas && (
                    <div className="flex align-items-center gap-1 text-[10px] text-slate-500 mt-1">
                      <i className={`pi ${METODE_ICON[item.metode_bayar] || 'pi-credit-card'}`} style={{ fontSize: '10px' }} />
                      <span className="capitalize">{item.metode_bayar}</span>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};
