'use client';

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { Toast } from 'primereact/toast';
import { KasirSidebar } from './components/KasirSidebar';
import { KasirPOSPanel } from './components/KasirPOSPanel';
import { KasirBayarModal } from './components/KasirBayarModal';
import { KasirStrukModal } from './components/KasirStrukModal';
import postData from '@/lib/axios/postData';
import { showError } from '@/lib/tools/generalTools';

export interface CartItem {
  jenis: 'layanan' | 'produk';
  kode: string;
  nama: string;
  nama_kategori?: string;
  satuan?: string;
  qty: number;
  harga_satuan: number;
  harga_asal?: number;
  is_promo?: boolean;
  nama_promo?: string;
  subtotal: number;
}

export interface TransaksiListItem {
  kode_transaksi: string;
  kode_kunjungan: string;
  no_rm: string;
  nama_pasien: string;
  no_hp: string;
  kode_promo: string | null;
  nama_promo: string | null;
  tanggal_transaksi: string;
  total_harga: number;
  total_diskon: number;
  total_bayar: number;
  metode_bayar: string;
  status: 'draft' | 'lunas' | 'batal';
  created_at: string;
}

export interface BayarResult {
  kode_transaksi: string;
  metode_bayar: string;
  total_bayar: number;
  nominal_bayar: number;
  kembalian: number;
  nama_pasien?: string;
  no_rm?: string;
  items?: CartItem[];
  kode_promo?: string | null;
  nama_promo?: string | null;
  total_diskon?: number;
}

export default function KasirPage() {
  const toast = useRef<Toast>(null);

  // State sidebar
  const [transaksiList, setTransaksiList] = useState<TransaksiListItem[]>([]);
  const [loadingList, setLoadingList] = useState(false);
  const [selectedKodeTrx, setSelectedKodeTrx] = useState<string | null>(null);
  const [listRefreshKey, setListRefreshKey] = useState(0);

  // State modal
  const [showBayarModal, setShowBayarModal] = useState(false);
  const [showStrukModal, setShowStrukModal] = useState(false);
  const [bayarResult, setBayarResult] = useState<BayarResult | null>(null);

  // Pending bayar payload (from POS panel)
  const [pendingBayarPayload, setPendingBayarPayload] = useState<{
    kode_transaksi: string;
    total_bayar: number;
    nama_pasien: string;
    no_rm: string;
    items: CartItem[];
    kode_promo?: string | null;
    nama_promo?: string | null;
    total_diskon?: number;
  } | null>(null);

  const refreshList = useCallback(() => {
    setListRefreshKey((k) => k + 1);
  }, []);

  const handleSelectTrx = (kode: string) => {
    setSelectedKodeTrx(kode);
  };

  const handleNewTrx = () => {
    setSelectedKodeTrx(null);
  };

  const handleDraftSaved = (kode_transaksi: string) => {
    setSelectedKodeTrx(kode_transaksi);
    refreshList();
  };

  const handleOpenBayar = (payload: typeof pendingBayarPayload) => {
    setPendingBayarPayload(payload);
    setShowBayarModal(true);
  };

  const handleBayarConfirm = async (metode: string, nominal: number) => {
    if (!pendingBayarPayload) return;
    try {
      const res = await postData('/master/kasir-bayar', {
        kode_transaksi: pendingBayarPayload.kode_transaksi,
        metode_bayar: metode,
        nominal_bayar: nominal,
      });

      if (['00', '0000'].includes(res?.data?.status)) {
        const result: BayarResult = {
          ...res.data.data,
          nama_pasien: pendingBayarPayload.nama_pasien,
          no_rm: pendingBayarPayload.no_rm,
          items: pendingBayarPayload.items,
          kode_promo: pendingBayarPayload.kode_promo,
          nama_promo: pendingBayarPayload.nama_promo,
          total_diskon: pendingBayarPayload.total_diskon,
        };
        setBayarResult(result);
        setShowBayarModal(false);
        setShowStrukModal(true);
        setSelectedKodeTrx(null);
        refreshList();
      } else {
        showError(toast, res?.data?.message || 'Pembayaran gagal');
      }
    } catch {
      showError(toast, 'Gagal terhubung ke server');
    }
  };

  return (
    <div
      style={{
        display: 'flex',
        height: 'calc(100vh - 70px)',
        gap: '0',
        background: '#f8fafc',
        overflow: 'hidden',
      }}
    >
      <Toast ref={toast} position="top-right" />

      {/* SIDEBAR KIRI */}
      <div
        style={{
          width: '340px',
          minWidth: '300px',
          flexShrink: 0,
          height: '100%',
          overflow: 'hidden',
          borderRight: '1.5px solid #e2e8f0',
          background: '#ffffff',
        }}
      >
        <KasirSidebar
          toast={toast}
          selectedKodeTrx={selectedKodeTrx}
          refreshKey={listRefreshKey}
          onSelectTrx={handleSelectTrx}
          onNewTrx={handleNewTrx}
          onListChange={setTransaksiList}
        />
      </div>

      {/* PANEL UTAMA POS */}
      <div style={{ flex: 1, height: '100%', overflow: 'hidden' }}>
        <KasirPOSPanel
          toast={toast}
          kode_transaksi={selectedKodeTrx}
          onDraftSaved={handleDraftSaved}
          onOpenBayar={handleOpenBayar}
        />
      </div>

      {/* MODAL BAYAR */}
      <KasirBayarModal
        visible={showBayarModal}
        totalBayar={pendingBayarPayload?.total_bayar || 0}
        onHide={() => setShowBayarModal(false)}
        onConfirm={handleBayarConfirm}
      />

      {/* MODAL STRUK */}
      <KasirStrukModal
        visible={showStrukModal}
        result={bayarResult}
        onHide={() => setShowStrukModal(false)}
      />
    </div>
  );
}
