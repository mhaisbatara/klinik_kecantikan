'use client';

import React, { useState, useEffect } from 'react';
import { Button } from 'primereact/button';
import { Checkbox } from 'primereact/checkbox';
import { TabView, TabPanel } from 'primereact/tabview';
import { Tag } from 'primereact/tag';
import { ProgressSpinner } from 'primereact/progressspinner';
import { Toast } from 'primereact/toast';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { apiPasienLayananOptions, apiPasienAmbilAntrianLayanan, apiPasienKepemilikanPaket } from './endpoints';

interface ServiceItem {
  jenis: 'layanan' | 'paket' | 'klaim_paket';
  kode_layanan: string;
  kode_kategori: string;
  nama_kategori: string;
  nama: string;
  harga: number;
  harga_asal?: number;
  is_promo?: boolean;
  kode_promo?: string;
  nama_promo?: string;
  jenis_diskon?: 'persen' | 'nominal';
  nilai_diskon?: number;
  durasi_menit: number;
  masa_berlaku_hari?: number;
  total_sesi?: number;
  kode_ruangan?: string;
  nama_ruangan?: string;
  wajib_konsultasi?: 'tidak' | 'opsional' | 'wajib';
  kode_ruangan_konsultasi?: string;
  is_konsultasi?: number;
  tipe?: 'MEDICAL TREATMENT' | 'BEAUTY TREATMENT' | 'SERVICE TREATMENT' | string;
  kode_kepemilikan_paket_layanan?: string;
  nama_paket_asal?: string;
  sisa_sesi?: number;
}

interface RuanganGroup {
  kode_ruangan: string;
  nama_ruangan: string;
  deskripsi: string;
  items: ServiceItem[];
}

interface PasienInfo {
  no_rm: string;
  nama: string;
  nik?: string;
  no_hp?: string;
}

interface Props {
  pasienData: PasienInfo;
  toast: React.RefObject<Toast>;
  onSuccess: (resultData: any) => void;
  onBack: () => void;
}

export const StepPilihLayanan: React.FC<Props> = ({
  pasienData,
  toast,
  onSuccess,
  onBack,
}) => {
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [ruangans, setRuangans] = useState<RuanganGroup[]>([]);
  const [ownedPackages, setOwnedPackages] = useState<any[]>([]);

  // Map item yang dipilih: key = `${jenis}_${kode_layanan}`
  const [selectedMap, setSelectedMap] = useState<{ [key: string]: ServiceItem }>({});
  // Map pilihan konsul khusus untuk item Opsional Konsul (BEAUTY TREATMENT): true = Ya (Ke Ruang Konsul), false = Tidak (Langsung Treatment)
  const [consultChoiceMap, setConsultChoiceMap] = useState<{ [key: string]: boolean }>({});
  // Kode ruangan yang sedang aktif dipilih (null = belum ada yang dipilih)
  const [activeRuangan, setActiveRuangan] = useState<string | null>(null);

  const [activeTabIndex, setActiveTabIndex] = useState<number>(0);

  useEffect(() => {
    fetchAllData();
  }, [pasienData?.no_rm]);

  const fetchAllData = async () => {
    setLoading(true);
    setActiveTabIndex(0);
    try {
      const promises: Promise<any>[] = [postData(apiPasienLayananOptions)];
      if (pasienData?.no_rm) {
        promises.push(postData(apiPasienKepemilikanPaket, { no_rm: pasienData.no_rm }));
      }

      const [resOptions, resPackages] = await Promise.all(promises);

      if (['00', '0000'].includes(resOptions?.data?.status)) {
        setRuangans(resOptions.data.data.ruangan_layanan || resOptions.data.data.kategori_layanan || []);
      } else {
        showError(toast, resOptions?.data?.message || 'Gagal memuat pilihan layanan');
      }

      if (resPackages && ['00', '0000'].includes(resPackages?.data?.status)) {
        setOwnedPackages(resPackages.data.data || []);
      } else {
        setOwnedPackages([]);
      }
    } catch (error: any) {
      showError(toast, 'Terjadi kesalahan saat memuat daftar layanan');
    } finally {
      setLoading(false);
    }
  };

  const handleToggleItem = (item: ServiceItem) => {
    const key = `${item.jenis}_${item.kode_layanan}`;
    const isCurrentlySelected = !!selectedMap[key];

    if (isCurrentlySelected) {
      const newMap = { ...selectedMap };
      delete newMap[key];
      setSelectedMap(newMap);

      const remainingItems = Object.values(newMap);
      if (remainingItems.length === 0) {
        setActiveRuangan(null);
      }
    } else {
      if (activeRuangan !== null && activeRuangan !== item.kode_ruangan) {
        const currentSelectedRoom = Object.values(selectedMap)[0]?.nama_ruangan || activeRuangan;
        showError(
          toast,
          `Anda hanya dapat memilih layanan/paket dalam 1 ruangan yang sama per antrean kunjungan. Saat ini ruangan yang dipilih: ${currentSelectedRoom}. Batalkan pilihan sebelumnya jika ingin berganti ruangan.`
        );
        return;
      }

      const newMap = {
        ...selectedMap,
        [key]: item,
      };
      setSelectedMap(newMap);
      setActiveRuangan(item.kode_ruangan || null);

      if (consultChoiceMap[key] === undefined) {
        setConsultChoiceMap((prev) => ({ ...prev, [key]: true }));
      }
    }
  };

  const handleClearSelection = () => {
    setSelectedMap({});
    setActiveRuangan(null);
    setConsultChoiceMap({});
  };

  const selectedList = Object.values(selectedMap);
  const totalHarga = selectedList.reduce((acc, curr) => acc + (curr.jenis === 'klaim_paket' ? 0 : (curr.harga_asal ?? curr.harga)), 0);
  const totalDurasi = selectedList.reduce((acc, curr) => acc + (curr.durasi_menit || 0), 0);

  const formatRupiah = (val: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
    }).format(val);
  };

  const getItemConsultType = (item: ServiceItem) => {
    if (item.jenis === 'klaim_paket') {
      return { isWajib: false, isService: true, isOpsional: false };
    }
    const rawTipe = (item.tipe || '').toString().trim().toUpperCase();
    const isWajib = rawTipe === 'MEDICAL TREATMENT' || rawTipe.includes('MEDICAL') || rawTipe.includes('WAJIB') || item.wajib_konsultasi === 'wajib';
    const isService = rawTipe === 'SERVICE TREATMENT' || rawTipe.includes('SERVICE') || rawTipe.includes('TIDAK') || item.wajib_konsultasi === 'tidak';
    const isOpsional = !isWajib && !isService;
    return { isWajib, isService, isOpsional };
  };

  const handleProcessSubmit = async (customItems?: ServiceItem[]) => {
    const itemsToSubmit = customItems !== undefined ? customItems : selectedList;

    setSubmitting(true);
    try {
      const itemsPayload = itemsToSubmit.map((item) => {
        const key = `${item.jenis}_${item.kode_layanan}`;
        const { isWajib, isService } = getItemConsultType(item);

        let chooseConsult = false;
        if (isWajib) {
          chooseConsult = true;
        } else if (isService) {
          chooseConsult = false;
        } else {
          chooseConsult = consultChoiceMap[key] !== false;
        }

        return {
          jenis_layanan: item.jenis,
          kode_layanan: item.kode_layanan,
          kode_ruangan: item.kode_ruangan,
          nama_ruangan: item.nama_ruangan,
          butuh_konsul: chooseConsult,
          wajib_konsultasi: item.wajib_konsultasi || (isWajib ? 'wajib' : isService ? 'tidak' : 'opsional'),
          lewat_konsultasi: chooseConsult,
          kode_kepemilikan_paket_layanan: item.kode_kepemilikan_paket_layanan,
        };
      });

      const res = await postData(apiPasienAmbilAntrianLayanan, {
        no_rm: pasienData.no_rm,
        items: itemsPayload,
      });

      if (['00', '0000'].includes(res.data.status)) {
        showSuccess(toast, res.data.message || 'Pendaftaran kunjungan & antrean berhasil diterbitkan');
        onSuccess(res.data.data);
      } else {
        showError(toast, res.data.message || 'Gagal memproses pendaftaran kunjungan');
      }
    } catch (error: any) {
      const msg = error?.response?.data?.message || 'Terjadi kesalahan sistem';
      showError(toast, msg);
    } finally {
      setSubmitting(false);
    }
  };

  const confirmTakeQueue = (customItems?: ServiceItem[]) => {
    const itemsToConfirm = customItems !== undefined ? customItems : selectedList;
    if (itemsToConfirm.length === 0) {
      showError(toast, 'Silakan pilih minimal satu layanan atau paket terlebih dahulu!');
      return;
    }

    const firstItem = itemsToConfirm[0];
    const roomName = firstItem.nama_ruangan || activeRuangan;

    const listHtml = itemsToConfirm
      .map((it) => {
        const key = `${it.jenis}_${it.kode_layanan}`;
        const { isWajib, isService, isOpsional } = getItemConsultType(it);

        let badgeRoute = '';
        if (it.jenis === 'klaim_paket') {
          badgeRoute = `<span class="bg-amber-100 text-amber-800 text-[10px] px-2 py-0.5 border-round font-bold">🎁 KLAIM PAKET (Langsung ke ${it.nama_ruangan || 'Ruangan'})</span>`;
        } else if (isWajib) {
          badgeRoute = `<span class="bg-red-100 text-red-700 text-[10px] px-2 py-0.5 border-round font-bold">🩺 WAJIB KONSULTASI (Ke Ruang Konsul Dulu)</span>`;
        } else if (isService) {
          badgeRoute = `<span class="bg-green-100 text-green-700 text-[10px] px-2 py-0.5 border-round font-bold">⚡ LANGSUNG TINDAKAN (Ke ${it.nama_ruangan || 'Ruangan'})</span>`;
        } else if (isOpsional) {
          const chooseCons = consultChoiceMap[key] !== false;
          badgeRoute = chooseCons
            ? `<span class="bg-amber-100 text-amber-800 text-[10px] px-2 py-0.5 border-round font-bold">🩺 KE RUANG KONSUL DULU</span>`
            : `<span class="bg-blue-100 text-blue-700 text-[10px] px-2 py-0.5 border-round font-bold">⚡ LANGSUNG KE RUANGAN</span>`;
        }

        const priceText = it.jenis === 'klaim_paket' ? 'Rp 0 (Klaim)' : formatRupiah(it.harga_asal ?? it.harga);

        return `
          <li class="flex flex-column gap-1 py-2 border-bottom-1 surface-border">
            <div class="flex align-items-center justify-content-between">
              <span class="font-bold text-900">${it.nama}</span>
              <span class="text-blue-600 font-bold">${priceText}</span>
            </div>
            <div>${badgeRoute}</div>
          </li>
        `;
      })
      .join('');

    confirmDialog({
      header: 'Konfirmasi Terbitkan Antrean Kunjungan',
      message: (
        <div className="p-1 text-sm text-700">
          <div className="p-3 bg-blue-50 border-round-lg border-1 border-blue-200 mb-3">
            <div className="font-bold text-blue-900 text-base mb-1">{pasienData.nama}</div>
            <div className="text-xs text-blue-700">No. Rekam Medis: <strong>{pasienData.no_rm}</strong></div>
            <div className="text-xs text-blue-700 mt-1">Tujuan Ruangan: <strong>{roomName}</strong></div>
          </div>

          <p className="font-semibold text-900 mb-2">Rincian Layanan &amp; Antrean Kunjungan:</p>
          <ul
            className="list-none p-0 m-0 mb-3 max-h-12rem overflow-y-auto"
            dangerouslySetInnerHTML={{ __html: listHtml }}
          />

          <div className="flex align-items-center justify-content-between font-extrabold text-base pt-2 border-top-2 surface-border text-900">
            <span>Total Estimasi Biaya:</span>
            <span className="text-blue-600">{formatRupiah(totalHarga)}</span>
          </div>
          <p className="text-xs text-500 mt-3 m-0">
            Nomor antrean dan nomor kunjungan baru akan otomatis diterbitkan ke sistem.
          </p>
        </div>
      ),
      icon: 'pi pi-question-circle text-blue-600 text-2xl',
      acceptLabel: 'Ya, Terbitkan Antrean',
      rejectLabel: 'Batal',
      acceptClassName: 'p-button-success font-bold text-sm px-3',
      rejectClassName: 'p-button-secondary p-button-outlined text-sm px-3',
      accept: () => handleProcessSubmit(itemsToConfirm),
    });
  };

  const renderItemCard = (item: ServiceItem) => {
    const key = `${item.jenis}_${item.kode_layanan}`;
    const isSelected = !!selectedMap[key];
    const isPaket = item.jenis === 'paket';
    const isKlaim = item.jenis === 'klaim_paket';
    const isDisabled = activeRuangan !== null && activeRuangan !== item.kode_ruangan;
    const { isWajib, isService, isOpsional } = getItemConsultType(item);

    return (
      <div key={key} className="col-12 sm:col-6 lg:col-4 p-2">
        <div
          className={`h-full p-4 border-round-xl border-1 transition-all transition-duration-200 flex flex-column justify-content-between cursor-pointer ${
            isSelected
              ? isKlaim
                ? 'surface-card border-amber-500 shadow-3 bg-amber-50'
                : isPaket
                ? 'surface-card border-amber-500 shadow-3 bg-amber-50'
                : 'surface-card border-blue-600 shadow-3 bg-blue-50'
              : isDisabled
              ? 'surface-200 border-200 opacity-60 cursor-not-allowed'
              : 'surface-card surface-border hover:border-blue-400 hover:shadow-2'
          }`}
          onClick={() => {
            if (!isDisabled) handleToggleItem(item);
          }}
        >
          <div>
            <div className="flex align-items-center justify-content-between mb-2">
              <div className="flex align-items-center gap-1 flex-wrap">
                {isKlaim ? (
                  <Tag value="🎁 KLAIM SESI PAKET" severity="warning" className="text-xs font-bold" />
                ) : isPaket ? (
                  <Tag value="PAKET TREATMENT" severity="warning" className="text-xs font-bold" />
                ) : (
                  <Tag value={item.nama_kategori || 'LAYANAN'} severity="info" className="text-xs font-medium" />
                )}

                {item.total_sesi && item.total_sesi > 0 && (
                  <Tag value={`${item.total_sesi} SESI`} severity="success" className="text-xs font-bold" />
                )}

                {isWajib && <Tag value="Wajib Konsul" severity="danger" className="text-[10px] font-bold" />}
                {isService && <Tag value="Tidak Perlu Konsul" severity="success" className="text-[10px] font-bold" />}
                {isOpsional && <Tag value="Opsional Konsul" severity="info" className="text-[10px] font-bold" />}
              </div>

              <Checkbox
                checked={isSelected}
                disabled={isDisabled}
                onChange={() => {
                  if (!isDisabled) handleToggleItem(item);
                }}
              />
            </div>

            <h4 className="text-base font-bold text-900 m-0 mb-1 line-height-2">{item.nama}</h4>
            {isKlaim && item.nama_paket_asal && (
              <span className="text-xs text-amber-700 block font-semibold mb-1">Paket Asal: {item.nama_paket_asal}</span>
            )}
            <div className="flex align-items-center gap-3 text-xs text-500 mb-3">
              <span className="flex align-items-center gap-1">
                <i className="pi pi-clock text-xs" /> {item.durasi_menit} Menit
              </span>
              {isKlaim && item.sisa_sesi !== undefined && (
                <span className="font-bold text-amber-700">Sisa {item.sisa_sesi} Sesi</span>
              )}
            </div>

            <div>
              <span className={`text-base font-extrabold ${isKlaim ? 'text-amber-700' : isPaket ? 'text-amber-700' : 'text-blue-600'}`}>
                {isKlaim ? 'Rp 0 (Klaim Sesi)' : formatRupiah(item.harga_asal ?? item.harga)}
              </span>
            </div>

            {/* PILIHAN INTERAKTIF UNTUK OPSIONAL KONSUL */}
            {isSelected && isOpsional && (
              <div
                className="mt-3 pt-2 border-top-1 surface-border flex flex-column gap-1"
                onClick={(e) => e.stopPropagation()}
              >
                <span className="text-xs font-bold text-700 flex align-items-center gap-1">
                  <i className="pi pi-question-circle text-blue-500" />
                  Konsultasi Dokter Dahulu?
                </span>
                <div className="flex align-items-center gap-2 mt-1">
                  <Button
                    type="button"
                    size="small"
                    label="Ya (Ke Ruang Konsul)"
                    icon="pi pi-user-edit text-xs"
                    severity={consultChoiceMap[key] !== false ? 'warning' : 'secondary'}
                    outlined={consultChoiceMap[key] === false}
                    className="text-xs font-bold py-1 px-2 border-round-lg"
                    onClick={(e) => {
                      e.stopPropagation();
                      setConsultChoiceMap((prev) => ({ ...prev, [key]: true }));
                    }}
                  />
                  <Button
                    type="button"
                    size="small"
                    label="Tidak (Langsung Treatment)"
                    icon="pi pi-arrow-right text-xs"
                    severity={consultChoiceMap[key] === false ? 'success' : 'secondary'}
                    outlined={consultChoiceMap[key] !== false}
                    className="text-xs font-bold py-1 px-2 border-round-lg"
                    onClick={(e) => {
                      e.stopPropagation();
                      setConsultChoiceMap((prev) => ({ ...prev, [key]: false }));
                    }}
                  />
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="grid">
      <ConfirmDialog />

      <div className="col-12">
        <div className="surface-card p-4 border-round-xl border-1 surface-border shadow-1 mb-4">
          <div className="flex flex-column md:flex-row align-items-start md:align-items-center justify-content-between gap-3 border-bottom-1 surface-border pb-3 mb-3">
            <div>
              <div className="flex align-items-center gap-2 mb-1">
                <Button
                  icon="pi pi-arrow-left"
                  className="p-button-rounded p-button-text p-button-secondary p-button-sm"
                  onClick={onBack}
                  tooltip="Kembali ke Pencarian Pasien"
                />
                <h3 className="text-xl font-bold text-900 m-0">Langkah 2: Pilih Layanan &amp; Paket Treatment</h3>
              </div>
              <p className="text-500 text-sm m-0 ml-6">
                Pilih satu atau beberapa layanan/paket <strong>dalam ruangan yang sama</strong> untuk menerbitkan nomor antrean.
              </p>
            </div>

            <div className="flex align-items-center gap-2 bg-blue-50 p-3 border-round-xl border-1 border-blue-100 w-full md:w-auto">
              <i className="pi pi-user text-blue-600 text-2xl" />
              <div>
                <span className="text-xs text-500 block">Pasien Terdaftar</span>
                <span className="font-extrabold text-blue-900 text-base">{pasienData.nama}</span>
                <span className="text-xs text-blue-700 block font-semibold">No. RM: {pasienData.no_rm}</span>
              </div>
            </div>
          </div>

          {/* INFO RUANGAN AKTIF */}
          {activeRuangan && selectedList.length > 0 && (
            <div className="flex align-items-center justify-content-between flex-wrap gap-2 p-3 bg-blue-50 border-round-lg border-1 border-blue-200 mb-3">
              <div className="flex align-items-center gap-2">
                <i className="pi pi-check-circle text-blue-600 text-lg" />
                <div>
                  <span className="text-xs text-500 block">Ruangan Aktif</span>
                  <span className="font-bold text-blue-800 text-sm">
                    {selectedList[0]?.nama_ruangan || activeRuangan}
                  </span>
                  <span className="text-xs text-blue-600 ml-2">
                    ({selectedList.length} layanan/paket dipilih)
                  </span>
                </div>
              </div>
              <Button
                label="Batalkan Semua Pilihan"
                icon="pi pi-times"
                size="small"
                severity="danger"
                outlined
                className="border-round-lg text-xs"
                onClick={handleClearSelection}
              />
            </div>
          )}

          {loading ? (
            <div className="flex flex-column align-items-center justify-content-center p-6 my-4">
              <ProgressSpinner style={{ width: '40px', height: '40px' }} strokeWidth="4" />
              <span className="text-500 text-sm mt-3 font-medium">Memuat opsi layanan &amp; paket...</span>
            </div>
          ) : (
            <TabView
              className="p-tabview-custom"
              activeIndex={activeTabIndex}
              onTabChange={(e) => setActiveTabIndex(e.index)}
            >
              {(() => {
                const panels: React.ReactNode[] = [];

                const claimablePackages = (ownedPackages || []).filter((pkg: any) => {
                  if (pkg.status && pkg.status.toLowerCase() !== 'aktif') return false;
                  return (pkg.details || []).some((det: any) => (det.sisa_sesi || 0) > 0);
                });

                if (claimablePackages.length > 0) {
                  panels.push(
                    <TabPanel
                      key="owned_packages_tab"
                      header={`🎁 Paket Dimiliki Pasien (${claimablePackages.length})`}
                      leftIcon="pi pi-gift mr-2 text-amber-600 font-bold"
                    >
                      <div className="p-3 bg-amber-50 border-round-lg border-1 border-amber-200 mb-3 flex align-items-center gap-2">
                        <i className="pi pi-info-circle text-amber-600 text-lg" />
                        <span className="text-sm text-amber-900 font-semibold">
                          Pasien ini memiliki paket aktif! Centang sesi layanan di bawah ini untuk klaim antrean kunjungan tanpa biaya tambahan (Rp 0).
                        </span>
                      </div>

                      <div className="grid">
                        {claimablePackages.map((pkg: any) => {
                          return (pkg.details || [])
                            .filter((det: any) => (det.sisa_sesi || 0) > 0)
                            .map((det: any) => {
                              const claimItem: ServiceItem = {
                                jenis: 'klaim_paket',
                                kode_layanan: det.kode_layanan,
                                kode_kategori: 'KLAIM PAKET',
                                nama_kategori: `Klaim Paket`,
                                nama: `${det.nama_layanan || det.kode_layanan}`,
                                harga: 0,
                                harga_asal: 0,
                                durasi_menit: 45,
                                total_sesi: det.sesi_total,
                                sisa_sesi: det.sisa_sesi,
                                kode_ruangan: 'RNG-001',
                                nama_ruangan: 'Ruang Treatment',
                                tipe: 'BEAUTY TREATMENT',
                                kode_kepemilikan_paket_layanan: pkg.kode_kepemilikan_paket_layanan,
                                nama_paket_asal: pkg.nama_paket,
                              };

                              return renderItemCard(claimItem);
                            });
                        })}
                      </div>
                    </TabPanel>
                  );
                }

                ruangans.forEach((ruang) => {
                  const isRuangActive = activeRuangan === ruang.kode_ruangan;
                  const isRuangDisabled = activeRuangan !== null && activeRuangan !== ruang.kode_ruangan;
                  const ruangSelectedCount = ruang.items.filter(
                    (item) => !!selectedMap[`${item.jenis}_${item.kode_layanan}`]
                  ).length;
                  const roomTitle = ruang.nama_ruangan
                    ? `${ruang.nama_ruangan}`
                    : `Ruangan ${ruang.kode_ruangan}`;
                  const countSuffix = ruangSelectedCount > 0 ? ` (${ruangSelectedCount})` : '';
                  const tabHeaderString = `${roomTitle}${countSuffix}`;

                  panels.push(
                    <TabPanel
                      key={ruang.kode_ruangan}
                      header={tabHeaderString}
                      leftIcon={`pi ${isRuangActive ? 'pi-check-circle' : 'pi-building'} mr-2`}
                    >
                      {isRuangDisabled && (
                        <div className="flex align-items-center gap-2 p-3 mb-3 bg-orange-50 border-round-lg border-1 border-orange-200">
                          <i className="pi pi-info-circle text-orange-500" />
                          <span className="text-sm text-orange-700">
                            Ruangan ini tidak bisa dipilih karena Anda sudah memilih layanan/paket dari ruangan <strong>{selectedList[0]?.nama_ruangan || activeRuangan}</strong>.
                            Batalkan semua pilihan terlebih dahulu untuk berpindah ruangan.
                          </span>
                        </div>
                      )}
                      {ruang.items.length === 0 ? (
                        <div className="flex flex-column align-items-center justify-content-center p-5 surface-card border-round-xl border-1 surface-border my-3 text-center">
                          <i className="pi pi-inbox text-400 text-4xl mb-2" />
                          <span className="text-700 font-bold block text-base">{roomTitle}</span>
                          <span className="text-500 text-sm mt-1">Belum ada layanan atau paket yang tersedia di ruangan ini.</span>
                        </div>
                      ) : (
                        <div className="grid">
                          {ruang.items.map((item) => renderItemCard(item))}
                        </div>
                      )}
                    </TabPanel>
                  );
                });

                return panels;
              })()}
            </TabView>
          )}
        </div>
      </div>

      {/* FIXED / STICKY BOTTOM SUMMARY BAR */}
      <div
        className="fixed bottom-0 left-0 right-0 surface-card border-top-1 surface-border p-3 shadow-5 flex align-items-center justify-content-between"
        style={{ zIndex: 1000 }}
      >
        <div className="flex align-items-center gap-4 pl-3">
          <div>
            <span className="text-xs text-500 block">Dipilih:</span>
            <span className="font-extrabold text-900 text-lg">{selectedList.length} Item</span>
          </div>
          <div className="hidden sm:block border-left-1 surface-border pl-4">
            <span className="text-xs text-500 block">Total Estimasi Durasi:</span>
            <span className="font-bold text-700 text-base flex align-items-center gap-1">
              <i className="pi pi-clock text-blue-500" /> {totalDurasi} Menit
            </span>
          </div>
          <div className="border-left-1 surface-border pl-4">
            <span className="text-xs text-500 block">Total Estimasi Biaya:</span>
            <span className="font-extrabold text-blue-600 text-xl">{formatRupiah(totalHarga)}</span>
          </div>
        </div>

        <div className="flex align-items-center gap-2 pr-3">
          <Button
            label="Batalkan"
            icon="pi pi-times"
            severity="secondary"
            outlined
            className="border-round-lg font-bold px-3"
            onClick={onBack}
          />
          <Button
            label={submitting ? 'Memproses...' : 'Terbitkan Antrean Kunjungan'}
            icon="pi pi-check"
            severity="success"
            loading={submitting}
            className="border-round-lg font-bold px-4"
            onClick={() => confirmTakeQueue()}
          />
        </div>
      </div>
    </div>
  );
};
