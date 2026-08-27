'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { Toast } from 'primereact/toast';
import { Dropdown } from 'primereact/dropdown';
import { InputText } from 'primereact/inputtext';
import { Button } from 'primereact/button';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Tag } from 'primereact/tag';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import type { CartItem } from '../page';

interface KunjunganOption {
  kode_kunjungan: string;
  no_rm: string;
  nama_pasien: string;
  no_hp: string;
  jam_datang: string;
}

interface ItemOption {
  jenis: 'layanan' | 'produk';
  kode: string;
  nama: string;
  nama_kategori?: string;
  satuan?: string;
  harga: number;
  harga_asal?: number;
  is_promo?: boolean;
  nama_promo?: string;
  jenis_diskon?: string;
  nilai_diskon?: number;
  harga_promo?: number | null;
}

interface KasirPOSPanelProps {
  toast: React.RefObject<Toast>;
  kode_transaksi: string | null;
  onDraftSaved: (kode: string) => void;
  onOpenBayar: (payload: {
    kode_transaksi: string;
    total_bayar: number;
    nama_pasien: string;
    no_rm: string;
    items: CartItem[];
    kode_promo?: string | null;
    nama_promo?: string | null;
    total_diskon?: number;
  }) => void;
}

const formatRupiah = (val: number) =>
  new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(val || 0);

export const KasirPOSPanel: React.FC<KasirPOSPanelProps> = ({
  toast,
  kode_transaksi,
  onDraftSaved,
  onOpenBayar,
}) => {
  const [loadingOptions, setLoadingOptions] = useState(false);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [savingDraft, setSavingDraft] = useState(false);

  const [kunjunganList, setKunjunganList] = useState<KunjunganOption[]>([]);
  const [layananList, setLayananList] = useState<ItemOption[]>([]);
  const [produkList, setProdukList] = useState<ItemOption[]>([]);

  const [selectedKunjungan, setSelectedKunjungan] = useState<KunjunganOption | null>(null);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [searchItem, setSearchItem] = useState('');
  const [activeItemTab, setActiveItemTab] = useState<'layanan' | 'produk'>('layanan');
  const [editingKodeTrx, setEditingKodeTrx] = useState<string | null>(null);
  const [trxStatus, setTrxStatus] = useState<'draft' | 'lunas' | 'batal' | null>(null);
  const [appliedPromo, setAppliedPromo] = useState<{ kode_promo: string; nama_promo: string; jenis_diskon: string; nilai_diskon: number } | null>(null);

  useEffect(() => {
    fetchOptions();
  }, []);

  useEffect(() => {
    if (kode_transaksi) {
      fetchDetail(kode_transaksi);
    } else {
      resetForm();
    }
  }, [kode_transaksi]);

  const resetForm = () => {
    setSelectedKunjungan(null);
    setCart([]);
    setEditingKodeTrx(null);
    setTrxStatus(null);
    setAppliedPromo(null);
    setSearchItem('');
  };

  const fetchOptions = async () => {
    setLoadingOptions(true);
    try {
      const res = await postData('/master/kasir-options', {});
      if (['00', '0000'].includes(res?.data?.status)) {
        setKunjunganList(res.data.data.kunjungan || []);
        setLayananList(res.data.data.layanan || []);
        setProdukList(res.data.data.produk || []);
      }
    } catch {
      showError(toast, 'Gagal memuat opsi kasir');
    } finally {
      setLoadingOptions(false);
    }
  };

  const fetchDetail = async (kode: string) => {
    setLoadingDetail(true);
    try {
      const res = await postData('/master/kasir-detail', { kode_transaksi: kode });
      if (['00', '0000'].includes(res?.data?.status)) {
        const trx = res.data.data;
        setEditingKodeTrx(trx.kode_transaksi);
        setTrxStatus(trx.status);

        // Re-populate pasien
        const kunjungan = kunjunganList.find((k) => k.kode_kunjungan === trx.kode_kunjungan) ||
          (trx.kode_kunjungan ? {
            kode_kunjungan: trx.kode_kunjungan,
            no_rm: trx.no_rm,
            nama_pasien: trx.nama_pasien || trx.no_rm,
            no_hp: trx.no_hp || '',
            jam_datang: '',
          } : null);
        setSelectedKunjungan(kunjungan);

        // Populate cart
        const cartItems: CartItem[] = (trx.details || []).map((d: any) => ({
          jenis: d.jenis,
          kode: d.kode,
          nama: d.nama,
          satuan: d.satuan || (d.jenis === 'layanan' ? 'tindakan' : 'pcs'),
          qty: d.qty,
          harga_satuan: parseFloat(d.harga_satuan),
          subtotal: parseFloat(d.subtotal),
        }));
        setCart(cartItems);

        if (trx.kode_promo) {
          setAppliedPromo({
            kode_promo: trx.kode_promo,
            nama_promo: trx.nama_promo || trx.kode_promo,
            jenis_diskon: trx.jenis_diskon || 'persen',
            nilai_diskon: parseFloat(trx.nilai_diskon_promo || 0),
          });
        } else {
          setAppliedPromo(null);
        }
      }
    } catch {
      showError(toast, 'Gagal memuat detail transaksi');
    } finally {
      setLoadingDetail(false);
    }
  };

  const addToCart = (item: ItemOption) => {
    const harga = item.is_promo && item.harga_promo != null ? item.harga_promo : item.harga;
    const existing = cart.find((c) => c.jenis === item.jenis && c.kode === item.kode);
    if (existing) {
      setCart(cart.map((c) =>
        c.jenis === item.jenis && c.kode === item.kode
          ? { ...c, qty: c.qty + 1, subtotal: (c.qty + 1) * c.harga_satuan }
          : c
      ));
    } else {
      setCart([...cart, {
        jenis: item.jenis,
        kode: item.kode,
        nama: item.nama,
        nama_kategori: item.nama_kategori,
        satuan: item.satuan || (item.jenis === 'layanan' ? 'tindakan' : 'pcs'),
        qty: 1,
        harga_satuan: harga,
        harga_asal: item.harga_asal || item.harga,
        is_promo: item.is_promo,
        nama_promo: item.nama_promo,
        subtotal: harga,
      }]);
    }
  };

  const updateQty = (idx: number, newQty: number) => {
    if (newQty <= 0) {
      setCart(cart.filter((_, i) => i !== idx));
    } else {
      setCart(cart.map((c, i) => i === idx ? { ...c, qty: newQty, subtotal: newQty * c.harga_satuan } : c));
    }
  };

  const removeItem = (idx: number) => {
    setCart(cart.filter((_, i) => i !== idx));
  };

  const totalHarga = useMemo(() => cart.reduce((s, c) => s + c.subtotal, 0), [cart]);

  const totalDiskon = useMemo(() => {
    if (!appliedPromo) return 0;
    return appliedPromo.jenis_diskon === 'persen'
      ? (totalHarga * appliedPromo.nilai_diskon) / 100
      : Math.min(appliedPromo.nilai_diskon, totalHarga);
  }, [totalHarga, appliedPromo]);

  const totalBayar = Math.max(0, totalHarga - totalDiskon);

  const filteredItems = useMemo(() => {
    const list = activeItemTab === 'layanan' ? layananList : produkList;
    if (!searchItem.trim()) return list;
    const q = searchItem.toLowerCase();
    return list.filter((i) => i.nama.toLowerCase().includes(q) || i.nama_kategori?.toLowerCase().includes(q));
  }, [activeItemTab, layananList, produkList, searchItem]);

  const handleSaveDraft = async () => {
    if (!selectedKunjungan) {
      showError(toast, 'Pilih pasien terlebih dahulu');
      return;
    }
    if (cart.length === 0) {
      showError(toast, 'Tambahkan minimal 1 item ke cart');
      return;
    }

    setSavingDraft(true);
    try {
      const payload = {
        kode_transaksi: editingKodeTrx || undefined,
        kode_kunjungan: selectedKunjungan.kode_kunjungan,
        no_rm: selectedKunjungan.no_rm,
        items: cart.map((c) => ({
          jenis: c.jenis,
          kode: c.kode,
          nama: c.nama,
          qty: c.qty,
          harga_satuan: c.harga_satuan,
        })),
        kode_promo: appliedPromo?.kode_promo || null,
        metode_bayar: 'tunai',
      };

      const res = await postData('/master/kasir-save', payload);
      if (['00', '0000'].includes(res?.data?.status)) {
        showSuccess(toast, 'Draft transaksi berhasil disimpan');
        onDraftSaved(res.data.data.kode_transaksi);
      } else {
        showError(toast, res?.data?.message || 'Gagal menyimpan draft');
      }
    } catch {
      showError(toast, 'Gagal terhubung ke server');
    } finally {
      setSavingDraft(false);
    }
  };

  const handleBayar = async () => {
    if (!selectedKunjungan) { showError(toast, 'Pilih pasien terlebih dahulu'); return; }
    if (cart.length === 0) { showError(toast, 'Cart masih kosong'); return; }

    // Save draft first to get kode_transaksi
    setSavingDraft(true);
    try {
      const payload = {
        kode_transaksi: editingKodeTrx || undefined,
        kode_kunjungan: selectedKunjungan.kode_kunjungan,
        no_rm: selectedKunjungan.no_rm,
        items: cart.map((c) => ({ jenis: c.jenis, kode: c.kode, nama: c.nama, qty: c.qty, harga_satuan: c.harga_satuan })),
        kode_promo: appliedPromo?.kode_promo || null,
        metode_bayar: 'tunai',
      };
      const res = await postData('/master/kasir-save', payload);
      if (['00', '0000'].includes(res?.data?.status)) {
        const kodeTrx = res.data.data.kode_transaksi;
        setEditingKodeTrx(kodeTrx);
        onOpenBayar({
          kode_transaksi: kodeTrx,
          total_bayar: totalBayar,
          nama_pasien: selectedKunjungan.nama_pasien,
          no_rm: selectedKunjungan.no_rm,
          items: cart,
          kode_promo: appliedPromo?.kode_promo || null,
          nama_promo: appliedPromo?.nama_promo || null,
          total_diskon: totalDiskon,
        });
      } else {
        showError(toast, res?.data?.message || 'Gagal menyimpan sebelum bayar');
      }
    } catch {
      showError(toast, 'Gagal terhubung ke server');
    } finally {
      setSavingDraft(false);
    }
  };

  const isReadOnly = trxStatus === 'lunas' || trxStatus === 'batal';

  if (loadingDetail) {
    return (
      <div className="flex align-items-center justify-content-center h-full">
        <ProgressSpinner style={{ width: '32px', height: '32px' }} />
        <span className="ml-2 text-sm text-gray-400">Memuat transaksi...</span>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', height: '100%', overflow: 'hidden' }}>
      {/* KIRI: Item Catalog */}
      <div
        style={{
          width: '55%',
          borderRight: '1.5px solid #e2e8f0',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          background: '#f8fafc',
        }}
      >
        {/* Header item catalog */}
        <div style={{ padding: '14px 16px 10px', borderBottom: '1px solid #e2e8f0', background: '#ffffff' }}>
          <div style={{ fontSize: '13px', fontWeight: 800, color: '#0f172a', marginBottom: '10px' }}>Pilih Item</div>

          {/* Tabs layanan/produk */}
          <div className="flex gap-1 mb-2 p-1 border-round-lg" style={{ background: '#f1f5f9' }}>
            {(['layanan', 'produk'] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveItemTab(tab)}
                style={{
                  flex: 1,
                  padding: '7px 10px',
                  borderRadius: '8px',
                  border: 'none',
                  background: activeItemTab === tab ? '#ffffff' : 'transparent',
                  fontSize: '12.5px',
                  fontWeight: activeItemTab === tab ? 700 : 600,
                  color: activeItemTab === tab ? '#0d9488' : '#64748b',
                  cursor: 'pointer',
                  boxShadow: activeItemTab === tab ? '0 1px 4px rgba(0,0,0,0.08)' : 'none',
                  transition: 'all 0.15s',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: '6px',
                }}
              >
                <i className={`pi ${tab === 'layanan' ? 'pi-briefcase' : 'pi-shopping-bag'}`} style={{ fontSize: '12px' }} />
                {tab === 'layanan' ? 'Layanan' : 'Produk'}
                <span style={{ fontSize: '10px', background: activeItemTab === tab ? '#0d9488' : '#cbd5e1', color: '#fff', borderRadius: '999px', padding: '0 6px', fontWeight: 800 }}>
                  {(activeItemTab === tab ? filteredItems : activeItemTab === 'layanan' ? produkList : layananList).length}
                </span>
              </button>
            ))}
          </div>

          <div className="p-inputgroup">
            <span className="p-inputgroup-addon" style={{ background: '#f8fafc', border: '1.5px solid #e2e8f0', borderRight: 'none', borderRadius: '8px 0 0 8px' }}>
              <i className="pi pi-search text-gray-400 text-xs" />
            </span>
            <InputText
              value={searchItem}
              onChange={(e) => setSearchItem(e.target.value)}
              placeholder={`Cari ${activeItemTab}...`}
              style={{ fontSize: '12px', border: '1.5px solid #e2e8f0', borderLeft: 'none', borderRadius: '0 8px 8px 0', boxShadow: 'none' }}
            />
          </div>
        </div>

        {/* Item Grid */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '10px' }}>
          {loadingOptions ? (
            <div className="flex align-items-center justify-content-center py-4">
              <ProgressSpinner style={{ width: '24px', height: '24px' }} />
            </div>
          ) : filteredItems.length === 0 ? (
            <div className="flex flex-column align-items-center justify-content-center py-5">
              <i className="pi pi-inbox text-3xl mb-2" style={{ color: '#cbd5e1' }} />
              <span className="text-xs text-gray-400">Tidak ada item ditemukan</span>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: '8px' }}>
              {filteredItems.map((item) => {
                const harga = item.is_promo && item.harga_promo != null ? item.harga_promo : item.harga;
                const inCart = cart.some((c) => c.jenis === item.jenis && c.kode === item.kode);
                return (
                  <div
                    key={item.kode}
                    onClick={() => !isReadOnly && addToCart(item)}
                    style={{
                      background: '#ffffff',
                      borderRadius: '10px',
                      border: inCart ? '2px solid #0d9488' : item.is_promo ? '1.5px solid #fca5a5' : '1.5px solid #e2e8f0',
                      padding: '10px',
                      cursor: isReadOnly ? 'not-allowed' : 'pointer',
                      transition: 'all 0.15s',
                      position: 'relative',
                      opacity: isReadOnly ? 0.6 : 1,
                      userSelect: 'none',
                      boxShadow: inCart ? '0 0 0 3px rgba(13,148,136,0.1)' : 'none',
                    }}
                  >
                    {item.is_promo && (
                      <span style={{
                        position: 'absolute', top: '6px', left: '6px',
                        fontSize: '9px', fontWeight: 800,
                        background: 'linear-gradient(135deg,#ef4444,#f97316)',
                        color: '#fff', borderRadius: '4px', padding: '1px 5px',
                      }}>
                        🔥 -{item.nilai_diskon}{item.jenis_diskon === 'persen' ? '%' : ''}
                      </span>
                    )}
                    {inCart && (
                      <span style={{
                        position: 'absolute', top: '6px', right: '6px',
                        width: '18px', height: '18px', borderRadius: '50%',
                        background: '#0d9488', display: 'flex', alignItems: 'center', justifyContent: 'center',
                      }}>
                        <i className="pi pi-check text-white" style={{ fontSize: '9px' }} />
                      </span>
                    )}
                    <div style={{ paddingTop: item.is_promo ? '16px' : '0' }}>
                      <div style={{ fontSize: '11.5px', fontWeight: 700, color: '#0f172a', lineHeight: 1.3, marginBottom: '3px' }}>
                        {item.nama}
                      </div>
                      <div style={{ fontSize: '10px', color: '#94a3b8', marginBottom: '6px' }}>
                        {item.nama_kategori || (item.jenis === 'layanan' ? 'Layanan' : 'Produk')}
                      </div>
                      {item.is_promo && item.harga_asal && (
                        <div style={{ fontSize: '10px', color: '#94a3b8', textDecoration: 'line-through' }}>
                          {formatRupiah(item.harga_asal)}
                        </div>
                      )}
                      <div style={{ fontSize: '13px', fontWeight: 800, color: item.is_promo ? '#e11d48' : '#0d9488' }}>
                        {formatRupiah(harga)}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* KANAN: Cart & Checkout */}
      <div
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          background: '#ffffff',
        }}
      >
        {/* Pasien selector */}
        <div style={{ padding: '14px 16px 12px', borderBottom: '1px solid #e2e8f0' }}>
          <div style={{ fontSize: '11px', fontWeight: 700, color: '#64748b', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
            Pasien
          </div>
          {isReadOnly ? (
            <div style={{ background: '#f8fafc', borderRadius: '8px', padding: '8px 12px', border: '1px solid #e2e8f0' }}>
              <div style={{ fontSize: '14px', fontWeight: 700, color: '#0f172a' }}>{selectedKunjungan?.nama_pasien || '-'}</div>
              <div style={{ fontSize: '11px', color: '#64748b' }}>{selectedKunjungan?.no_rm}</div>
            </div>
          ) : (
            <Dropdown
              value={selectedKunjungan}
              options={kunjunganList}
              onChange={(e) => setSelectedKunjungan(e.value)}
              optionLabel="nama_pasien"
              placeholder="Pilih pasien kunjungan hari ini..."
              filter
              filterBy="nama_pasien,no_rm"
              filterPlaceholder="Cari nama / no RM..."
              className="w-full"
              style={{ fontSize: '13px' }}
              itemTemplate={(opt: KunjunganOption) => (
                <div>
                  <div style={{ fontWeight: 700, fontSize: '13px' }}>{opt.nama_pasien}</div>
                  <div style={{ fontSize: '11px', color: '#64748b' }}>{opt.no_rm} • Datang: {opt.jam_datang?.slice(0, 5)}</div>
                </div>
              )}
            />
          )}
          {trxStatus && (
            <div className="mt-1">
              <Tag
                value={trxStatus.toUpperCase()}
                severity={trxStatus === 'lunas' ? 'success' : trxStatus === 'batal' ? 'danger' : 'info'}
                style={{ fontSize: '10px' }}
              />
              {editingKodeTrx && <span style={{ fontSize: '11px', color: '#64748b', marginLeft: '8px' }}>{editingKodeTrx}</span>}
            </div>
          )}
        </div>

        {/* Cart items */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '10px 16px' }}>
          {cart.length === 0 ? (
            <div className="flex flex-column align-items-center justify-content-center h-full text-center" style={{ opacity: 0.5 }}>
              <i className="pi pi-shopping-cart text-4xl mb-2" style={{ color: '#cbd5e1' }} />
              <span className="text-sm text-gray-400">Pilih item dari katalog</span>
            </div>
          ) : (
            cart.map((item, idx) => (
              <div
                key={`${item.jenis}_${item.kode}_${idx}`}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '10px 0',
                  borderBottom: '1px solid #f1f5f9',
                }}
              >
                <div
                  style={{
                    width: '32px', height: '32px', borderRadius: '8px', flexShrink: 0,
                    background: item.jenis === 'layanan' ? '#f0fdfa' : '#fffbeb',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}
                >
                  <i className={`pi ${item.jenis === 'layanan' ? 'pi-briefcase' : 'pi-shopping-bag'}`}
                    style={{ fontSize: '13px', color: item.jenis === 'layanan' ? '#0d9488' : '#d97706' }} />
                </div>

                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: '12.5px', fontWeight: 700, color: '#0f172a', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {item.nama}
                    {item.is_promo && (
                      <span style={{ marginLeft: '5px', fontSize: '9px', background: '#ef4444', color: '#fff', borderRadius: '4px', padding: '1px 4px' }}>PROMO</span>
                    )}
                  </div>
                  <div style={{ fontSize: '11px', color: '#94a3b8' }}>
                    {formatRupiah(item.harga_satuan)} / {item.satuan || 'pcs'}
                  </div>
                </div>

                {!isReadOnly ? (
                  <div className="flex align-items-center gap-1">
                    <button onClick={() => updateQty(idx, item.qty - 1)} style={{ width: '24px', height: '24px', borderRadius: '6px', border: '1.5px solid #e2e8f0', background: '#f8fafc', cursor: 'pointer', fontSize: '13px', fontWeight: 700, color: '#334155' }}>−</button>
                    <span style={{ minWidth: '28px', textAlign: 'center', fontSize: '13px', fontWeight: 800, color: '#0f172a' }}>{item.qty}</span>
                    <button onClick={() => updateQty(idx, item.qty + 1)} style={{ width: '24px', height: '24px', borderRadius: '6px', border: '1.5px solid #0d9488', background: '#0d9488', cursor: 'pointer', fontSize: '13px', fontWeight: 700, color: '#fff' }}>+</button>
                  </div>
                ) : (
                  <span style={{ fontSize: '13px', fontWeight: 700 }}>x{item.qty}</span>
                )}

                <div style={{ textAlign: 'right', minWidth: '80px' }}>
                  <div style={{ fontSize: '13px', fontWeight: 800, color: '#0d9488' }}>{formatRupiah(item.subtotal)}</div>
                </div>

                {!isReadOnly && (
                  <button onClick={() => removeItem(idx)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#ef4444', padding: '4px' }}>
                    <i className="pi pi-trash" style={{ fontSize: '12px' }} />
                  </button>
                )}
              </div>
            ))
          )}
        </div>

        {/* Total & Actions */}
        <div style={{ padding: '12px 16px', borderTop: '1.5px solid #e2e8f0', background: '#f8fafc', flexShrink: 0 }}>
          {/* Summary */}
          <div style={{ marginBottom: '10px' }}>
            <div className="flex justify-content-between mb-1">
              <span style={{ fontSize: '12px', color: '#64748b' }}>Subtotal</span>
              <span style={{ fontSize: '12px', fontWeight: 600 }}>{formatRupiah(totalHarga)}</span>
            </div>
            {appliedPromo && (
              <div className="flex justify-content-between mb-1 align-items-center">
                <span style={{ fontSize: '12px', color: '#e11d48', display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <i className="pi pi-percentage" style={{ fontSize: '11px' }} />
                  {appliedPromo.nama_promo} ({appliedPromo.jenis_diskon === 'persen' ? `${appliedPromo.nilai_diskon}%` : formatRupiah(appliedPromo.nilai_diskon)})
                  {!isReadOnly && (
                    <button onClick={() => setAppliedPromo(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#ef4444', fontSize: '11px', padding: '0 2px' }}>
                      <i className="pi pi-times" />
                    </button>
                  )}
                </span>
                <span style={{ fontSize: '12px', fontWeight: 600, color: '#e11d48' }}>- {formatRupiah(totalDiskon)}</span>
              </div>
            )}
            <div className="flex justify-content-between">
              <span style={{ fontSize: '14px', fontWeight: 800, color: '#0f172a' }}>Total Bayar</span>
              <span style={{ fontSize: '16px', fontWeight: 900, color: '#0d9488' }}>{formatRupiah(totalBayar)}</span>
            </div>
          </div>

          {/* Actions */}
          {!isReadOnly && (
            <div className="flex gap-2">
              <Button
                label="Simpan Draft"
                icon="pi pi-save"
                className="p-button-outlined p-button-secondary flex-1"
                onClick={handleSaveDraft}
                loading={savingDraft}
                disabled={cart.length === 0 || !selectedKunjungan}
                style={{ fontSize: '12px', fontWeight: 700 }}
              />
              <Button
                label="Bayar"
                icon="pi pi-credit-card"
                className="flex-1"
                onClick={handleBayar}
                loading={savingDraft}
                disabled={cart.length === 0 || !selectedKunjungan}
                style={{ fontSize: '13px', fontWeight: 800, background: 'linear-gradient(135deg,#0d9488,#059669)', border: 'none' }}
              />
            </div>
          )}

          {isReadOnly && trxStatus === 'lunas' && (
            <div className="flex align-items-center justify-content-center gap-2 py-2" style={{ color: '#15803d' }}>
              <i className="pi pi-check-circle text-xl" />
              <span style={{ fontWeight: 700, fontSize: '14px' }}>Transaksi Lunas</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
