'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Toast } from 'primereact/toast';
import postData from '@/lib/axios/postData';
import { showError } from '@/lib/tools/generalTools';

export interface RekomendasiItem {
  jenis: 'layanan' | 'paket_layanan' | 'produk' | 'paket_produk';
  tipe: string;
  kode: string;
  nama: string;
  harga: number;
  harga_asal?: number;
  is_promo?: boolean;
  kode_promo?: string;
  nama_promo?: string;
  jenis_diskon?: 'persen' | 'nominal';
  nilai_diskon?: number;
  qty?: number;
  satuan?: string;
  kode_ruangan?: string;
  nama_ruangan?: string;
  kode_kategori?: string;
  nama_kategori?: string;
  masa_berlaku_hari?: number;
}

interface RekomendasiTreatmentPanelProps {
  toast: React.RefObject<Toast>;
  selectedItems: RekomendasiItem[];
  onChangeSelectedItems: (items: RekomendasiItem[]) => void;
}

type TabKey = 'layanan' | 'paket_layanan' | 'produk' | 'paket_produk';

const TABS: { key: TabKey; label: string; icon: string; accent: string; bgActive: string }[] = [
  { key: 'layanan', label: 'Layanan', icon: 'pi-briefcase', accent: '#0d9488', bgActive: '#f0fdfa' },
  { key: 'paket_layanan', label: 'Paket Layanan', icon: 'pi-box', accent: '#7c3aed', bgActive: '#faf5ff' },
  { key: 'produk', label: 'Produk', icon: 'pi-shopping-bag', accent: '#d97706', bgActive: '#fffbeb' },
  { key: 'paket_produk', label: 'Paket Produk', icon: 'pi-tags', accent: '#4338ca', bgActive: '#eef2ff' },
];

export const RekomendasiTreatmentPanel: React.FC<RekomendasiTreatmentPanelProps> = ({
  toast,
  selectedItems,
  onChangeSelectedItems,
}) => {
  const [loading, setLoading] = useState<boolean>(true);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [activeTab, setActiveTab] = useState<TabKey>('layanan');
  const [selectedRoomFilter, setSelectedRoomFilter] = useState<string>('ALL');
  const [showOnlyPromo, setShowOnlyPromo] = useState<boolean>(false);

  const [options, setOptions] = useState<Record<TabKey, RekomendasiItem[]>>({
    layanan: [],
    paket_layanan: [],
    produk: [],
    paket_produk: [],
  });

  useEffect(() => {
    fetchOptions();
  }, []);

  const fetchOptions = async () => {
    setLoading(true);
    try {
      const res = await postData('/master/ruangan-rekomendasi-options', {});
      if (['00', '0000'].includes(res?.data?.status)) {
        setOptions({
          layanan: res.data.data.layanan || [],
          paket_layanan: res.data.data.paket_layanan || [],
          produk: res.data.data.produk || [],
          paket_produk: res.data.data.paket_produk || [],
        });
      } else {
        showError(toast, res?.data?.message || 'Gagal memuat opsi rekomendasi');
      }
    } catch {
      showError(toast, 'Gagal terhubung ke server untuk opsi rekomendasi');
    } finally {
      setLoading(false);
    }
  };

  const activeTreatmentRoom = useMemo(() => {
    const activeItem = selectedItems.find((s) => ['layanan', 'paket_layanan'].includes(s.jenis));
    if (!activeItem) return null;
    return {
      kode_ruangan: activeItem.kode_ruangan || 'UNASSIGNED',
      nama_ruangan: activeItem.nama_ruangan || activeItem.kode_ruangan || 'Ruang Treatment',
    };
  }, [selectedItems]);

  const roomList = useMemo(() => {
    const roomsMap = new Map<string, string>();
    [...options.layanan, ...options.paket_layanan].forEach((item) => {
      const k = item.kode_ruangan || 'UNASSIGNED';
      const n = item.nama_ruangan || item.kode_ruangan || 'Ruangan Lainnya';
      if (!roomsMap.has(k)) roomsMap.set(k, n);
    });
    return Array.from(roomsMap.entries()).map(([kode, nama]) => ({ kode, nama }));
  }, [options.layanan, options.paket_layanan]);

  const isItemSelected = (item: RekomendasiItem) =>
    selectedItems.some((s) => s.jenis === item.jenis && s.kode === item.kode);

  const handleToggleSelect = (item: RekomendasiItem) => {
    const isService = ['layanan', 'paket_layanan'].includes(item.jenis);
    const exists = isItemSelected(item);

    if (exists) {
      onChangeSelectedItems(selectedItems.filter((s) => !(s.jenis === item.jenis && s.kode === item.kode)));
      return;
    }

    if (isService) {
      const itemRoomCode = item.kode_ruangan || 'UNASSIGNED';
      if (activeTreatmentRoom !== null && activeTreatmentRoom.kode_ruangan !== itemRoomCode) {
        showError(
          toast,
          `Tidak bisa memilih layanan dari ruangan berbeda! Aktif: "${activeTreatmentRoom.nama_ruangan}". Batalkan pilihan sebelumnya terlebih dahulu.`
        );
        return;
      }
    }

    onChangeSelectedItems([...selectedItems, { ...item, qty: item.jenis.includes('produk') ? 1 : undefined }]);
  };

  const handleQtyChange = (item: RekomendasiItem, newQty: number) => {
    const validQty = Math.max(1, newQty || 1);
    onChangeSelectedItems(
      selectedItems.map((s) => (s.jenis === item.jenis && s.kode === item.kode ? { ...s, qty: validQty } : s))
    );
  };

  const filterItems = (list: RekomendasiItem[], checkRoom = false) => {
    let result = list;
    if (checkRoom && selectedRoomFilter !== 'ALL') {
      result = result.filter((i) => (i.kode_ruangan || 'UNASSIGNED') === selectedRoomFilter);
    }
    if (showOnlyPromo) {
      result = result.filter((i) => i.is_promo);
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      result = result.filter(
        (i) =>
          i.nama.toLowerCase().includes(q) ||
          i.kode.toLowerCase().includes(q) ||
          (i.nama_ruangan && i.nama_ruangan.toLowerCase().includes(q)) ||
          (i.nama_kategori && i.nama_kategori.toLowerCase().includes(q)) ||
          (i.nama_promo && i.nama_promo.toLowerCase().includes(q))
      );
    }
    return result;
  };

  const currentTab = TABS.find((t) => t.key === activeTab)!;
  const isServiceTab = activeTab === 'layanan' || activeTab === 'paket_layanan';
  const displayItems = filterItems(options[activeTab], isServiceTab);

  const totalPromoItemsCount = useMemo(() => {
    return Object.values(options).flatMap((arr) => arr).filter((i) => i.is_promo).length;
  }, [options]);

  const countLayanan = selectedItems.filter((s) => ['layanan', 'paket_layanan'].includes(s.jenis)).length;
  const countProduk = selectedItems.filter((s) => ['produk', 'paket_produk'].includes(s.jenis)).length;
  const totalHargaSelected = selectedItems.reduce((sum, i) => sum + i.harga * (i.qty || 1), 0);

  const formatRupiah = (val: number) =>
    new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(val);

  return (
    <div
      className="p-3 border-round-2xl surface-card select-none"
      style={{
        border: '1.5px solid #e2e8f0',
        boxShadow: '0 4px 20px -2px rgba(0, 0, 0, 0.05)',
        userSelect: 'none',
        WebkitUserSelect: 'none',
      }}
    >
      {/* ── HEADER ── */}
      <div className="flex align-items-center justify-content-between mb-3 pb-2 border-bottom-1 surface-border">
        <div className="flex align-items-center gap-2.5">
          <div
            className="flex align-items-center justify-content-center border-round-xl"
            style={{
              width: '36px',
              height: '36px',
              background: 'linear-gradient(135deg, #0d9488, #059669)',
              boxShadow: '0 2px 8px rgba(13, 148, 136, 0.25)',
            }}
          >
            <i className="pi pi-sparkles text-white text-base" />
          </div>
          <div>
            <span style={{ fontSize: '13.5px', fontWeight: 800, color: '#0f172a', display: 'block', lineHeight: 1.2 }}>
              Treatment &amp; Produk Rekomendasi
            </span>
            <span style={{ fontSize: '11px', color: '#64748b', fontWeight: 500 }}>
              Pilih tindakan lanjut &amp; produk untuk pasien ini
            </span>
          </div>
        </div>

        <div className="flex align-items-center gap-2">
          {totalPromoItemsCount > 0 && (
            <span
              className="inline-flex align-items-center gap-1.5 text-xs font-bold px-2.5 py-1 border-round-pill cursor-pointer"
              style={{
                background: showOnlyPromo ? 'linear-gradient(135deg, #ef4444, #f97316)' : '#fff1f2',
                color: showOnlyPromo ? '#ffffff' : '#e11d48',
                border: '1px solid #fecdd3',
                boxShadow: showOnlyPromo ? '0 2px 8px rgba(239,68,68,0.3)' : 'none',
              }}
              onClick={() => setShowOnlyPromo(!showOnlyPromo)}
            >
              <i className="pi pi-percentage text-xs" />
              {totalPromoItemsCount} Promo Aktif
            </span>
          )}
          {countLayanan > 0 && (
            <span
              className="inline-flex align-items-center gap-1.5 text-xs font-bold px-2.5 py-1 border-round-pill"
              style={{ background: '#ccfbf1', color: '#0f766e', border: '1px solid #99f6e4' }}
            >
              <i className="pi pi-ticket text-xs" />
              {countLayanan} Antrean
            </span>
          )}
          {countProduk > 0 && (
            <span
              className="inline-flex align-items-center gap-1.5 text-xs font-bold px-2.5 py-1 border-round-pill"
              style={{ background: '#fef3c7', color: '#b45309', border: '1px solid #fde68a' }}
            >
              <i className="pi pi-shopping-bag text-xs" />
              {countProduk} Produk
            </span>
          )}
        </div>
      </div>

      {/* ── SEARCH & PROMO FILTER TOGGLE ── */}
      <div className="flex gap-2 mb-3">
        <div className="p-inputgroup flex-1">
          <span className="p-inputgroup-addon" style={{ background: '#f8fafc', border: '1.5px solid #cbd5e1', borderRight: 'none', borderRadius: '12px 0 0 12px' }}>
            <i className="pi pi-search text-gray-400 text-xs" />
          </span>
          <InputText
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Cari layanan, paket, produk, atau nama promo..."
            style={{
              fontSize: '13px',
              border: '1.5px solid #cbd5e1',
              borderLeft: 'none',
              borderRight: searchQuery ? 'none' : '1.5px solid #cbd5e1',
              borderRadius: searchQuery ? '0' : '0 12px 12px 0',
              boxShadow: 'none',
            }}
          />
          {searchQuery && (
            <Button
              icon="pi pi-times"
              className="p-button-text p-button-secondary p-button-sm"
              onClick={() => setSearchQuery('')}
              style={{ border: '1.5px solid #cbd5e1', borderLeft: 'none', borderRadius: '0 12px 12px 0' }}
            />
          )}
        </div>

        <button
          type="button"
          onClick={() => setShowOnlyPromo(!showOnlyPromo)}
          style={{
            padding: '0 14px',
            borderRadius: '12px',
            fontSize: '12px',
            fontWeight: 700,
            border: showOnlyPromo ? '1.5px solid #ef4444' : '1.5px solid #cbd5e1',
            background: showOnlyPromo ? 'linear-gradient(135deg, #ef4444, #f97316)' : '#ffffff',
            color: showOnlyPromo ? '#ffffff' : '#e11d48',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            transition: 'all 0.18s ease',
            whiteSpace: 'nowrap',
          }}
        >
          <i className="pi pi-percentage" style={{ fontSize: '11px' }} />
          Hanya Promo 🔥
        </button>
      </div>

      {/* ── ROOM LOCK BANNER ── */}
      {activeTreatmentRoom && (
        <div
          className="flex align-items-center gap-2 mb-3 px-3 py-2 border-round-xl text-xs font-medium"
          style={{ background: 'linear-gradient(90deg, #f0fdfa, #ecfdf5)', border: '1.5px solid #6ee7b7', color: '#065f46' }}
        >
          <i className="pi pi-lock" style={{ color: '#059669', fontSize: '12px' }} />
          <span>
            Ruangan Aktif: <strong>{activeTreatmentRoom.nama_ruangan}</strong>
            <span className="ml-2 font-normal text-gray-500">— Layanan dari ruangan lain terkunci</span>
          </span>
        </div>
      )}

      {/* ── CUSTOM TABS ── */}
      <div className="flex gap-1.5 mb-3 p-1 border-round-xl overflow-x-auto" style={{ background: '#f1f5f9', border: '1px solid #e2e8f0' }}>
        {TABS.map((tab) => {
          const count = filterItems(options[tab.key], tab.key === 'layanan' || tab.key === 'paket_layanan').length;
          const isActive = activeTab === tab.key;
          return (
            <button
              key={tab.key}
              type="button"
              onClick={() => {
                setActiveTab(tab.key);
                setSelectedRoomFilter('ALL');
              }}
              style={{
                flex: 1,
                minWidth: '110px',
                padding: '8px 10px',
                borderRadius: '10px',
                border: isActive ? `1.5px solid ${tab.accent}` : '1.5px solid transparent',
                background: isActive ? '#ffffff' : 'transparent',
                cursor: 'pointer',
                transition: 'all 0.18s ease',
                boxShadow: isActive ? '0 2px 8px rgba(0, 0, 0, 0.06)' : 'none',
                userSelect: 'none',
              }}
            >
              <div className="flex align-items-center justify-content-center gap-1.5">
                <i
                  className={`pi ${tab.icon}`}
                  style={{ fontSize: '13px', color: isActive ? tab.accent : '#94a3b8' }}
                />
                <span
                  style={{
                    fontSize: '12px',
                    fontWeight: isActive ? 700 : 600,
                    color: isActive ? tab.accent : '#64748b',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {tab.label}
                </span>
                {count > 0 && (
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 800,
                      padding: '1px 6px',
                      borderRadius: '999px',
                      background: isActive ? tab.accent : '#cbd5e1',
                      color: '#ffffff',
                      lineHeight: 1.3,
                      marginLeft: '2px',
                    }}
                  >
                    {count}
                  </span>
                )}
              </div>
            </button>
          );
        })}
      </div>

      {/* ── ROOM FILTER PILLS (only for service tabs) ── */}
      {isServiceTab && roomList.length > 0 && (
        <div className="flex align-items-center gap-1.5 flex-wrap mb-3">
          <span className="text-xs font-bold text-gray-500 mr-1 flex align-items-center gap-1">
            <i className="pi pi-filter text-xs" />
            Ruangan:
          </span>
          {[{ kode: 'ALL', nama: 'Semua' }, ...roomList].map((r) => {
            const isActive = selectedRoomFilter === r.kode;
            const isLocked = r.kode !== 'ALL' && activeTreatmentRoom !== null && activeTreatmentRoom.kode_ruangan !== r.kode;
            return (
              <button
                key={r.kode}
                type="button"
                onClick={() => setSelectedRoomFilter(r.kode)}
                style={{
                  padding: '4px 12px',
                  fontSize: '11.5px',
                  fontWeight: 600,
                  borderRadius: '999px',
                  border: isActive ? `1.5px solid ${currentTab.accent}` : '1.5px solid #cbd5e1',
                  background: isActive ? currentTab.accent : isLocked ? '#f8fafc' : '#ffffff',
                  color: isActive ? '#ffffff' : isLocked ? '#94a3b8' : '#334155',
                  cursor: 'pointer',
                  opacity: isLocked ? 0.6 : 1,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  transition: 'all 0.15s ease',
                  userSelect: 'none',
                }}
              >
                {isLocked && <i className="pi pi-lock" style={{ fontSize: '9px' }} />}
                {r.nama}
              </button>
            );
          })}
        </div>
      )}

      {/* ── ITEMS GRID ── */}
      {loading ? (
        <div className="flex align-items-center justify-content-center py-5">
          <ProgressSpinner style={{ width: '28px', height: '28px' }} />
          <span className="ml-2 text-xs font-semibold text-gray-400">Memuat katalog...</span>
        </div>
      ) : displayItems.length === 0 ? (
        <div
          className="flex flex-column align-items-center justify-content-center py-5 border-round-xl text-center"
          style={{ background: '#f8fafc', border: '1.5px dashed #cbd5e1' }}
        >
          <i className="pi pi-inbox text-3xl mb-2" style={{ color: '#cbd5e1' }} />
          <span className="text-xs font-semibold text-gray-400">
            {showOnlyPromo ? 'Tidak ada promo aktif untuk kategori ini' : `Tidak ada ${currentTab.label.toLowerCase()} ditemukan`}
          </span>
        </div>
      ) : (
        <div className="grid formgrid overflow-y-auto pr-1" style={{ maxHeight: '22rem' }}>
          {displayItems.map((item) => {
            const selected = isItemSelected(item);
            const selectedObj = selectedItems.find((s) => s.jenis === item.jenis && s.kode === item.kode);
            const isLocked =
              isServiceTab &&
              activeTreatmentRoom !== null &&
              !selected &&
              (item.kode_ruangan || 'UNASSIGNED') !== activeTreatmentRoom.kode_ruangan;
            const isProduk = activeTab === 'produk' || activeTab === 'paket_produk';

            return (
              <div key={item.kode} className="col-12 sm:col-6 md:col-4 mb-2 p-1">
                <div
                  onClick={() => !isLocked && handleToggleSelect(item)}
                  style={{
                    borderRadius: '12px',
                    border: selected
                      ? `2px solid ${item.is_promo ? '#ef4444' : currentTab.accent}`
                      : isLocked
                      ? '1.5px solid #e2e8f0'
                      : item.is_promo
                      ? '1.5px solid #fca5a5'
                      : '1.5px solid #e2e8f0',
                    background: selected ? currentTab.bgActive : isLocked ? '#f8fafc' : item.is_promo ? '#fff1f2' : '#ffffff',
                    padding: '12px 14px',
                    cursor: isLocked ? 'not-allowed' : 'pointer',
                    opacity: isLocked ? 0.55 : 1,
                    boxShadow: selected ? `0 4px 14px -2px ${currentTab.accent}30` : '0 1px 3px rgba(0, 0, 0, 0.03)',
                    transition: 'all 0.15s ease',
                    height: '100%',
                    display: 'flex',
                    flexDirection: 'column',
                    justifyContent: 'space-between',
                    position: 'relative',
                    userSelect: 'none',
                  }}
                >
                  {/* Selected checkmark badge */}
                  {selected && (
                    <span
                      style={{
                        position: 'absolute',
                        top: '10px',
                        right: '10px',
                        width: '20px',
                        height: '20px',
                        borderRadius: '50%',
                        background: item.is_promo ? '#ef4444' : currentTab.accent,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        boxShadow: `0 2px 6px ${item.is_promo ? '#ef4444' : currentTab.accent}40`,
                      }}
                    >
                      <i className="pi pi-check text-white" style={{ fontSize: '10px', fontWeight: 900 }} />
                    </span>
                  )}

                  {/* Locked badge */}
                  {isLocked && (
                    <span
                      style={{
                        position: 'absolute',
                        top: '10px',
                        right: '10px',
                        background: '#f1f5f9',
                        borderRadius: '6px',
                        padding: '2px 6px',
                        fontSize: '9px',
                        color: '#94a3b8',
                        fontWeight: 700,
                        display: 'flex',
                        alignItems: 'center',
                        gap: '3px',
                      }}
                    >
                      <i className="pi pi-lock" style={{ fontSize: '9px' }} />
                      TERKUNCI
                    </span>
                  )}

                  {/* ITEM INFO */}
                  <div style={{ paddingRight: selected || isLocked ? '26px' : '0' }}>
                    {item.is_promo && (
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '3px',
                          fontSize: '9.5px',
                          fontWeight: 800,
                          padding: '2px 7px',
                          borderRadius: '6px',
                          marginBottom: '4px',
                          marginRight: '4px',
                          background: 'linear-gradient(135deg, #ef4444, #f97316)',
                          color: '#ffffff',
                          boxShadow: '0 2px 6px rgba(239, 68, 68, 0.25)',
                          letterSpacing: '0.02em',
                        }}
                      >
                        <i className="pi pi-percentage text-white" style={{ fontSize: '9px' }} />
                        PROMO {item.jenis_diskon === 'persen' ? `-${item.nilai_diskon}%` : ''}
                      </span>
                    )}

                    {(activeTab === 'paket_layanan' || activeTab === 'paket_produk') && (
                      <span
                        style={{
                          display: 'inline-block',
                          fontSize: '9.5px',
                          fontWeight: 800,
                          padding: '2px 7px',
                          borderRadius: '6px',
                          marginBottom: '4px',
                          background: `${currentTab.accent}18`,
                          color: currentTab.accent,
                          letterSpacing: '0.03em',
                        }}
                      >
                        {activeTab === 'paket_layanan' ? 'PAKET LAYANAN' : 'PAKET PRODUK'}
                      </span>
                    )}

                    <div
                      style={{
                        fontSize: '13px',
                        fontWeight: 700,
                        color: '#0f172a',
                        lineHeight: 1.35,
                        marginBottom: '3px',
                      }}
                    >
                      {item.nama}
                    </div>
                    <div style={{ fontSize: '11px', color: '#64748b', fontWeight: 500 }}>
                      {item.nama_promo ? `${item.nama_promo} • ` : ''}
                      {item.nama_kategori || currentTab.label}
                      {isProduk && item.satuan ? ` • ${item.satuan}` : ''}
                    </div>
                  </div>

                  {/* FOOTER */}
                  <div
                    style={{
                      marginTop: '10px',
                      paddingTop: '8px',
                      borderTop: '1px solid #f1f5f9',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      gap: '6px',
                    }}
                  >
                    <div>
                      {item.is_promo && item.harga_asal && item.harga_asal > item.harga && (
                        <span
                          style={{
                            fontSize: '11px',
                            color: '#94a3b8',
                            textDecoration: 'line-through',
                            marginRight: '5px',
                            fontWeight: 600,
                          }}
                        >
                          {formatRupiah(item.harga_asal)}
                        </span>
                      )}
                      <span
                        style={{
                          fontSize: '13px',
                          fontWeight: 800,
                          color: item.is_promo ? '#e11d48' : currentTab.accent,
                        }}
                      >
                        {formatRupiah(item.harga)}
                      </span>
                    </div>

                    {isServiceTab && (
                      <span
                        style={{
                          fontSize: '10px',
                          fontWeight: 600,
                          padding: '2px 8px',
                          borderRadius: '999px',
                          background: selected ? currentTab.accent : `${currentTab.accent}15`,
                          color: selected ? '#ffffff' : currentTab.accent,
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '4px',
                          maxWidth: '120px',
                          overflow: 'hidden',
                          whiteSpace: 'nowrap',
                        }}
                        title={item.nama_ruangan || 'Ruangan'}
                      >
                        <i className="pi pi-building flex-shrink-0" style={{ fontSize: '9px' }} />
                        <span style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>
                          {item.nama_ruangan || 'Ruangan'}
                        </span>
                      </span>
                    )}

                    {isProduk && selected && (
                      <div className="flex align-items-center gap-1" onClick={(e) => e.stopPropagation()}>
                        <button
                          type="button"
                          onClick={() => handleQtyChange(item, (selectedObj?.qty || 1) - 1)}
                          style={{
                            width: '22px',
                            height: '22px',
                            borderRadius: '6px',
                            border: '1.5px solid #cbd5e1',
                            background: '#f8fafc',
                            cursor: 'pointer',
                            fontSize: '12px',
                            fontWeight: 700,
                            color: '#334155',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                          }}
                        >
                          −
                        </button>
                        <span
                          style={{
                            minWidth: '24px',
                            textAlign: 'center',
                            fontSize: '12px',
                            fontWeight: 800,
                            color: currentTab.accent,
                          }}
                        >
                          {selectedObj?.qty || 1}
                        </span>
                        <button
                          type="button"
                          onClick={() => handleQtyChange(item, (selectedObj?.qty || 1) + 1)}
                          style={{
                            width: '22px',
                            height: '22px',
                            borderRadius: '6px',
                            border: `1.5px solid ${currentTab.accent}`,
                            background: currentTab.accent,
                            cursor: 'pointer',
                            fontSize: '12px',
                            fontWeight: 700,
                            color: '#ffffff',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                          }}
                        >
                          +
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* ── SELECTED SUMMARY BAR ── */}
      {selectedItems.length > 0 && (
        <div
          className="mt-3 select-none"
          style={{
            background: 'linear-gradient(135deg, #f8fafc, #f0fdfa)',
            border: '1.5px solid #99f6e4',
            borderRadius: '14px',
            padding: '12px 14px',
          }}
        >
          <div className="flex align-items-center justify-content-between mb-2">
            <div className="flex align-items-center gap-2">
              <span
                style={{
                  width: '22px',
                  height: '22px',
                  borderRadius: '7px',
                  background: '#0d9488',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <i className="pi pi-check text-white text-xs" />
              </span>
              <div>
                <span style={{ fontSize: '12px', fontWeight: 800, color: '#0f766e' }}>
                  {selectedItems.length} Item Terpilih
                </span>
                <span style={{ fontSize: '12px', color: '#475569', marginLeft: '6px' }}>
                  • Total: <strong style={{ color: '#0d9488' }}>{formatRupiah(totalHargaSelected)}</strong>
                </span>
              </div>
            </div>
            <button
              type="button"
              onClick={() => onChangeSelectedItems([])}
              style={{
                fontSize: '11px',
                fontWeight: 700,
                color: '#ef4444',
                background: 'none',
                border: 'none',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
              }}
            >
              <i className="pi pi-trash" style={{ fontSize: '11px' }} />
              Reset
            </button>
          </div>

          <div className="flex flex-wrap gap-1.5">
            {selectedItems.map((item) => {
              const isLayanan = ['layanan', 'paket_layanan'].includes(item.jenis);
              return (
                <span
                  key={`${item.jenis}_${item.kode}`}
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '5px',
                    fontSize: '11px',
                    fontWeight: 600,
                    padding: '4px 10px',
                    borderRadius: '999px',
                    background: isLayanan ? '#ccfbf1' : '#fef3c7',
                    border: isLayanan ? '1.5px solid #5eead4' : '1.5px solid #fcd34d',
                    color: isLayanan ? '#134e4a' : '#78350f',
                  }}
                >
                  <i
                    className={`pi ${isLayanan ? 'pi-ticket' : 'pi-shopping-bag'}`}
                    style={{ fontSize: '10px', color: isLayanan ? '#0d9488' : '#d97706' }}
                  />
                  {item.nama}
                  {item.is_promo && (
                    <span
                      style={{
                        background: '#ef4444',
                        color: '#ffffff',
                        borderRadius: '999px',
                        padding: '1px 5px',
                        fontSize: '9px',
                        fontWeight: 800,
                      }}
                    >
                      PROMO
                    </span>
                  )}
                  {item.qty && item.qty > 1 && (
                    <span
                      style={{
                        background: '#d97706',
                        color: '#ffffff',
                        borderRadius: '999px',
                        padding: '1px 5px',
                        fontSize: '10px',
                        fontWeight: 800,
                      }}
                    >
                      x{item.qty}
                    </span>
                  )}
                  <span style={{ fontWeight: 800 }}>{formatRupiah(item.harga * (item.qty || 1))}</span>
                  <i
                    className="pi pi-times"
                    onClick={() => handleToggleSelect(item)}
                    style={{ fontSize: '10px', color: '#ef4444', cursor: 'pointer', marginLeft: '2px' }}
                  />
                </span>
              );
            })}
          </div>

          <div
            className="flex flex-column sm:flex-row gap-2 mt-2 pt-2"
            style={{ borderTop: '1px solid #99f6e4', fontSize: '11px', color: '#475569' }}
          >
            {countLayanan > 0 && (
              <span style={{ color: '#065f46', display: 'flex', alignItems: 'center', gap: '5px', fontWeight: 500 }}>
                <i className="pi pi-ticket" style={{ color: '#0d9488', fontSize: '11px' }} />
                {countLayanan} tindakan → <strong>Nomor Antrean ({activeTreatmentRoom?.nama_ruangan})</strong>
              </span>
            )}
            {countProduk > 0 && (
              <span style={{ color: '#78350f', display: 'flex', alignItems: 'center', gap: '5px', fontWeight: 500 }}>
                <i className="pi pi-shopping-bag" style={{ color: '#d97706', fontSize: '11px' }} />
                {countProduk} produk → <strong>Draf Transaksi Kasir</strong>
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
