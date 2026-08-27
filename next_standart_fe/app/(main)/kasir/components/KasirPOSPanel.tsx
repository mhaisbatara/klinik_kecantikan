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
  layanan_pendaftaran?: CartItem[];
}

interface ItemOption {
  jenis: 'layanan' | 'produk';
  kode: string;
  nama: string;
  nama_kategori?: string;
  satuan?: string;
  harga: number;
}

interface PromoOption {
  kode_promo: string;
  nama_promo: string;
  jenis_diskon: 'persen' | 'nominal';
  nilai_diskon: number;
  tanggal_mulai?: string;
  tanggal_selesai?: string;
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
  const [promoList, setPromoList] = useState<PromoOption[]>([]);

  const [selectedKunjungan, setSelectedKunjungan] = useState<KunjunganOption | null>(null);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [searchItem, setSearchItem] = useState('');
  const [activeItemTab, setActiveItemTab] = useState<'layanan' | 'produk'>('layanan');
  const [editingKodeTrx, setEditingKodeTrx] = useState<string | null>(null);
  const [trxStatus, setTrxStatus] = useState<'draft' | 'lunas' | 'batal' | null>(null);
  const [appliedPromo, setAppliedPromo] = useState<PromoOption | null>(null);

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
        setPromoList(res.data.data.promo || []);
      }
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || err?.message || 'Gagal memuat opsi kasir');
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

        const kunjungan = kunjunganList.find((k) => k.kode_kunjungan === trx.kode_kunjungan) ||
          (trx.kode_kunjungan ? {
            kode_kunjungan: trx.kode_kunjungan,
            no_rm: trx.no_rm,
            nama_pasien: trx.nama_pasien || trx.no_rm,
            no_hp: trx.no_hp || '',
            jam_datang: '',
          } : null);
        setSelectedKunjungan(kunjungan);

        const cartItems: CartItem[] = (trx.details || []).map((d: any) => ({
          jenis: d.jenis,
          kode: d.kode,
          nama: d.nama,
          satuan: d.satuan || (d.jenis === 'layanan' ? 'tindakan' : 'pcs'),
          qty: d.qty,
          harga_satuan: parseFloat(d.harga_satuan),
          subtotal: parseFloat(d.subtotal),
          is_from_pendaftaran: Boolean(d.is_from_pendaftaran),
        }));
        setCart(cartItems);

        if (trx.kode_promo) {
          const promo = promoList.find((p) => p.kode_promo === trx.kode_promo) || {
            kode_promo: trx.kode_promo,
            nama_promo: trx.nama_promo || trx.kode_promo,
            jenis_diskon: trx.jenis_diskon || 'persen',
            nilai_diskon: parseFloat(trx.nilai_diskon_promo || 0),
          };
          setAppliedPromo(promo);
        } else {
          setAppliedPromo(null);
        }
      }
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || err?.message || 'Gagal memuat detail transaksi');
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleKunjunganChange = (kunjungan: KunjunganOption | null) => {
    setSelectedKunjungan(kunjungan);
    if (!kunjungan) {
      setCart([]);
      setEditingKodeTrx(null);
      setTrxStatus(null);
      return;
    }

    if (!editingKodeTrx) {
      const itemsFromPendaftaran = kunjungan.layanan_pendaftaran || [];
      setCart(itemsFromPendaftaran);
    }
  };

  const addToCart = (item: ItemOption) => {
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
        harga_satuan: item.harga,
        subtotal: item.harga,
        is_from_pendaftaran: false,
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

  // Real-time Total Calculations
  const totalHarga = useMemo(() => cart.reduce((s, c) => s + c.subtotal, 0), [cart]);

  const totalDiskon = useMemo(() => {
    if (!appliedPromo || totalHarga <= 0) return 0;
    const diskon = appliedPromo.jenis_diskon === 'persen'
      ? (totalHarga * appliedPromo.nilai_diskon) / 100
      : appliedPromo.nilai_diskon;
    return Math.min(diskon, totalHarga);
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
          is_from_pendaftaran: c.is_from_pendaftaran ? 1 : 0,
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
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || err?.message || 'Gagal terhubung ke server');
    } finally {
      setSavingDraft(false);
    }
  };

  const handleBayar = async () => {
    if (!selectedKunjungan) { showError(toast, 'Pilih pasien terlebih dahulu'); return; }
    if (cart.length === 0) { showError(toast, 'Cart masih kosong'); return; }

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
          is_from_pendaftaran: c.is_from_pendaftaran ? 1 : 0,
        })),
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
    } catch (err: any) {
      showError(toast, err?.response?.data?.message || err?.message || 'Gagal terhubung ke server');
    } finally {
      setSavingDraft(false);
    }
  };

  const isReadOnly = trxStatus === 'lunas' || trxStatus === 'batal';

  if (loadingDetail) {
    return (
      <div className="flex align-items-center justify-content-center h-full surface-ground">
        <ProgressSpinner style={{ width: '32px', height: '32px' }} />
        <span className="ml-2 text-sm text-500 font-medium">Memuat rincian transaksi...</span>
      </div>
    );
  }

  return (
    <div className="flex h-full gap-2 overflow-hidden">
      {/* KIRI: Katalog Item (50%) */}
      <div style={{ flex: '1 1 50%', minWidth: 0 }} className="flex flex-column h-full surface-card border-round-xl border-1 surface-border shadow-1 overflow-hidden">
        {/* Header Catalog */}
        <div className="p-3 border-bottom-1 surface-border bg-white flex-shrink-0">
          <label className="block text-xs font-extrabold text-teal-800 uppercase tracking-wider mb-2 flex align-items-center gap-2 m-0">
            <i className="pi pi-shopping-bag text-teal-600 text-sm" />
            KATALOG ITEM (LAYANAN &amp; PRODUK)
          </label>

          {/* Tabs layanan/produk */}
          <div className="flex gap-1 mb-2 p-1 bg-slate-100 border-round-lg">
            {(['layanan', 'produk'] as const).map((tab) => {
              const isActive = activeItemTab === tab;
              const count = tab === 'layanan' ? layananList.length : produkList.length;
              return (
                <button
                  key={tab}
                  onClick={() => setActiveItemTab(tab)}
                  className={`flex-1 py-2 px-3 border-round-md font-bold text-xs border-none cursor-pointer flex align-items-center justify-content-center gap-2 transition-all ${
                    isActive ? 'bg-teal-600 text-white shadow-1' : 'bg-transparent text-slate-600 hover:text-slate-900'
                  }`}
                >
                  <i className={`pi ${tab === 'layanan' ? 'pi-briefcase' : 'pi-box'}`} style={{ fontSize: '12px' }} />
                  {tab === 'layanan' ? 'Layanan & Paket' : 'Produk'}
                  <span className={`text-[10px] px-1.5 py-0.5 border-round-md font-black ${isActive ? 'bg-teal-800 text-white' : 'bg-slate-200 text-slate-700'}`}>
                    {count}
                  </span>
                </button>
              );
            })}
          </div>

          <div className="p-input-icon-left w-full">
            <i className="pi pi-search text-xs" />
            <InputText
              value={searchItem}
              onChange={(e) => setSearchItem(e.target.value)}
              placeholder={`Cari ${activeItemTab === 'layanan' ? 'layanan / paket' : 'produk'}...`}
              className="p-inputtext-sm w-full border-round-lg text-xs"
            />
          </div>
        </div>

        {/* Item Grid */}
        <div className="flex-1 overflow-y-auto p-3 surface-ground">
          {loadingOptions ? (
            <div className="flex align-items-center justify-content-center py-5">
              <ProgressSpinner style={{ width: '28px', height: '28px' }} />
            </div>
          ) : filteredItems.length === 0 ? (
            <div className="flex flex-column align-items-center justify-content-center py-5 text-center">
              <i className="pi pi-inbox text-3xl text-300 mb-2" />
              <span className="text-xs text-500 font-medium">Tidak ada item ditemukan</span>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: '8px' }}>
              {filteredItems.map((item) => {
                const inCartItem = cart.find((c) => c.jenis === item.jenis && c.kode === item.kode);
                const inCart = Boolean(inCartItem);
                return (
                  <div
                    key={item.kode}
                    onClick={() => !isReadOnly && addToCart(item)}
                    className={`surface-card border-1 border-round-xl p-2.5 transition-all user-select-none relative flex flex-column justify-content-between ${
                      isReadOnly ? 'cursor-not-allowed opacity-60' : 'cursor-pointer hover:shadow-2'
                    } ${inCart ? 'bg-teal-50/70 border-2 border-teal-500 shadow-1' : 'surface-border shadow-1'}`}
                  >
                    {inCart && (
                      <span className="absolute top-2 right-2 bg-teal-600 text-white text-[9px] font-black px-1.5 py-0.5 border-round-md flex align-items-center gap-1 shadow-1">
                        <i className="pi pi-check text-[8px]" />
                        Terpilih
                      </span>
                    )}

                    <div>
                      <div className="font-bold text-xs text-slate-900 mb-1 line-height-2 pr-4">
                        {item.nama}
                      </div>
                      <div className="text-[10px] text-500 mb-1 font-medium">
                        {item.nama_kategori || (item.jenis === 'layanan' ? 'Layanan' : 'Produk')}
                      </div>
                    </div>

                    <div className="flex align-items-center justify-content-between pt-1.5 border-top-1 surface-border mt-1">
                      <span className="font-black text-xs text-teal-700">{formatRupiah(item.harga)}</span>
                      {inCart && inCartItem && (
                        <span className="text-[10px] font-bold text-teal-800 bg-teal-100 px-1.5 py-0.5 border-round-md">
                          x{inCartItem.qty}
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* KANAN: Pasien & Rincian Kasir (50%) */}
      <div style={{ flex: '1 1 50%', minWidth: 0 }} className="flex flex-column h-full surface-card border-round-xl border-1 surface-border shadow-1 overflow-hidden">
        {/* Pasien selector header */}
        <div className="p-3 border-bottom-1 surface-border bg-white flex-shrink-0">
          <div className="flex align-items-center justify-content-between mb-2">
            <label className="text-xs font-extrabold text-teal-800 uppercase tracking-wider flex align-items-center gap-2 m-0">
              <i className="pi pi-user text-teal-600 text-sm" />
              RINCIAN TRANSAKSI KASIR
            </label>
            {trxStatus && (
              <div className="flex align-items-center gap-2">
                <Tag
                  value={trxStatus.toUpperCase()}
                  severity={trxStatus === 'lunas' ? 'success' : trxStatus === 'batal' ? 'danger' : 'info'}
                  className="text-[10px] font-extrabold px-2 py-0.5"
                />
                {editingKodeTrx && <span className="text-xs font-black text-slate-700 bg-slate-100 px-2 py-0.5 border-round-md">{editingKodeTrx}</span>}
              </div>
            )}
          </div>

          {/* Pasien Selector / Display */}
          {isReadOnly ? (
            <div className="bg-slate-50 border-round-xl p-2.5 border-1 surface-border flex align-items-center justify-content-between">
              <div>
                <div className="font-extrabold text-xs text-slate-900">{selectedKunjungan?.nama_pasien || '-'}</div>
                <div className="text-[11px] text-slate-500 mt-0.5">No. RM: {selectedKunjungan?.no_rm}</div>
              </div>
              {selectedKunjungan?.kode_kunjungan && (
                <span className="text-[10px] font-bold text-teal-700 bg-teal-100 px-2 py-0.5 border-round-md">
                  {selectedKunjungan.kode_kunjungan}
                </span>
              )}
            </div>
          ) : (
            <Dropdown
              value={selectedKunjungan}
              options={kunjunganList}
              onChange={(e) => handleKunjunganChange(e.value)}
              optionLabel="nama_pasien"
              placeholder="Pilih Pasien..."
              filter
              filterBy="nama_pasien,no_rm"
              filterPlaceholder="Cari nama / no RM..."
              className="w-full p-inputtext-sm border-round-lg text-xs"
              valueTemplate={(opt: KunjunganOption) => (
                opt ? (
                  <div className="flex align-items-center justify-content-between w-full py-0.5">
                    <span className="font-bold text-xs text-slate-900">{opt.nama_pasien}</span>
                    <span className="text-[11px] text-teal-700 font-semibold bg-teal-50 px-2 py-0.5 border-round-md">
                      RM: {opt.no_rm}
                    </span>
                  </div>
                ) : null
              )}
              itemTemplate={(opt: KunjunganOption) => (
                <div className="flex align-items-center justify-content-between w-full py-1">
                  <div>
                    <div className="font-bold text-xs text-slate-900 mb-0.5">{opt.nama_pasien}</div>
                    <div className="text-[11px] text-slate-500">RM: {opt.no_rm}</div>
                  </div>
                  {opt.jam_datang && (
                    <span className="text-[10px] text-slate-400 font-medium">
                      {opt.jam_datang.slice(0, 5)}
                    </span>
                  )}
                </div>
              )}
            />
          )}
        </div>

        {/* Cart items list */}
        <div className="flex-1 overflow-y-auto p-3 surface-ground flex flex-column gap-2">
          {cart.length === 0 ? (
            <div className="flex flex-column align-items-center justify-content-center h-full text-center py-5">
              <i className="pi pi-shopping-cart text-4xl text-300 mb-2" />
              <span className="text-xs text-400 font-medium">Pilih item dari katalog di sebelah kiri</span>
            </div>
          ) : (
            cart.map((item, idx) => (
              <div
                key={`${item.jenis}_${item.kode}_${idx}`}
                className="surface-card p-2.5 border-round-xl border-1 surface-border shadow-1 flex align-items-center justify-content-between gap-3"
              >
                {/* Item Info (Nama & Harga Satuan) */}
                <div className="flex-1 min-w-0">
                  <div className="font-extrabold text-xs text-slate-900 line-height-2 overflow-hidden text-ellipsis white-space-nowrap">
                    {item.nama}
                  </div>
                  <div className="text-[11px] text-slate-500 font-medium mt-0.5">
                    {formatRupiah(item.harga_satuan)} / {item.satuan || 'pcs'}
                  </div>
                </div>

                {/* Controls (Qty & Subtotal & Hapus) */}
                <div className="flex align-items-center gap-3 flex-shrink-0">
                  {!isReadOnly ? (
                    <div className="flex align-items-center gap-1.5 bg-slate-100 p-1 border-round-lg border-1 surface-border">
                      <button
                        onClick={() => updateQty(idx, item.qty - 1)}
                        className="border-none bg-white hover:bg-slate-200 border-round-md font-bold cursor-pointer text-slate-700 shadow-1"
                        style={{ width: '22px', height: '22px', fontSize: '12px' }}
                      >−</button>
                      <span className="font-extrabold text-xs px-1 text-slate-900">{item.qty}</span>
                      <button
                        onClick={() => updateQty(idx, item.qty + 1)}
                        className="border-none bg-teal-600 hover:bg-teal-700 text-white border-round-md font-bold cursor-pointer shadow-1"
                        style={{ width: '22px', height: '22px', fontSize: '12px' }}
                      >+</button>
                    </div>
                  ) : (
                    <span className="font-extrabold text-xs text-slate-700">x{item.qty}</span>
                  )}

                  {/* Subtotal */}
                  <div className="text-right" style={{ minWidth: '75px' }}>
                    <div className="font-black text-xs text-teal-700">{formatRupiah(item.subtotal)}</div>
                  </div>

                  {/* Hapus button */}
                  {!isReadOnly && (
                    <button
                      onClick={() => removeItem(idx)}
                      className="border-none bg-transparent cursor-pointer text-red-400 hover:text-red-600 p-1"
                      title="Hapus Item"
                    >
                      <i className="pi pi-trash text-xs" />
                    </button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>

        {/* Footer Summary & Actions */}
        <div className="p-3 border-top-1 surface-border bg-white flex-shrink-0">
          {/* Promo Selector Dropdown */}
          <div className="mb-2">
            <label className="block text-[11px] font-extrabold text-slate-600 uppercase tracking-wider mb-1">
              Voucher / Promo Diskon
            </label>
            {isReadOnly ? (
              appliedPromo ? (
                <div className="text-xs font-bold text-rose-700 bg-rose-50 border-round-md p-2 border-1 border-rose-200">
                  <i className="pi pi-percentage mr-1" />
                  {appliedPromo.nama_promo} ({appliedPromo.jenis_diskon === 'persen' ? `${appliedPromo.nilai_diskon}%` : formatRupiah(appliedPromo.nilai_diskon)})
                </div>
              ) : (
                <div className="text-xs text-slate-400">Tanpa Promo</div>
              )
            ) : (
              <Dropdown
                value={appliedPromo}
                options={promoList}
                onChange={(e) => setAppliedPromo(e.value || null)}
                optionLabel="nama_promo"
                placeholder="Pilih Promo Diskon (Opsional)..."
                showClear
                filter
                filterBy="nama_promo"
                className="w-full p-inputtext-sm border-round-lg text-xs"
                itemTemplate={(opt: PromoOption) => (
                  <div className="flex align-items-center justify-content-between w-full">
                    <span className="font-bold text-xs text-slate-900">{opt.nama_promo}</span>
                    <span className="text-[11px] font-extrabold text-rose-700 bg-rose-100 px-1.5 py-0.5 border-round-md">
                      {opt.jenis_diskon === 'persen' ? `-${opt.nilai_diskon}%` : `-${formatRupiah(opt.nilai_diskon)}`}
                    </span>
                  </div>
                )}
                valueTemplate={(opt: PromoOption) => (
                  opt ? (
                    <div className="flex align-items-center justify-content-between w-full">
                      <span className="font-bold text-xs text-rose-700">
                        <i className="pi pi-ticket mr-1" />
                        {opt.nama_promo}
                      </span>
                      <span className="text-[11px] font-black text-rose-700">
                        {opt.jenis_diskon === 'persen' ? `-${opt.nilai_diskon}%` : `-${formatRupiah(opt.nilai_diskon)}`}
                      </span>
                    </div>
                  ) : null
                )}
              />
            )}
          </div>

          {/* Totals Summary Box */}
          <div className="bg-teal-50 p-2.5 border-round-xl border-1 border-teal-200 mb-2">
            <div className="flex justify-content-between text-xs text-slate-700 mb-1">
              <span>Subtotal</span>
              <span className="font-bold">{formatRupiah(totalHarga)}</span>
            </div>

            {appliedPromo && (
              <div className="flex justify-content-between text-xs text-rose-700 mb-1">
                <span>Diskon ({appliedPromo.nama_promo})</span>
                <span className="font-extrabold">- {formatRupiah(totalDiskon)}</span>
              </div>
            )}

            <div className="flex justify-content-between align-items-center pt-2 border-top-1 border-teal-200 mt-1">
              <span className="font-extrabold text-xs text-teal-950">Total Bayar</span>
              <span className="font-black text-lg text-teal-700">{formatRupiah(totalBayar)}</span>
            </div>
          </div>

          {/* Actions */}
          {!isReadOnly && (
            <div className="flex gap-2">
              <Button
                label="Simpan Draft"
                icon="pi pi-save"
                outlined
                severity="secondary"
                onClick={handleSaveDraft}
                loading={savingDraft}
                disabled={cart.length === 0 || !selectedKunjungan}
                className="font-bold text-xs border-round-lg flex-1"
              />
              <Button
                label="Bayar"
                icon="pi pi-credit-card"
                severity="success"
                onClick={handleBayar}
                loading={savingDraft}
                disabled={cart.length === 0 || !selectedKunjungan}
                className="font-bold text-xs bg-teal-600 border-none border-round-lg px-4 text-white shadow-2 flex-1"
              />
            </div>
          )}

          {isReadOnly && trxStatus === 'lunas' && (
            <Tag value="✅ Transaksi Lunas" severity="success" className="w-full py-2 text-xs font-bold text-center border-round-lg" />
          )}
        </div>
      </div>
    </div>
  );
};
