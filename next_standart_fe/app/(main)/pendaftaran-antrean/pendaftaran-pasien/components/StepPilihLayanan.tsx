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

  useEffect(() => {
    fetchOptions();
    if (pasienData?.no_rm) {
      fetchOwnedPackages();
    }
  }, [pasienData?.no_rm]);

  const fetchOptions = async () => {
    setLoading(true);
    try {
      const res = await postData(apiPasienLayananOptions);
      if (['00', '0000'].includes(res.data.status)) {
        setRuangans(res.data.data.ruangan_layanan || res.data.data.kategori_layanan || []);
      } else {
        showError(toast, res.data.message || 'Gagal memuat pilihan layanan');
      }
    } catch (error: any) {
      showError(toast, 'Terjadi kesalahan saat memuat daftar layanan');
    } finally {
      setLoading(false);
    }
  };

  const fetchOwnedPackages = async () => {
    try {
      const res = await postData(apiPasienKepemilikanPaket, {
        no_rm: pasienData.no_rm,
        status: 'aktif',
      });
      if (['00', '0000'].includes(res.data.status)) {
        setOwnedPackages(res.data.data || []);
      }
    } catch (e) {
      console.error('Failed to load owned packages for patient');
    }
  };

  /**
   * Toggle pilih/batal item layanan atau paket.
   */
  const handleToggleItem = (item: ServiceItem) => {
    const key = `${item.jenis}_${item.kode_layanan}`;
    const targetRoomCode = item.kode_ruangan || 'LAINNYA';

    setSelectedMap((prev) => {
      const next = { ...prev };

      if (next[key]) {
        delete next[key];
        if (Object.keys(next).length === 0) {
          setActiveRuangan(null);
        }
        return next;
      }

      if (activeRuangan !== null && activeRuangan !== targetRoomCode) {
        const activeRoomName = Object.values(prev)[0]?.nama_ruangan || activeRuangan;
        showError(
          toast,
          `Tidak bisa pilih layanan/paket dari ruangan berbeda. Saat ini aktif: ruangan "${activeRoomName}". Batalkan pilihan terlebih dahulu jika ingin berpindah ruangan.`
        );
        return prev;
      }

      next[key] = item;
      setActiveRuangan(targetRoomCode);

      setConsultChoiceMap((cPrev) => {
        if (cPrev[key] === undefined) {
          return { ...cPrev, [key]: true };
        }
        return cPrev;
      });

      return next;
    });
  };

  const handleClearSelection = () => {
    setSelectedMap({});
    setActiveRuangan(null);
    setConsultChoiceMap({});
  };

  const selectedList = Object.values(selectedMap);
  const totalHarga = selectedList.reduce((sum, i) => sum + (i.harga_asal ?? i.harga), 0);
  const totalDurasi = selectedList.reduce((sum, i) => sum + i.durasi_menit, 0);

  const formatRupiah = (val: number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val);
  };

  const getItemConsultType = (item: ServiceItem) => {
    if (item.jenis === 'klaim_paket') {
      return { isWajib: false, isService: true, isOpsional: false };
    }
    const rawTipe = (item.tipe || '').toString().trim().toUpperCase();
    const isWajib = rawTipe === 'MEDICAL TREATMENT' || rawTipe.includes('MEDICAL') || rawTipe.includes('WAJIB');
    const isService = rawTipe === 'SERVICE TREATMENT' || rawTipe.includes('SERVICE') || rawTipe.includes('TIDAK');
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
    const itemsToSubmit = customItems !== undefined ? customItems : selectedList;

    if (itemsToSubmit.length === 0) {
      confirmDialog({
        message: (
          <div className="flex flex-column align-items-center text-center gap-2 py-2">
            <i className="pi pi-question-circle text-blue-500 text-4xl mb-1" />
            <span className="font-bold text-lg text-900">Pendaftaran Kunjungan Tanpa Layanan?</span>
            <span className="text-sm text-600 max-w-24rem">
              Anda tidak memilih layanan/paket treatment. Pasien <strong>{pasienData.nama}</strong> ({pasienData.no_rm}) akan didaftarkan antrean kunjungan ke <strong>Ruang Konsultasi Dokter</strong>.
            </span>
          </div>
        ),
        header: 'Konfirmasi Pendaftaran Kunjungan',
        icon: 'pi pi-info-circle',
        acceptLabel: 'Ya, Terbitkan Antrean Konsul',
        rejectLabel: 'Batal',
        acceptClassName: 'p-button-primary font-bold px-4',
        rejectClassName: 'p-button-outlined p-button-secondary',
        accept: () => handleProcessSubmit([]),
      });
      return;
    }

    const firstItem = itemsToSubmit[0];
    const roomName = firstItem.nama_ruangan || 'Ruang Treatment';

    confirmDialog({
      message: (
        <div className="flex flex-column gap-3 py-1">
          <div className="text-center pb-2 border-bottom-1 surface-border">
            <i className="pi pi-[#3b82f6] pi-ticket text-blue-500 text-4xl mb-2" />
            <h4 className="font-extrabold text-xl text-900 m-0">Terbitkan Nomor Antrean Kunjungan?</h4>
            <p className="text-sm text-500 m-0 mt-1">
              Pasien <strong>{pasienData.nama}</strong> ({pasienData.no_rm})
            </p>
          </div>

          <div className="surface-100 p-3 border-round-xl">
            <span className="text-xs text-500 block mb-2 font-bold uppercase">Daftar Layanan Dipilih:</span>
            {itemsToSubmit.map((item, idx) => {
              const key = `${item.jenis}_${item.kode_layanan}`;
              const { isWajib, isService } = getItemConsultType(item);
              let statusText = 'Konsultasi Dokter Dahulu';
              if (isService) statusText = 'Langsung Treatment';
              else if (!isWajib && consultChoiceMap[key] === false) statusText = 'Langsung Treatment (Tanpa Konsul)';

              return (
                <div key={idx} className="flex align-items-center justify-content-between py-1 text-sm border-bottom-1 border-200 last:border-none">
                  <div>
                    <span className="font-bold text-900">{item.nama}</span>
                    {item.jenis === 'klaim_paket' && <Tag value="KLAIM PAKET" severity="warning" className="ml-2 text-[10px]" />}
                    <span className="text-xs text-blue-600 block">{statusText}</span>
                  </div>
                  <span className="font-extrabold text-slate-800">{formatRupiah(item.harga)}</span>
                </div>
              );
            })}
          </div>
        </div>
      ),
      header: 'Konfirmasi Pendaftaran',
      acceptLabel: 'Ya, Terbitkan Antrean Now',
      rejectLabel: 'Batal',
      acceptClassName: 'p-button-success font-bold px-4',
      rejectClassName: 'p-button-outlined p-button-secondary',
      accept: () => handleProcessSubmit(itemsToSubmit),
    });
  };

  const renderItemCard = (item: ServiceItem) => {
    const key = `${item.jenis}_${item.kode_layanan}`;
    const isSelected = !!selectedMap[key];
    const isPaket = item.jenis === 'paket';
    const isKlaim = item.jenis === 'klaim_paket';
    const targetRoomCode = item.kode_ruangan || 'LAINNYA';
    const isDisabled = activeRuangan !== null && activeRuangan !== targetRoomCode && !isSelected;

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
            <TabView className="p-tabview-custom">
              {/* TAB KHUSUS: PAKET DIMILIKI PASIEN (KLAIM SESI) */}
              {ownedPackages && ownedPackages.length > 0 && (
                <TabPanel
                  header={`🎁 Paket Dimiliki Pasien (${ownedPackages.length})`}
                  leftIcon="pi pi-gift mr-2 text-amber-600 font-bold"
                >
                  <div className="p-3 bg-amber-50 border-round-lg border-1 border-amber-200 mb-3 flex align-items-center gap-2">
                    <i className="pi pi-info-circle text-amber-600 text-lg" />
                    <span className="text-sm text-amber-900 font-semibold">
                      Pasien ini memiliki paket aktif! Centang sesi layanan di bawah ini untuk klaim antrean kunjungan tanpa biaya tambahan (Rp 0).
                    </span>
                  </div>

                  <div className="grid">
                    {ownedPackages.map((pkg) => {
                      return (pkg.details || []).map((det: any) => {
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
              )}

              {/* TABS RUANGAN LAYANAN & PAKET STANDARD */}
              {ruangans.map((ruang) => {
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

                return (
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
              })}
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
