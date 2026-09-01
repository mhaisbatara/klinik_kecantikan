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
    petugasJagaList?: any[];
    toast: React.RefObject<Toast>;
    getGridData: () => void;
    handleAksi: (item: AntrianLayananData, customAksi?: string) => void;
    playChime: () => void;
    speakNomorLayanan: (noAntrian: string, namaPasien?: string, namaRuangan?: string) => void;
    onManageFormClick: () => void;
}

export const ActiveTreatmentPanel: React.FC<ActiveTreatmentPanelProps> = ({
    activePatient,
    nextWaitingPatient,
    kodeRuangan,
    namaRuangan,
    isKonsultasi = false,
    petugasJagaList = [],
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

    // State Dokter / Petugas Jaga
    const [dokterBertugas, setDokterBertugas] = useState<string>('');

    useEffect(() => {
        if (petugasJagaList && petugasJagaList.length > 0) {
            const initialName = petugasJagaList[0].nama_karyawan;
            setDokterBertugas(initialName);
            setFormData((prev) => ({ ...prev, 'Dokter / Petugas Jaga': initialName }));
        }
    }, [petugasJagaList]);

    // Step state: 'form' (Form Penanganan) vs 'hasil' (Hasil Treatment & Produk Kasir)
    const [activeStep, setActiveStep] = useState<'form' | 'hasil'>('form');
    // Setelah simpan, kunci semua input form agar tidak bisa diubah lagi
    const [isFormSaved, setIsFormSaved] = useState<boolean>(false);

    // Modal Sukses Terbit Antrean & Transaksi
    const [showHasilModal, setShowHasilModal] = useState<boolean>(false);
    const [hasilAntrianList, setHasilAntrianList] = useState<any[]>([]);
    const [hasilTransaksiDraft, setHasilTransaksiDraft] = useState<any | null>(null);
    const [hasilKodeKunjungan, setHasilKodeKunjungan] = useState<string>('');
    const [hasilPasienNama, setHasilPasienNama] = useState<string>('');
    const [hasilNoRm, setHasilNoRm] = useState<string>('');

    useEffect(() => {
        if (kodeRuangan) {
            loadFormFields();
        }
    }, [kodeRuangan]);

    useEffect(() => {
        if (activePatient) {
            // Form data dipindahkan ke trx_rekam_medis; form dimulai kosong setiap sesi baru
            setCatatanPetugas('');
            setFormData({});
            setRekomendasiItems([]);
            setActiveStep('form');
            setIsFormSaved(false);
        } else {
            setFormData({});
            setCatatanPetugas('');
            setRekomendasiItems([]);
            setActiveStep('form');
            setIsFormSaved(false);
        }
    }, [activePatient?.kode_antrian_layanan]);

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

            // Kunci form setelah berhasil simpan tanpa mengosongkan nilainya
            setIsFormSaved(true);

            // Pindah otomatis ke step Hasil Treatment (Foto After & Produk Kasir)
            setActiveStep('hasil');

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
                        className="text-xs font-bold bg-green-500 text-white border-none border-round-lg hover:bg-green-600"
                        onClick={() => handleAksi(activePatient, 'selesai')}
                    />
                </div>
            </div>

            {/* STEP NAVIGATION HEADER BAR (Hanya untuk Ruangan Tindakan non-konsultasi) */}
            {!isKonsultasi && (
                <div className="flex flex-column sm:flex-row align-items-center justify-content-between p-3 bg-teal-50 border-bottom-1 surface-border gap-2">
                    <div className="flex align-items-center gap-2 w-full sm:w-auto">
                        <button
                            type="button"
                            onClick={() => setActiveStep('form')}
                            className={`flex align-items-center gap-2 px-3 py-2 border-round-lg font-bold text-xs cursor-pointer border-none transition-all ${
                                activeStep === 'form'
                                    ? 'bg-teal-700 text-white shadow-2'
                                    : 'surface-card text-700 hover:surface-200 border-1 surface-border'
                            }`}
                        >
                            <span className={`w-1.5rem h-1.5rem border-circle flex align-items-center justify-content-center text-xs font-extrabold ${
                                activeStep === 'form' ? 'bg-white text-teal-800' : 'bg-teal-100 text-teal-800'
                            }`}>
                                1
                            </span>
                            <span>1. Form Penanganan Pasien</span>
                        </button>

                        <i className="pi pi-chevron-right text-400 text-sm hidden sm:inline-block" />

                        <button
                            type="button"
                            onClick={() => setActiveStep('hasil')}
                            className={`flex align-items-center gap-2 px-3 py-2 border-round-lg font-bold text-xs cursor-pointer border-none transition-all ${
                                activeStep === 'hasil'
                                    ? 'bg-teal-700 text-white shadow-2'
                                    : 'surface-card text-700 hover:surface-200 border-1 surface-border'
                            }`}
                        >
                            <span className={`w-1.5rem h-1.5rem border-circle flex align-items-center justify-content-center text-xs font-extrabold ${
                                activeStep === 'hasil' ? 'bg-white text-teal-800' : 'bg-teal-100 text-teal-800'
                            }`}>
                                2
                            </span>
                            <span>2. Hasil Treatment (Foto After) &amp; Rekomendasi Produk</span>
                        </button>
                    </div>

                    {activeStep === 'hasil' && (
                        <Button
                            label="Kembali ke Form Penanganan"
                            icon="pi pi-arrow-left"
                            outlined
                            size="small"
                            severity="secondary"
                            className="text-xs font-bold border-round-lg"
                            onClick={() => setActiveStep('form')}
                        />
                    )}
                </div>
            )}

            {/* STEP 1: FORM PENANGANAN PASIEN */}
            {activeStep === 'form' || isKonsultasi ? (
                <div className="p-4 flex flex-column gap-4 surface-ground">
                    {/* 1. SECTION ISIAN KHUSUS FORM RUANGAN */}
                    {loadingFields ? (
                        <div className="flex align-items-center justify-content-center py-4">
                            <ProgressSpinner style={{ width: '30px', height: '30px' }} />
                            <span className="ml-2 text-xs text-500">Memuat format form ruangan...</span>
                        </div>
                    ) : (
                        <div className="surface-card p-3 border-round-xl border-1 surface-border shadow-1">
                            <div className="flex align-items-center justify-content-between mb-3 pb-2 border-bottom-1 surface-border">
                                <label className="text-xs font-extrabold text-teal-800 uppercase tracking-wider flex align-items-center gap-2 m-0">
                                    <i className="pi pi-file-edit text-teal-600 text-sm" />
                                    ISIAN KHUSUS FORM RUANGAN ({namaRuangan})
                                </label>
                                <Tag value={`${fields.length + 1} Field`} severity="info" className="text-[10px] font-bold" />
                            </div>

                            <div className="grid formgrid p-fluid">
                                {/* DOKTER / PETUGAS JAGA HARI INI (DITARUH PALING ATAS SEBELUM KELUHAN UTAMA) */}
                                <div className="col-12 mb-3">
                                    <label className="block text-xs font-bold text-700 mb-2 flex align-items-center justify-content-between">
                                        <span className="flex align-items-center gap-1.5 text-teal-900 font-extrabold">
                                            <i className="pi pi-user-edit text-teal-600 font-bold" />
                                            Dokter / Petugas Jaga Hari Ini <span className="text-red-500 font-bold">*</span>
                                        </span>
                                    </label>
                                    {petugasJagaList && petugasJagaList.length > 0 ? (
                                        <Dropdown
                                            value={dokterBertugas || (petugasJagaList[0] ? petugasJagaList[0].nama_karyawan : '')}
                                            options={petugasJagaList.map((p) => ({
                                                label: `👨‍⚕️ ${p.nama_karyawan} (${(p.jabatan || 'DOKTER').toUpperCase()} • Jam ${p.jam_mulai} - ${p.jam_selesai})`,
                                                value: p.nama_karyawan,
                                            }))}
                                            onChange={(e) => {
                                                setDokterBertugas(e.value);
                                                handleFieldChange('Dokter / Petugas Jaga', e.value);
                                            }}
                                            placeholder="-- Pilih Dokter / Petugas Jaga --"
                                            disabled={isFormSaved}
                                            className="w-full text-sm font-bold border-round-md shadow-1 bg-white border-teal-300 text-teal-900"
                                        />
                                    ) : (
                                        <InputText
                                            value="Tidak ada jadwal dokter/petugas aktif di ruangan ini"
                                            disabled
                                            className="w-full text-sm border-round-md shadow-1 bg-amber-50 text-amber-900 border-amber-200"
                                        />
                                    )}
                                </div>

                                {fields.map((f, i) => {
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
                                                    <label className="block text-xs font-bold text-700 mb-2 flex align-items-center justify-content-between">
                                                        <span>
                                                            {f.label_field} {isReq && <span className="text-red-500 font-bold">*</span>}
                                                        </span>
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
                                <Tag
                                    value={isKonsultasi ? "✅ Form Konsultasi & Rekomendasi Telah Disimpan" : "✅ Form Penanganan Telah Disimpan & Dikunci"}
                                    severity="success"
                                    className="px-3 py-2 text-xs font-bold"
                                />
                                {!isKonsultasi && (
                                    <Button
                                        label="Lanjut ke Hasil Treatment →"
                                        severity="success"
                                        size="small"
                                        onClick={() => setActiveStep('hasil')}
                                        className="font-bold text-xs bg-teal-600 border-none border-round-lg px-4 text-white shadow-2"
                                    />
                                )}
                            </div>
                        ) : (
                            <Button
                                label={isKonsultasi ? "Simpan Rekomendasi & Penanganan Pasien" : "Simpan Form Penanganan & Lanjut ke Hasil Treatment"}
                                icon={isKonsultasi ? "pi pi-check-circle" : "pi pi-arrow-right"}
                                iconPos="right"
                                severity="success"
                                size="small"
                                loading={saving}
                                onClick={() => handleSaveForm()}
                                className="font-bold text-xs bg-teal-600 border-none border-round-lg px-4 text-white shadow-2"
                            />
                        )}
                    </div>
                </div>
            ) : (
                /* STEP 2: PANEL HASIL TREATMENT & REKOMENDASI PRODUK KASIR */
                <div className="p-4 surface-ground">
                    <HasilTreatmentPanel
                        activePatient={activePatient}
                        toast={toast}
                        getGridData={getGridData}
                        kodeRuangan={kodeRuangan}
                        namaRuangan={namaRuangan}
                    />
                </div>
            )}

            {/* CONFIRM DIALOG & HASIL MODAL */}
            <Dialog
                visible={showConfirmModal && !showHasilModal}
                onHide={() => setShowConfirmModal(false)}
                header={
                    <div className="flex align-items-center gap-3">
                        <div
                            className="flex align-items-center justify-content-center border-round-xl"
                            style={{
                                width: '40px',
                                height: '40px',
                                background: 'linear-gradient(135deg, #0d9488, #059669)',
                                boxShadow: '0 4px 12px rgba(13, 148, 136, 0.3)',
                            }}
                        >
                            <i className="pi pi-shield text-white text-xl" />
                        </div>
                        <div>
                            <span className="text-lg font-black text-900 block" style={{ lineHeight: 1.2 }}>
                                Persetujuan &amp; Konfirmasi Penanganan Pasien
                            </span>
                            <span className="text-xs text-500 font-medium">
                                Konfirmasi data form penanganan dan rekomendasi produk kasir
                            </span>
                        </div>
                    </div>
                }
                style={{ width: '540px' }}
                modal
                className="p-fluid"
                footer={
                    <div className="flex align-items-center justify-content-end gap-2 pt-2 border-top-1 surface-border">
                        <Button
                            label="Batal"
                            icon="pi pi-times"
                            outlined
                            severity="secondary"
                            className="font-bold text-xs border-round-lg px-3 py-2"
                            onClick={() => setShowConfirmModal(false)}
                        />
                        <Button
                            label="✓ Setujui &amp; Simpan Penanganan"
                            icon="pi pi-check-circle"
                            severity="success"
                            className="font-extrabold text-xs border-round-lg px-4 py-2 shadow-2 bg-teal-600 border-none hover:bg-teal-700"
                            onClick={handleConfirmAccept}
                        />
                    </div>
                }
            >
                <div className="flex flex-column gap-3 py-2 text-left">
                    <div
                        className="p-3 border-round-2xl relative overflow-hidden"
                        style={{
                            background: 'linear-gradient(135deg, #f0fdfa, #ccfbf1)',
                            border: '1.5px solid #99f6e4',
                        }}
                    >
                        <div className="flex align-items-center justify-content-between">
                            <div>
                                <span className="text-[10px] font-extrabold uppercase tracking-wider block text-teal-700 mb-0.5">
                                    PASIEN AKTIF TINDAKAN
                                </span>
                                <span className="font-black text-base text-teal-950 block">
                                    {activePatient?.nama_pasien || hasilPasienNama || 'Pasien'}
                                </span>
                                <span className="text-xs text-teal-800 font-medium">
                                    No. RM: <strong>{activePatient?.no_rm || hasilNoRm}</strong> | Ruangan: <strong>{namaRuangan}</strong>
                                </span>
                            </div>
                            <Tag value={`No. #${activePatient?.nomor_antrian || '-'}`} severity="success" className="text-sm font-extrabold px-3 py-1.5 border-round-xl shadow-1" />
                        </div>
                    </div>

                    <div className="surface-card p-3 border-round-2xl border-1 surface-border shadow-1 flex flex-column gap-2">
                        <span className="text-xs font-extrabold text-700 uppercase tracking-wider block border-bottom-1 surface-border pb-2">
                            📋 Ringkasan Data Ditambahkan
                        </span>

                        {rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).length > 0 ? (
                            <div className="p-2.5 border-round-xl text-xs surface-50 flex flex-column gap-1">
                                <span className="font-bold text-amber-700 flex align-items-center gap-1.5">
                                    <i className="pi pi-shopping-bag text-amber-600" />
                                    {rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).length} Produk Rekomendasi Kasir:
                                </span>
                                <span className="font-semibold text-800 pl-4">
                                    {rekomendasiItems.filter((i) => ['produk', 'paket_produk'].includes(i.jenis)).map((p) => `${p.nama} (${p.qty || 1}x)`).join(', ')}
                                </span>
                            </div>
                        ) : (
                            <span className="text-xs text-500 italic p-1">Tanpa produk tambahan yang dimasukkan.</span>
                        )}
                    </div>

                    <div
                        className="p-3 border-round-2xl flex align-items-start gap-3"
                        style={{
                            background: '#f0fdfa',
                            border: '1.5px solid #99f6e4',
                        }}
                    >
                        <i className="pi pi-check-circle text-teal-600 text-2xl mt-0.5 flex-shrink-0" />
                        <div>
                            <span className="font-extrabold text-xs text-teal-950 block mb-1">
                                Persetujuan Tindakan Pasien (Informed Consent)
                            </span>
                            <p className="text-xs text-teal-800 m-0 leading-relaxed font-medium">
                                Apakah Anda yakin data penanganan dan rekomendasi produk untuk pasien ini sudah sesuai dan disetujui pasien?
                            </p>
                        </div>
                    </div>
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
