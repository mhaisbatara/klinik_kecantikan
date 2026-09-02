'use client';

import React, { useState, useEffect } from 'react';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { InputTextarea } from 'primereact/inputtextarea';
import { InputNumber } from 'primereact/inputnumber';
import { Dropdown } from 'primereact/dropdown';
import { Checkbox } from 'primereact/checkbox';
import { Tag } from 'primereact/tag';
import { Toast } from 'primereact/toast';
import { ProgressSpinner } from 'primereact/progressspinner';
import postData from '@/lib/axios/postData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { Dialog } from 'primereact/dialog';
import { AntrianLayananData, RuanganFormField } from './interfaces';
import { FormRuanganFotoUploader } from './FormRuanganFotoUploader';
import { RekomendasiTreatmentPanel, RekomendasiItem } from './RekomendasiTreatmentPanel';
import { DialogHasilTerbitAntrian } from './DialogHasilTerbitAntrian';
import { HasilTreatmentPanel } from './HasilTreatmentPanel';

interface ActiveTreatmentPanelProps {
    activePatient: AntrianLayananData | null;
    nextWaitingPatient: AntrianLayananData | null;
    kodeRuangan: string;
    namaRuangan: string;
    isKonsultasi?: boolean;
    toast: React.RefObject<Toast>;
    getGridData: () => void;
    handleAksi: (item: AntrianLayananData, customAksi?: string, skipFormValidation?: boolean) => void;
    playChime: () => void;
    speakNomorLayanan: (noAntrian: string, namaPasien?: string, namaRuangan?: string) => void;
    onManageFormClick: () => void;
    petugasJagaList?: any[];
}

export const ActiveTreatmentPanel: React.FC<ActiveTreatmentPanelProps> = ({
    activePatient,
    nextWaitingPatient,
    kodeRuangan,
    namaRuangan,
    isKonsultasi = false,
    toast,
    getGridData,
    handleAksi,
    playChime,
    speakNomorLayanan,
    onManageFormClick,
}) => {
    const [fields, setFields] = useState<RuanganFormField[]>([]);
    const [loadingFields, setLoadingFields] = useState<boolean>(false);
    const [formData, setFormData] = useState<Record<string, any>>({});
    const [catatanPetugas, setCatatanPetugas] = useState<string>('');
    const [rekomendasiItems, setRekomendasiItems] = useState<RekomendasiItem[]>([]);
    const [saving, setSaving] = useState<boolean>(false);

    // Dropdown Petugas / Dokter (SIP) State
    const [karyawanOptions, setKaryawanOptions] = useState<any[]>([]);
    const [selectedPetugas, setSelectedPetugas] = useState<string>('');

    // Step state: 'form' (Form Penanganan) vs 'hasil' (Hasil Treatment & Produk Kasir)
    const [activeStep, setActiveStep] = useState<'form' | 'hasil'>('form');
    // Setelah simpan, kunci semua input form agar tidak bisa diubah lagi
    const [isFormSaved, setIsFormSaved] = useState<boolean>(false);
    const [isHasilSaved, setIsHasilSaved] = useState<boolean>(false);

    // Modal Sukses Terbit Antrean & Transaksi
    const [showHasilModal, setShowHasilModal] = useState<boolean>(false);
    const [hasilAntrianList, setHasilAntrianList] = useState<any[]>([]);
    const [hasilTransaksiDraft, setHasilTransaksiDraft] = useState<any | null>(null);
    const [hasilKodeKunjungan, setHasilKodeKunjungan] = useState<string>('');
    const [hasilPasienNama, setHasilPasienNama] = useState<string>('');
    const [hasilNoRm, setHasilNoRm] = useState<string>('');

    useEffect(() => {
        loadKaryawan();
    }, []);

    useEffect(() => {
        if (kodeRuangan) {
            loadFormFields();
        }
    }, [kodeRuangan]);

    const [currentAntrianId, setCurrentAntrianId] = useState<string>('');

    useEffect(() => {
        if (activePatient?.kode_antrian_layanan) {
            if (activePatient.kode_antrian_layanan !== currentAntrianId) {
                setCurrentAntrianId(activePatient.kode_antrian_layanan);
                let initialForm = {};
                let hasForm = false;
                if (activePatient.hasil_form) {
                    try {
                        initialForm = typeof activePatient.hasil_form === 'string' ? JSON.parse(activePatient.hasil_form) : activePatient.hasil_form;
                        hasForm = Object.keys(initialForm).length > 0;
                    } catch (_) {}
                }
                setFormData(initialForm);
                setCatatanPetugas(activePatient.catatan_petugas || '');
                setSelectedPetugas(activePatient.kode_karyawan || '');
                setActiveStep(hasForm ? 'hasil' : 'form');
                setIsFormSaved(hasForm);
                setIsHasilSaved(false);

                if (isKonsultasi) {
                    loadPendaftaranItems(activePatient.kode_kunjungan);
                } else {
                    setRekomendasiItems([]);
                }
            } else if (activePatient.kode_karyawan && !selectedPetugas) {
                setSelectedPetugas(activePatient.kode_karyawan);
            }
        } else {
            setCurrentAntrianId('');
            setFormData({});
            setCatatanPetugas('');
            setRekomendasiItems([]);
            setSelectedPetugas('');
            setActiveStep('form');
            setIsFormSaved(false);
            setIsHasilSaved(false);
        }
    }, [activePatient?.kode_antrian_layanan, isKonsultasi]);

    const loadPendaftaranItems = async (kodeKunjungan?: string) => {
        if (!kodeKunjungan) return;
        try {
            const res = await postData('/master/antrian-layanan-pendaftaran-items', {
                kode_kunjungan: kodeKunjungan,
            });
            if (['00', '0000'].includes(res.data.status) && res.data.data?.length > 0) {
                setRekomendasiItems(res.data.data);
            } else {
                setRekomendasiItems([]);
            }
        } catch (e) {
            setRekomendasiItems([]);
        }
    };

    const loadKaryawan = async () => {
        try {
            const res = await postData('/master/karyawan-data', { page: 1, perPage: 100 });
            const list = res.data?.data || [];
            const opts = list.map((k: any) => ({
                label: `${k.nama}${k.jabatan ? ` (${k.jabatan.toUpperCase()})` : ''}`,
                value: k.no_sip,
                nama: k.nama,
                jabatan: k.jabatan,
                no_sip: k.no_sip,
            }));
            setKaryawanOptions(opts);
        } catch (_) {
            // silent fail
        }
    };

    const loadFormFields = async () => {
        if (!kodeRuangan) return;
        setLoadingFields(true);
        try {
            const res = await postData('/master/ruangan-form-data', { kode_ruangan: kodeRuangan });
            setFields(res.data.data || []);
        } catch (_) {
            // silent fail
        } finally {
            setLoadingFields(false);
        }
    };

    const handleFieldChange = (key: string, value: any) => {
        if (isFormSaved) return;
        setFormData((prev) => ({ ...prev, [key]: value }));
    };

    const executeSaveForm = async (targetStatus?: string) => {
        if (!activePatient) return;
        setSaving(true);
        try {
            const payload: any = {
                kode_antrian_layanan: activePatient.kode_antrian_layanan,
                kode_karyawan: selectedPetugas,
                no_sip: selectedPetugas,
                hasil_form: formData,
                catatan_petugas: catatanPetugas,
                rekomendasi_items: rekomendasiItems,
            };
            if (targetStatus) {
                payload.status_tindakan = targetStatus;
            }

            const res = await postData('/master/antrian-layanan-simpan-rekomendasi', payload);
            showSuccess(toast, res.data.message || 'Form penanganan berhasil disimpan.');

            const antrianBaru = res.data?.data?.antrian_layanan_baru || [];
            const trxDraft = res.data?.data?.transaksi_draft || null;
            const kodeKunjungan = res.data?.data?.kode_kunjungan || '';

            // Simpan info pasien SEBELUM getGridData() mengosongkan activePatient
            if (antrianBaru.length > 0 || trxDraft) {
                setHasilPasienNama(activePatient?.nama_pasien || '');
                setHasilNoRm(activePatient?.no_rm || '');
                setHasilAntrianList(antrianBaru);
                setHasilTransaksiDraft(trxDraft);
                setHasilKodeKunjungan(kodeKunjungan);
            }

            // Update local officer info so header badge displays doctor name immediately
            if (selectedPetugas) {
                const foundKaryawan = karyawanOptions.find((k) => k.value === selectedPetugas);
                if (foundKaryawan) {
                    activePatient.nama_petugas = foundKaryawan.nama;
                    activePatient.kode_karyawan = selectedPetugas;
                }
            }

            // Kunci form setelah berhasil simpan tanpa mengosongkan nilainya (form tidak bisa diotak-atik)
            setIsFormSaved(true);

            // Refresh data
            getGridData();

            if (antrianBaru.length > 0 || trxDraft) {
                setShowHasilModal(true);
            }
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal menyimpan catatan & rekomendasi penanganan');
        } finally {
            setSaving(false);
        }
    };

    // State Konfirmasi Simpan
    const [showConfirmModal, setShowConfirmModal] = useState<boolean>(false);
    const [targetStatusToSave, setTargetStatusToSave] = useState<string | undefined>(undefined);

    const handleSaveForm = (targetStatus?: string) => {
        if (!activePatient) return;

        // Validation: Petugas / Dokter Examiner wajib dipilih
        if (!selectedPetugas) {
            showError(toast, 'Petugas / Dokter Penanggung Jawab wajib dipilih!');
            return;
        }

        // Check mandatory fields
        for (const f of fields) {
            if (f.is_required) {
                const val = formData[f.label_field];
                if (f.tipe_field === 'upload_foto') {
                    const hasBefore = val && typeof val === 'object' && val.before;
                    if (!hasBefore) {
                        showError(toast, `Field '${f.label_field}' wajib mengunggah foto!`);
                        return;
                    }
                } else if (!val) {
                    showError(toast, `Field '${f.label_field}' wajib diisi!`);
                    return;
                }
            }
        }

        setTargetStatusToSave(targetStatus);
        setShowConfirmModal(true);
    };

    const handleConfirmAccept = () => {
        setShowConfirmModal(false);
        executeSaveForm(targetStatusToSave);
    };

    // ─── IF NO PATIENT IS CURRENTLY IN TREATMENT ─────────────────────────────
    if (!activePatient) {
        return (
            <>
                <div className="card shadow-2 border-round-xl p-4 surface-card border-top-3 border-teal-500 mb-4">
                    <div className="flex flex-column sm:flex-row align-items-start sm:align-items-center justify-content-between gap-3">
                        <div className="flex align-items-center gap-3">
                            <div className="w-3rem h-3rem border-circle bg-teal-100 text-teal-700 flex align-items-center justify-content-center text-xl font-bold flex-shrink-0">
                                👨‍⚕️
                            </div>
                            <div>
                                <span className="text-xs font-bold text-teal-700 bg-teal-100 px-2 py-1 border-round-md inline-block mb-1">
                                    Sesi Penanganan Ruangan: {namaRuangan}
                                </span>
                                <h3 className="text-xl font-bold text-900 m-0">Belum Ada Pasien Yang Sedang Ditangani</h3>
                                <p className="text-xs text-500 m-0 mt-1">
                                    {nextWaitingPatient
                                        ? `Pasien berikutnya: No. #${nextWaitingPatient.nomor_antrian} — ${nextWaitingPatient.nama_pasien} (${nextWaitingPatient.nama_layanan})`
                                        : 'Tidak ada antrean pasien yang sedang menunggu di ruangan ini.'}
                                </p>
                            </div>
                        </div>

                        <div className="flex align-items-center gap-2 flex-wrap">
                            <Button
                                label="⚙️ Form Ruangan"
                                icon="pi pi-cog"
                                outlined
                                size="small"
                                severity="help"
                                onClick={onManageFormClick}
                            />

                            {nextWaitingPatient && (
                                <Button
                                    label={`📢 Panggil Pasien Next (#${nextWaitingPatient.nomor_antrian})`}
                                    icon="pi pi-megaphone"
                                    size="small"
                                    className="font-bold bg-teal-600 border-none text-white"
                                    onClick={() => handleAksi(nextWaitingPatient, 'dipanggil')}
                                />
                            )}
                        </div>
                    </div>
                </div>

                <DialogHasilTerbitAntrian
                    visible={showHasilModal}
                    onHide={() => setShowHasilModal(false)}
                    pasienNama={hasilPasienNama}
                    noRm={hasilNoRm}
                    kodeKunjungan={hasilKodeKunjungan}
                    antrianList={hasilAntrianList}
                    transaksiDraft={hasilTransaksiDraft}
                />
            </>
        );
    }

    // ─── ACTIVE PATIENT IN TREATMENT CARD & FORM EMBED ────────────────────────
    return (
        <div className="card shadow-3 border-round-xl p-0 mb-4 surface-card overflow-hidden border-2 border-teal-500">
            {/* ACTIVE PATIENT HEADER HERO */}
            <div className="p-4 bg-teal-700 text-white">
                <div className="flex flex-column md:flex-row align-items-start md:align-items-center gap-3 mb-3">
                    <div className="bg-white text-teal-900 border-round-xl px-4 py-2 text-center shadow-2" style={{ minWidth: '80px' }}>
                        <span className="text-xs font-bold block text-teal-600 white-space-nowrap">NO. ANTREAN</span>
                        <span className="text-4xl font-black">{activePatient.nomor_antrian}</span>
                    </div>

                    <div className="flex-1">
                        <div className="flex align-items-center gap-2 mb-1">
                            <Tag value="PASIEN SEDANG DITANGANI" severity="success" className="text-xs font-bold px-2" />
                            <span className="text-xs text-teal-200">Jam Datang: {activePatient.jam_datang || '-'}</span>
                        </div>
                        <h2 className="text-xl font-black text-white m-0 mt-1">
                            {activePatient.nama_pasien || 'Pasien'}
                            <span className="text-sm font-normal text-teal-200 ml-2">(RM: {activePatient.no_rm})</span>
                        </h2>
                        <div className="flex align-items-center gap-2 mt-2 flex-wrap">
                            <span className="inline-flex align-items-center gap-1 bg-teal-800 text-teal-100 text-xs font-semibold px-2 py-1 border-round-md">
                                <i className="pi pi-briefcase text-xs" />
                                {activePatient.nama_layanan}
                            </span>
                            <span className="inline-flex align-items-center gap-1 bg-teal-800 text-teal-100 text-xs font-semibold px-2 py-1 border-round-md">
                                <i className="pi pi-building text-xs" />
                                {namaRuangan}
                            </span>
                            {(activePatient.nama_petugas || karyawanOptions.find((k) => k.value === selectedPetugas)?.nama) && (
                                <span className="inline-flex align-items-center gap-1 bg-teal-900 text-teal-100 text-xs font-semibold px-2 py-1 border-round-md border-1 border-teal-400">
                                    <i className="pi pi-user text-xs" />
                                    Petugas: {karyawanOptions.find((k) => k.value === selectedPetugas)?.nama || activePatient.nama_petugas}
                                </span>
                            )}
                        </div>
                    </div>
                </div>

                <div className="flex align-items-center justify-content-end gap-2 flex-wrap pt-2 border-top-1 border-teal-600">
                    <Button
                        label="Panggil Ulang"
                        icon="pi pi-volume-up"
                        size="small"
                        className="text-xs font-semibold bg-white-alpha-20 text-white border-1 border-white-alpha-40 border-round-lg hover:bg-white-alpha-30"
                        onClick={() => {
                            playChime();
                            speakNomorLayanan(activePatient.nomor_antrian, activePatient.nama_pasien, namaRuangan);
                        }}
                    />
                    <Button
                        label="Batalkan"
                        icon="pi pi-times"
                        size="small"
                        className="text-xs font-semibold bg-red-500 text-white border-none border-round-lg hover:bg-red-600"
                        onClick={() => handleAksi(activePatient, 'batal')}
                    />
                    <Button
                        label="Selesaikan Tindakan"
                        icon="pi pi-check"
                        size="small"
                        disabled={(!isFormSaved && !activePatient?.hasil_form) || !isHasilSaved}
                        className={`text-xs font-bold border-none border-round-lg ${
                            (!isFormSaved && !activePatient?.hasil_form) || !isHasilSaved
                                ? 'bg-gray-400 text-white cursor-not-allowed opacity-60'
                                : 'bg-green-500 text-white hover:bg-green-600 shadow-2'
                        }`}
                        tooltip={
                            !isHasilSaved
                                ? 'Tombol Selesaikan Tindakan baru bisa diklik setelah data Form Hasil Treatment (Step 2) disimpan'
                                : ''
                        }
                        onClick={() => {
                            if (!isFormSaved && !activePatient?.hasil_form) {
                                showError(toast, 'Harap isi dan simpan Form Penanganan Pasien (Step 1) terlebih dahulu.');
                                return;
                            }
                            if (!isHasilSaved) {
                                showError(toast, 'Selesaikan Tindakan baru bisa diklik setelah data Form Hasil Treatment (Step 2) disimpan!');
                                return;
                            }
                            handleAksi(activePatient, 'selesai', true);
                        }}
                    />
                </div>
            </div>

            {/* PANEL HEADER BAR */}
            <div className="flex flex-column sm:flex-row align-items-center justify-content-between p-3 bg-teal-50 border-bottom-1 surface-border gap-2">
                <div className="flex align-items-center gap-2">
                    <i className="pi pi-user-edit text-teal-700 text-lg" />
                    <span className="text-sm font-extrabold text-teal-900">Form Penanganan &amp; Rekomendasi Medis Pasien</span>
                </div>
            </div>

            {/* FORM PENANGANAN PASIEN */}
            <div className="p-4 flex flex-column gap-4 surface-ground">
                    {/* SECTION PETUGAS / DOKTER PENANGGUNG JAWAB (SESUAI SIP) */}
                    <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
                        <div className="flex align-items-center justify-content-between mb-3 pb-2 border-bottom-1 surface-border">
                            <label className="text-xs font-extrabold text-teal-800 uppercase tracking-wider flex align-items-center gap-2 m-0">
                                <i className="pi pi-user text-teal-600 text-sm" />
                                PETUGAS / DOKTER PENANGGUNG JAWAB (SESUAI SIP)
                            </label>
                            <span className="text-[10px] text-500 font-semibold">Tersimpan berdasar No. SIP</span>
                        </div>
                        <div className="p-fluid">
                            <Dropdown
                                value={selectedPetugas}
                                options={karyawanOptions}
                                onChange={(e) => setSelectedPetugas(e.value)}
                                placeholder="-- Pilih Nama Petugas / Dokter --"
                                filter
                                filterBy="label,value,nama"
                                showClear
                                disabled={isFormSaved}
                                className="w-full text-sm border-round-md shadow-1 bg-white"
                                valueTemplate={(option) => {
                                    if (option) {
                                        return (
                                            <div className="flex align-items-center gap-2">
                                                <span className="font-bold text-teal-900">{option.nama || option.label}</span>
                                                {option.value && (
                                                    <span className="text-xs text-500 font-normal">(No. SIP: {option.value})</span>
                                                )}
                                            </div>
                                        );
                                    }
                                    return <span>-- Pilih Nama Petugas / Dokter --</span>;
                                }}
                                itemTemplate={(option) => (
                                    <div className="flex align-items-center justify-content-between py-1">
                                        <div>
                                            <span className="font-bold text-teal-900 block text-sm">{option.nama || option.label}</span>
                                            <span className="text-xs text-500 block">No. SIP: {option.value}</span>
                                        </div>
                                    </div>
                                )}
                            />
                        </div>
                    </div>
                    {/* 1. SECTION ISIAN KHUSUS FORM RUANGAN */}
                    {loadingFields ? (
                        <div className="flex align-items-center justify-content-center py-4">
                            <ProgressSpinner style={{ width: '30px', height: '30px' }} />
                            <span className="ml-2 text-xs text-500">Memuat format form ruangan...</span>
                        </div>
                    ) : fields.length > 0 && (
                        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
                            <div className="flex align-items-center justify-content-between mb-3 pb-2 border-bottom-1 surface-border">
                                <label className="text-xs font-extrabold text-teal-800 uppercase tracking-wider flex align-items-center gap-2 m-0">
                                    <i className="pi pi-file-edit text-teal-600 text-sm" />
                                    ISIAN KHUSUS FORM RUANGAN ({namaRuangan})
                                </label>
                                <Tag value={`${fields.length} Field`} severity="info" className="text-[10px] font-bold" />
                            </div>

                            <div className="grid formgrid p-fluid">
                                {fields
                                    .filter((f) => !(f.label_field || '').toLowerCase().includes('treatment yang direkomendasikan'))
                                    .map((f, i) => {
                                        const val = formData[f.label_field];
                                        const isReq = Boolean(f.is_required);
                                        let optionsList: string[] = [];
                                        if (f.tipe_field === 'select' && f.options) {
                                            optionsList = f.options.split(',').map((s) => s.trim());
                                        }

                                        const colSize = 'col-12';

                                        return (
                                            <div key={f.id || i} className={`${colSize} mb-3`}>
                                                {f.tipe_field === 'upload_foto' ? (
                                                    <FormRuanganFotoUploader
                                                        value={val}
                                                        onChange={(newVal) => handleFieldChange(f.label_field, newVal)}
                                                        labelField={f.label_field}
                                                        isRequired={isReq}
                                                        toast={toast}
                                                        disabled={isFormSaved}
                                                    />
                                                ) : (
                                                    <>
                                                        <label className="block text-xs font-bold text-700 mb-2">
                                                            {f.label_field} {isReq && <span className="text-red-500 font-bold">*</span>}
                                                        </label>

                                                    {f.tipe_field === 'textarea' ? (
                                                        <InputTextarea
                                                            value={val}
                                                            onChange={(e) => handleFieldChange(f.label_field, e.target.value)}
                                                            rows={3}
                                                            placeholder={`Masukkan ${f.label_field}...`}
                                                            disabled={isFormSaved}
                                                            className="w-full text-sm border-round-md shadow-1 bg-white border-300 focus:border-teal-500"
                                                        />
                                                    ) : f.tipe_field === 'number' ? (
                                                        <InputNumber
                                                            value={typeof val === 'number' ? val : null}
                                                            onValueChange={(e) => handleFieldChange(f.label_field, e.value)}
                                                            placeholder={`Masukkan ${f.label_field}`}
                                                            disabled={isFormSaved}
                                                            className="w-full text-sm border-round-md shadow-1 bg-white"
                                                        />
                                                    ) : f.tipe_field === 'select' ? (
                                                        <Dropdown
                                                            value={val}
                                                            options={optionsList.map((o) => ({ label: o, value: o }))}
                                                            onChange={(e) => handleFieldChange(f.label_field, e.value)}
                                                            placeholder={`Pilih ${f.label_field}...`}
                                                            disabled={isFormSaved}
                                                            className="w-full text-sm border-round-md shadow-1 bg-white"
                                                        />
                                                    ) : f.tipe_field === 'checkbox' ? (
                                                        <div className="flex align-items-center gap-2 bg-white p-2.5 border-round-md border-1 border-300">
                                                            <Checkbox
                                                                checked={Boolean(val)}
                                                                disabled={isFormSaved}
                                                                onChange={(e) => handleFieldChange(f.label_field, e.checked)}
                                                            />
                                                            <span className="text-xs text-800 font-semibold">{f.label_field}</span>
                                                        </div>
                                                    ) : (
                                                        <InputText
                                                            value={val}
                                                            onChange={(e) => handleFieldChange(f.label_field, e.target.value)}
                                                            placeholder={`Masukkan ${f.label_field}...`}
                                                            disabled={isFormSaved}
                                                            className="w-full text-sm border-round-md shadow-1 bg-white"
                                                        />
                                                    )}
                                                </>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    )}

                    {/* 2. SECTION REKOMENDASI TREATMENT & PRODUK — HANYA DI RUANG KONSULTASI */}
                    {isKonsultasi && (
                        <RekomendasiTreatmentPanel
                            toast={toast}
                            selectedItems={rekomendasiItems}
                            onChangeSelectedItems={setRekomendasiItems}
                            disabled={isFormSaved}
                        />
                    )}

                    {/* 3. SECTION CATATAN PETUGAS / OBSERVASI RUANGAN */}
                    <div className="p-3 border-round-xl border-1 surface-border bg-white shadow-1">
                        <label className="block text-xs font-extrabold text-teal-800 uppercase tracking-wider mb-2 flex align-items-center gap-2">
                            <i className="pi pi-pencil text-teal-600 text-sm" />
                            CATATAN PETUGAS &amp; OBSERVASI TINDAKAN RUANGAN
                        </label>
                        <InputTextarea
                            value={catatanPetugas}
                            onChange={(e) => setCatatanPetugas(e.target.value)}
                            rows={4}
                            placeholder="Tuliskan rincian hasil tindakan, obat/alat yang digunakan, resep, atau catatan khusus observasi pasien saat berada di ruangan ini..."
                            disabled={isFormSaved}
                            className="w-full text-sm border-round-md bg-white border-300 focus:border-teal-500"
                        />
                    </div>

                    {/* SAVE ACTION FOOTER BAR */}
                    <div className="flex align-items-center justify-content-end gap-3 mt-2 pt-3 border-top-1 surface-border">
                        {isFormSaved ? (
                            <div className="flex align-items-center gap-3 flex-wrap">
                                <Tag value="✅ Form Penanganan Telah Disimpan & Dikunci" severity="success" className="px-3 py-2 text-xs font-bold" />
                            </div>
                        ) : (
                            <Button
                                label={isKonsultasi ? "Simpan Form & Selesaikan Konsultasi" : "Simpan Form Penanganan & Selesaikan"}
                                icon="pi pi-check-circle"
                                severity="success"
                                size="small"
                                loading={saving}
                                onClick={() => handleSaveForm('selesai')}
                                className="font-bold text-xs bg-teal-600 border-none border-round-lg px-4 text-white shadow-2"
                            />
                        )}
                    </div>
                </div>

            {/* CONFIRM DIALOG & HASIL MODAL */}
            <Dialog
                visible={showConfirmModal && !showHasilModal}
                onHide={() => setShowConfirmModal(false)}
                header="Konfirmasi Penanganan & Rekomendasi"
                style={{ width: '480px' }}
                modal
                className="p-fluid"
                footer={
                    <div className="flex justify-content-end gap-2">
                        <Button
                            label="Batal"
                            icon="pi pi-times"
                            className="p-button-outlined p-button-secondary text-xs"
                            onClick={() => setShowConfirmModal(false)}
                        />
                        <Button
                            label="Ya, Simpan & Terbitkan"
                            icon="pi pi-check"
                            className="p-button-success font-bold text-xs"
                            onClick={handleConfirmAccept}
                        />
                    </div>
                }
            >
                <div className="flex flex-column gap-3 py-1 text-left">
                    <div className="p-3 border-round-xl" style={{ background: '#f0fdfa', border: '1.5px solid #99f6e4' }}>
                        <span className="text-[10px] font-bold uppercase block" style={{ color: '#0d9488' }}>Pasien Aktif</span>
                        <span className="font-extrabold text-sm block" style={{ color: '#134e4a' }}>{activePatient?.nama_pasien || hasilPasienNama || 'Pasien'}</span>
                        <span className="text-xs" style={{ color: '#0f766e' }}>No. RM: {activePatient?.no_rm || hasilNoRm} | Ruangan: {namaRuangan}</span>
                    </div>

                    <div className="flex flex-column gap-2">
                        {rekomendasiItems.filter((i) => ['layanan', 'paket_layanan'].includes(i.jenis)).length > 0 && (
                            <div className="p-3 border-round-xl text-xs" style={{ background: '#f0fdfa', border: '1.5px solid #5eead4' }}>
                                <span className="font-bold block mb-1" style={{ color: '#0f766e' }}>
                                    <i className="pi pi-ticket mr-1" />
                                    Menerbitkan {rekomendasiItems.filter((i) => ['layanan', 'paket_layanan'].includes(i.jenis)).length} Nomor Antrean Layanan:
                                </span>
                                <span className="font-semibold" style={{ color: '#115e59' }}>{rekomendasiItems.filter((i) => ['layanan', 'paket_layanan'].includes(i.jenis)).map((l) => l.nama).join(', ')}</span>
                            </div>
                        )}

                        {rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).length > 0 && (
                            <div className="p-3 border-round-xl text-xs" style={{ background: '#fffbeb', border: '1.5px solid #fcd34d' }}>
                                <span className="font-bold block mb-1" style={{ color: '#b45309' }}>
                                    <i className="pi pi-shopping-bag mr-1" />
                                    Memasukkan {rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).length} Produk ke Draf Transaksi Kasir:
                                </span>
                                <span className="font-semibold" style={{ color: '#78350f' }}>{rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).map((p) => `${p.nama} (${p.qty || 1}x)`).join(', ')}</span>
                            </div>
                        )}
                    </div>

                    <p className="text-xs text-gray-700 m-0">
                        Apakah Anda yakin ingin menyimpan hasil penanganan &amp; menerbitkan nomor antrean/transaksi untuk pasien ini?
                    </p>
                </div>
            </Dialog>

            <DialogHasilTerbitAntrian
                visible={showHasilModal}
                onHide={() => setShowHasilModal(false)}
                pasienNama={hasilPasienNama}
                noRm={hasilNoRm}
                kodeKunjungan={hasilKodeKunjungan}
                antrianList={hasilAntrianList}
                transaksiDraft={hasilTransaksiDraft}
            />
        </div>
    );
};
