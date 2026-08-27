'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Toast } from 'primereact/toast';
import { InputText } from 'primereact/inputtext';
import { Button } from 'primereact/button';
import { ProgressSpinner } from 'primereact/progressspinner';
import postData from '@/lib/axios/postData';
import { showError } from '@/lib/tools/generalTools';
import type { TransaksiListItem } from '../page';

const STATUS_CONFIG: Record<string, { label: string; bg: string; color: string; dot: string }> = {
  draft: { label: 'DRAFT', bg: '#f1f5f9', color: '#475569', dot: '#94a3b8' },
  lunas: { label: 'LUNAS', bg: '#dcfce7', color: '#15803d', dot: '#22c55e' },
  batal: { label: 'BATAL', bg: '#fee2e2', color: '#b91c1c', dot: '#ef4444' },
};

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
  onNewTrx: () => void;
  onListChange: (list: TransaksiListItem[]) => void;
}

const formatRupiah = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(val || 0);

export const KasirSidebar: React.FC<KasirSidebarProps> = ({
  toast,
  selectedKodeTrx,
  refreshKey,
  onSelectTrx,
  onNewTrx,
  onListChange,
}) => {
  const [list, setList] = useState<TransaksiListItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('semua');
  const todayStr = new Date().toISOString().slice(0, 10);

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
        onListChange(data);
      } else {
        showError(toast, res?.data?.message || 'Gagal memuat daftar transaksi');
      }
    } catch {
      showError(toast, 'Gagal terhubung ke server');
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

  const totalDraft = list.filter((i) => i.status === 'draft').length;
  const totalLunas = list.filter((i) => i.status === 'lunas').length;
  const totalPendapatan = list.filter((i) => i.status === 'lunas').reduce((s, i) => s + parseFloat(String(i.total_bayar || 0)), 0);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%', userSelect: 'none' }}>
      {/* HEADER */}
      <div
        style={{
          padding: '16px 16px 12px',
          background: 'linear-gradient(135deg, #0f172a, #1e293b)',
          flexShrink: 0,
        }}
      >
        <div className="flex align-items-center justify-content-between mb-3">
          <div className="flex align-items-center gap-2">
            <div
              style={{
                width: '34px',
                height: '34px',
                borderRadius: '10px',
                background: 'linear-gradient(135deg, #0d9488, #059669)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 2px 8px rgba(13,148,136,0.3)',
              }}
            >
              <i className="pi pi-calculator text-white" style={{ fontSize: '15px' }} />
            </div>
            <div>
              <div style={{ fontSize: '14px', fontWeight: 800, color: '#ffffff' }}>Kasir</div>
              <div style={{ fontSize: '11px', color: '#94a3b8', fontWeight: 400 }}>
                {new Date().toLocaleDateString('id-ID', { weekday: 'short', day: '2-digit', month: 'short', year: 'numeric' })}
              </div>
            </div>
          </div>
          <Button
            icon="pi pi-plus"
            label="Baru"
            className="p-button-sm p-button-outlined"
            onClick={onNewTrx}
            style={{
              border: '1.5px solid #0d9488',
              color: '#0d9488',
              background: 'transparent',
              fontSize: '12px',
              fontWeight: 700,
              padding: '6px 12px',
              borderRadius: '8px',
            }}
          />
        </div>

        {/* Ringkasan hari ini */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr 1fr',
            gap: '6px',
          }}
        >
          {[
            { label: 'Draft', value: totalDraft, color: '#94a3b8' },
            { label: 'Lunas', value: totalLunas, color: '#22c55e' },
            { label: 'Pendapatan', value: formatRupiah(totalPendapatan), color: '#0d9488', small: true },
          ].map((s) => (
            <div
              key={s.label}
              style={{
                background: 'rgba(255,255,255,0.07)',
                borderRadius: '8px',
                padding: '8px 8px 6px',
                textAlign: 'center',
                border: '1px solid rgba(255,255,255,0.08)',
              }}
            >
              <div style={{ fontSize: s.small ? '10px' : '16px', fontWeight: 800, color: s.color, lineHeight: 1.2 }}>
                {s.value}
              </div>
              <div style={{ fontSize: '10px', color: '#64748b', fontWeight: 500, marginTop: '2px' }}>{s.label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* SEARCH + FILTER */}
      <div style={{ padding: '10px 12px', borderBottom: '1px solid #f1f5f9', background: '#fafafa', flexShrink: 0 }}>
        <div className="p-inputgroup mb-2">
          <span className="p-inputgroup-addon" style={{ background: '#f1f5f9', border: '1.5px solid #e2e8f0', borderRight: 'none', borderRadius: '8px 0 0 8px' }}>
            <i className="pi pi-search text-gray-400 text-xs" />
          </span>
          <InputText
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Cari pasien / kode..."
            style={{ fontSize: '12px', border: '1.5px solid #e2e8f0', borderLeft: 'none', borderRadius: '0 8px 8px 0', boxShadow: 'none' }}
          />
        </div>

        <div className="flex gap-1">
          {['semua', 'draft', 'lunas', 'batal'].map((s) => (
            <button
              key={s}
              onClick={() => setFilterStatus(s)}
              style={{
                flex: 1,
                padding: '5px 4px',
                fontSize: '11px',
                fontWeight: 700,
                borderRadius: '6px',
                border: filterStatus === s ? `1.5px solid ${s === 'lunas' ? '#22c55e' : s === 'draft' ? '#0d9488' : s === 'batal' ? '#ef4444' : '#0d9488'}` : '1.5px solid #e2e8f0',
                background: filterStatus === s ? (s === 'lunas' ? '#dcfce7' : s === 'draft' ? '#f0fdfa' : s === 'batal' ? '#fee2e2' : '#f0fdfa') : '#ffffff',
                color: filterStatus === s ? (s === 'lunas' ? '#15803d' : s === 'draft' ? '#0d9488' : s === 'batal' ? '#b91c1c' : '#0d9488') : '#64748b',
                cursor: 'pointer',
                textTransform: 'capitalize',
              }}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {/* LIST */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 10px' }}>
        {loading ? (
          <div className="flex align-items-center justify-content-center py-5">
            <ProgressSpinner style={{ width: '24px', height: '24px' }} />
            <span className="ml-2 text-xs text-gray-400">Memuat...</span>
          </div>
        ) : filteredList.length === 0 ? (
          <div className="flex flex-column align-items-center justify-content-center py-5 text-center">
            <i className="pi pi-receipt text-3xl mb-2" style={{ color: '#cbd5e1' }} />
            <span className="text-xs text-gray-400">Belum ada transaksi hari ini</span>
          </div>
        ) : (
          filteredList.map((item) => {
            const cfg = STATUS_CONFIG[item.status] || STATUS_CONFIG.draft;
            const isSelected = selectedKodeTrx === item.kode_transaksi;
            return (
              <div
                key={item.kode_transaksi}
                onClick={() => onSelectTrx(item.kode_transaksi)}
                style={{
                  borderRadius: '10px',
                  border: isSelected ? '2px solid #0d9488' : '1.5px solid #e2e8f0',
                  background: isSelected ? '#f0fdfa' : '#ffffff',
                  padding: '10px 12px',
                  marginBottom: '6px',
                  cursor: 'pointer',
                  transition: 'all 0.15s ease',
                  boxShadow: isSelected ? '0 0 0 3px rgba(13,148,136,0.12)' : '0 1px 3px rgba(0,0,0,0.04)',
                }}
              >
                <div className="flex align-items-center justify-content-between mb-1">
                  <span style={{ fontSize: '11.5px', fontWeight: 800, color: isSelected ? '#0d9488' : '#0f172a' }}>
                    {item.kode_transaksi}
                  </span>
                  <span
                    style={{
                      fontSize: '9.5px',
                      fontWeight: 800,
                      padding: '2px 7px',
                      borderRadius: '999px',
                      background: cfg.bg,
                      color: cfg.color,
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '4px',
                    }}
                  >
                    <span style={{ width: '5px', height: '5px', borderRadius: '50%', background: cfg.dot, display: 'inline-block' }} />
                    {cfg.label}
                  </span>
                </div>

                <div style={{ fontSize: '13px', fontWeight: 700, color: '#1e293b', marginBottom: '2px' }}>
                  {item.nama_pasien || '-'}
                </div>
                <div style={{ fontSize: '11px', color: '#64748b', marginBottom: '6px' }}>
                  {item.no_rm}
                </div>

                <div className="flex align-items-center justify-content-between">
                  <span style={{ fontSize: '13px', fontWeight: 800, color: item.status === 'lunas' ? '#15803d' : '#0d9488' }}>
                    {formatRupiah(parseFloat(String(item.total_bayar || 0)))}
                  </span>
                  {item.metode_bayar && (
                    <span className="flex align-items-center gap-1" style={{ fontSize: '10.5px', color: '#64748b' }}>
                      <i className={`pi ${METODE_ICON[item.metode_bayar] || 'pi-money-bill'}`} style={{ fontSize: '11px' }} />
                      {item.metode_bayar}
                    </span>
                  )}
                </div>
              </div>
            );
          })
        )}
      </div>
    </div>
  );
};
