'use client';

import React, { useState, useEffect } from 'react';
import { InputText } from 'primereact/inputtext';
import { InputTextarea } from 'primereact/inputtextarea';
import { Button } from 'primereact/button';
import { Divider } from 'primereact/divider';
import { Dropdown } from 'primereact/dropdown';
import { Checkbox } from 'primereact/checkbox';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Dialog } from 'primereact/dialog';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { confirmDialog } from 'primereact/confirmdialog';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { getData, putData, postData } from '@/lib/axios/postData';

interface FasilitasItem {
    nama: string;
    icon: string;
}

interface InformasiCabangSectionProps {
    session: any;
    toast: React.RefObject<any>;
}

const POPULAR_EMOJIS = ['🏥', '💆‍♀️', '🔬', '💊', '🚗', '📶', '☕', '🧴', '✨', '🛋️', '💳', '👶'];

const DAYS_LIST = [
    { num: '1', label: 'Senin' },
    { num: '2', label: 'Selasa' },
    { num: '3', label: 'Rabu' },
    { num: '4', label: 'Kamis' },
    { num: '5', label: 'Jumat' },
    { num: '6', label: 'Sabtu' },
    { num: '7', label: 'Minggu' },
];

const DAY_NAMES: Record<number, string> = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu',
};

export default function InformasiCabangSection({ session, toast }: InformasiCabangSectionProps) {
    const userRole = (session?.user?.role || '').toLowerCase();
    const isSuperAdmin = userRole === 'superadmin';
    const userKodeCabang = session?.user?.kode_cabang || 'CBG-001';

    const [selectedKodeCabang, setSelectedKodeCabang] = useState<string>(userKodeCabang);
    const [cabangOptions, setCabangOptions] = useState<{ label: string; value: string; }[]>([]);

    const [loading, setLoading] = useState<boolean>(false);
    const [saving, setSaving] = useState<boolean>(false);

    // Form fields
    const [kodeCabang, setKodeCabang] = useState<string>('');
    const [namaCabang, setNamaCabang] = useState<string>('');
    const [alamat, setAlamat] = useState<string>('');
    const [noTelp, setNoTelp] = useState<string>('');
    const [email, setEmail] = useState<string>('');
    const [pjManager, setPjManager] = useState<string>('');
    const [jamBuka, setJamBuka] = useState<string>('09:00');
    const [jamTutup, setJamTutup] = useState<string>('20:00');
    const [selectedDays, setSelectedDays] = useState<string[]>(['1', '2', '3', '4', '5', '6', '7']);
    const [fasilitas, setFasilitas] = useState<FasilitasItem[]>([]);
    const [tz, setTz] = useState<string>('Asia/Jakarta');

    // Dialog Fasilitas
    const [dialogFasilitasVisible, setDialogFasilitasVisible] = useState<boolean>(false);
    const [editFasilitasIndex, setEditFasilitasIndex] = useState<number | null>(null);
    const [fasilitasForm, setFasilitasForm] = useState<FasilitasItem>({ nama: '', icon: '🏥' });

    // Format helper hari operasional
    const formatHariOperasional = (days: string[]) => {
        if (!days || days.length === 0) return 'Tidak ada hari dipilih';
        const numList = days.map(d => parseInt(d, 10)).filter(d => d >= 1 && d <= 7).sort((a, b) => a - b);
        if (numList.length === 7) return 'Senin – Minggu';

        let isContiguous = true;
        for (let i = 0; i < numList.length - 1; i++) {
            if (numList[i + 1] !== numList[i] + 1) {
                isContiguous = false;
                break;
            }
        }

        if (isContiguous && numList.length >= 3) {
            return `${DAY_NAMES[numList[0]]} – ${DAY_NAMES[numList[numList.length - 1]]}`;
        }

        return numList.map(n => DAY_NAMES[n]).join(', ');
    };

    const getTzLabel = (timezone: string) => {
        const s = (timezone || '').toLowerCase();
        if (s.includes('makassar') || s.includes('bali') || s.includes('ujung_pandang') || s.includes('wita')) return 'WITA';
        if (s.includes('jayapura') || s.includes('wit')) return 'WIT';
        return 'WIB';
    };

    const previewJamOperasional = `${jamBuka.slice(0, 5)} – ${jamTutup.slice(0, 5)} ${getTzLabel(tz)} (${formatHariOperasional(selectedDays)})`;

    // Load data cabang
    const fetchCabangData = async (targetCode: string) => {
        setLoading(true);
        try {
            const endpoint = isSuperAdmin
                ? `/cabang/profil?kode_cabang=${encodeURIComponent(targetCode)}`
                : `/cabang/profil`;

            let res;
            try {
                res = await getData(endpoint);
            } catch (_) {
                // Fallback to postData jika GET interceptor belum aktif
                res = await postData(endpoint, { kode_cabang: targetCode });
            }

            const data = res?.data?.data;
            if (data) {
                setKodeCabang(data.kode_cabang || targetCode);
                setNamaCabang(data.nama_cabang || '');
                setAlamat(data.alamat || '');
                setNoTelp(data.no_telp || '');
                setEmail(data.email || '');
                setPjManager(data.pj_manager || '');
                setJamBuka(data.jam_buka ? String(data.jam_buka).slice(0, 5) : '09:00');
                setJamTutup(data.jam_tutup ? String(data.jam_tutup).slice(0, 5) : '20:00');

                if (data.hari_operasional) {
                    const days = String(data.hari_operasional).split(',').map((d: string) => d.trim()).filter(Boolean);
                    setSelectedDays(days);
                } else {
                    setSelectedDays(['1', '2', '3', '4', '5', '6', '7']);
                }

                if (Array.isArray(data.fasilitas)) {
                    setFasilitas(data.fasilitas);
                } else {
                    setFasilitas([]);
                }

                setTz(data.tz || 'Asia/Jakarta');
            }

            if (res?.data?.cabang_options && isSuperAdmin) {
                const opts = res.data.cabang_options.map((c: any) => ({
                    label: `${c.kode_cabang} - ${c.nama_cabang}`,
                    value: c.kode_cabang,
                }));
                setCabangOptions(opts);
            }
        } catch (err: any) {
            const msg = err?.response?.data?.message || err?.message || 'Gagal memuat profil cabang';
            showError(toast, msg);
        } finally {
            setLoading(false);
        }
    };

    // Load options for superadmin jika belum ada
    const fetchAllBranchOptions = async () => {
        try {
            const res = await postData('/master/cabang-data', { status: 'aktif' });
            if (res?.data?.data && Array.isArray(res.data.data)) {
                const opts = res.data.data.map((c: any) => ({
                    label: `${c.kode_cabang} - ${c.nama_cabang}`,
                    value: c.kode_cabang,
                }));
                setCabangOptions(opts);
            }
        } catch (_) {}
    };

    useEffect(() => {
        const target = isSuperAdmin ? selectedKodeCabang : userKodeCabang;
        setKodeCabang(target);
        fetchCabangData(target);
        if (isSuperAdmin && cabangOptions.length === 0) {
            fetchAllBranchOptions();
        }
    }, [selectedKodeCabang, userKodeCabang]);

    // Handle day checkbox toggle
    const toggleDay = (dayNum: string) => {
        let updated = [...selectedDays];
        if (updated.includes(dayNum)) {
            updated = updated.filter(d => d !== dayNum);
        } else {
            updated.push(dayNum);
        }
        updated.sort((a, b) => parseInt(a, 10) - parseInt(b, 10));
        setSelectedDays(updated);
    };

    // Fasilitas reorder
    const moveFasilitasUp = (index: number) => {
        if (index <= 0) return;
        const updated = [...fasilitas];
        const temp = updated[index - 1];
        updated[index - 1] = updated[index];
        updated[index] = temp;
        setFasilitas(updated);
    };

    const moveFasilitasDown = (index: number) => {
        if (index >= fasilitas.length - 1) return;
        const updated = [...fasilitas];
        const temp = updated[index + 1];
        updated[index + 1] = updated[index];
        updated[index] = temp;
        setFasilitas(updated);
    };

    // Fasilitas Dialog
    const handleOpenAddFasilitas = () => {
        setEditFasilitasIndex(null);
        setFasilitasForm({ nama: '', icon: '🏥' });
        setDialogFasilitasVisible(true);
    };

    const handleOpenEditFasilitas = (index: number, item: FasilitasItem) => {
        setEditFasilitasIndex(index);
        setFasilitasForm({ nama: item.nama, icon: item.icon || '✨' });
        setDialogFasilitasVisible(true);
    };

    const handleDeleteFasilitas = (index: number) => {
        const targetName = fasilitas[index]?.nama;
        confirmDialog({
            message: `Apakah Anda yakin ingin menghapus fasilitas "${targetName}"?`,
            header: 'Konfirmasi Hapus Fasilitas',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: () => {
                const updated = fasilitas.filter((_, i) => i !== index);
                setFasilitas(updated);
            },
        });
    };

    const handleSaveFasilitasModal = () => {
        const trimmedNama = (fasilitasForm.nama || '').trim();
        if (!trimmedNama) {
            showError(toast, 'Nama fasilitas tidak boleh kosong.');
            return;
        }

        // Cek duplikasi
        const isDuplicate = fasilitas.some((f, idx) => {
            if (editFasilitasIndex !== null && idx === editFasilitasIndex) return false;
            return f.nama.toLowerCase() === trimmedNama.toLowerCase();
        });

        if (isDuplicate) {
            showError(toast, `Fasilitas "${trimmedNama}" sudah ada dalam daftar.`);
            return;
        }

        const newItem: FasilitasItem = {
            nama: trimmedNama,
            icon: (fasilitasForm.icon || '✨').trim(),
        };

        let updated = [...fasilitas];
        if (editFasilitasIndex !== null) {
            updated[editFasilitasIndex] = newItem;
        } else {
            if (updated.length >= 20) {
                showError(toast, 'Maksimal 20 fasilitas cabang.');
                return;
            }
            updated.push(newItem);
        }

        setFasilitas(updated);
        setDialogFasilitasVisible(false);
    };

    // Handle Save Section Cabang
    const handleSaveCabang = async () => {
        // Validasi
        if (!namaCabang.trim()) {
            showError(toast, 'Nama Cabang wajib diisi!');
            return;
        }
        if (!alamat.trim()) {
            showError(toast, 'Alamat Cabang wajib diisi!');
            return;
        }
        if (!noTelp.trim()) {
            showError(toast, 'Nomor Telepon / WhatsApp wajib diisi!');
            return;
        }
        if (email.trim()) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email.trim())) {
                showError(toast, 'Format email resmi cabang tidak valid!');
                return;
            }
        }
        if (!jamBuka.trim() || !jamTutup.trim()) {
            showError(toast, 'Jam operasional buka dan tutup wajib diisi!');
            return;
        }

        const parseMinutes = (t: string) => {
            const [h, m] = t.split(':').map(Number);
            return h * 60 + (m || 0);
        };

        if (parseMinutes(jamTutup) <= parseMinutes(jamBuka)) {
            showError(toast, 'Jam tutup operasional harus lebih malam daripada jam buka!');
            return;
        }

        if (selectedDays.length === 0) {
            showError(toast, 'Pilih minimal 1 hari operasional!');
            return;
        }

        setSaving(true);
        try {
            const payload = {
                kode_cabang: kodeCabang,
                nama_cabang: namaCabang.trim(),
                alamat: alamat.trim(),
                no_telp: noTelp.trim(),
                email: email.trim() || null,
                pj_manager: pjManager.trim() || null,
                jam_buka: `${jamBuka.slice(0, 5)}:00`,
                jam_tutup: `${jamTutup.slice(0, 5)}:00`,
                hari_operasional: selectedDays.join(','),
                fasilitas: fasilitas,
            };

            let res;
            try {
                res = await putData('/cabang/profil', payload);
            } catch (putErr: any) {
                // Fallback jika BFF interceptor atau client fallback ke POST
                res = await postData('/cabang/profil', payload);
            }

            if (res?.data?.status === '00' || res?.status === 200) {
                showSuccess(toast, res?.data?.message || 'Informasi cabang berhasil diperbarui!');
                fetchCabangData(kodeCabang);
            } else {
                showError(toast, res?.data?.message || 'Gagal menyimpan informasi cabang.');
            }
        } catch (error: any) {
            const msg = error?.response?.data?.message || error?.message || 'Gagal menyimpan informasi cabang.';
            showError(toast, msg);
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="col-12 mt-5">
            <div className="card border-round-2xl border-1 surface-border p-4 bg-white shadow-2">
                {/* Section Header */}
                <div className="flex flex-column md:flex-row md:align-items-center justify-content-between gap-3 mb-2">
                    <div>
                        <span className="text-emerald-700 font-bold uppercase text-xs tracking-wider flex align-items-center gap-2">
                            <i className="pi pi-compass text-base" />
                            4. Informasi Cabang (Tampil di Aplikasi Pasien) – {namaCabang || kodeCabang} ({kodeCabang})
                        </span>
                        <p className="text-xs text-600 m-0 mt-1 font-medium">
                            Data di bagian ini khusus cabang Anda dan tampil di halaman <strong>Cabang Klinik Kami</strong> di aplikasi pasien. Berbeda dengan data kop dokumen di atas.
                        </p>
                    </div>

                    {/* Dropdown Cabang Khusus Superadmin */}
                    {isSuperAdmin && (
                        <div className="flex align-items-center gap-2">
                            <span className="text-xs font-bold text-700 white-space-nowrap">
                                <i className="pi pi-filter mr-1 text-emerald-600" /> Pilih Cabang:
                            </span>
                            <Dropdown
                                value={selectedKodeCabang}
                                options={cabangOptions.length > 0 ? cabangOptions : [{ label: `${kodeCabang} - ${namaCabang}`, value: kodeCabang }]}
                                onChange={(e) => setSelectedKodeCabang(e.value)}
                                className="p-inputtext-sm"
                                style={{ minWidth: '220px' }}
                            />
                        </div>
                    )}
                </div>

                <Divider className="mt-2 mb-4" />

                {loading ? (
                    <div className="text-center py-5">
                        <i className="pi pi-spin pi-spinner text-3xl text-emerald-600" />
                        <p className="text-sm text-600 mt-2 font-medium">Memuat data cabang...</p>
                    </div>
                ) : (
                    <div className="grid formgrid p-fluid">
                        {/* Sub-bagian 1: Kontak & Penanggung Jawab */}
                        <div className="col-12 mb-2">
                            <span className="text-800 font-bold text-sm flex align-items-center gap-2">
                                <i className="pi pi-id-card text-emerald-600" />
                                Kontak &amp; Penanggung Jawab Cabang
                            </span>
                        </div>

                        <div className="field col-12 md:col-4 mb-3">
                            <label htmlFor="cabangKode" className="font-semibold text-xs mb-1 text-700">
                                Kode Cabang (Sistem)
                            </label>
                            <InputText
                                id="cabangKode"
                                value={kodeCabang}
                                disabled
                                className="p-disabled bg-gray-100 font-mono text-sm"
                            />
                        </div>

                        <div className="field col-12 md:col-8 mb-3">
                            <label htmlFor="cabangNama" className="font-semibold text-xs mb-1 text-800">
                                Nama Cabang <span className="text-red-500">*</span>
                            </label>
                            <IconField iconPosition="left">
                                <InputIcon className="pi pi-building text-emerald-600" />
                                <InputText
                                    id="cabangNama"
                                    value={namaCabang}
                                    onChange={(e) => setNamaCabang(e.target.value)}
                                    placeholder="Contoh: Klinik Cabang Utama"
                                    className="text-sm"
                                />
                            </IconField>
                        </div>

                        <div className="field col-12 mb-3">
                            <label htmlFor="cabangAlamat" className="font-semibold text-xs mb-1 text-800">
                                Alamat Lokasi Cabang <span className="text-red-500">*</span>
                            </label>
                            <InputTextarea
                                id="cabangAlamat"
                                value={alamat}
                                onChange={(e) => setAlamat(e.target.value)}
                                rows={2}
                                autoResize
                                placeholder="Alamat lengkap cabang untuk panduan pasien"
                                className="text-sm"
                            />
                        </div>

                        <div className="field col-12 md:col-4 mb-3">
                            <label htmlFor="cabangTelp" className="font-semibold text-xs mb-1 text-800">
                                Telepon / WhatsApp Cabang <span className="text-red-500">*</span>
                            </label>
                            <div className="p-inputgroup">
                                <span className="p-inputgroup-addon bg-white">
                                    <i className="pi pi-phone text-emerald-600" />
                                </span>
                                <InputText
                                    id="cabangTelp"
                                    value={noTelp}
                                    onChange={(e) => setNoTelp(e.target.value)}
                                    placeholder="081234567890"
                                    className="text-sm"
                                />
                            </div>
                        </div>

                        <div className="field col-12 md:col-4 mb-3">
                            <label htmlFor="cabangEmail" className="font-semibold text-xs mb-1 text-800">
                                Email Resmi Cabang
                            </label>
                            <div className="p-inputgroup">
                                <span className="p-inputgroup-addon bg-white">
                                    <i className="pi pi-envelope text-emerald-600" />
                                </span>
                                <InputText
                                    id="cabangEmail"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    placeholder="cabang@klinik.com"
                                    className="text-sm"
                                />
                            </div>
                        </div>

                        <div className="field col-12 md:col-4 mb-3">
                            <label htmlFor="cabangPj" className="font-semibold text-xs mb-1 text-800">
                                Penanggung Jawab / Manager Cabang
                            </label>
                            <div className="p-inputgroup">
                                <span className="p-inputgroup-addon bg-white">
                                    <i className="pi pi-user text-emerald-600" />
                                </span>
                                <InputText
                                    id="cabangPj"
                                    value={pjManager}
                                    onChange={(e) => setPjManager(e.target.value)}
                                    placeholder="Nama Penanggung Jawab"
                                    className="text-sm"
                                />
                            </div>
                        </div>

                        {/* Sub-bagian 2: Jam Operasional */}
                        <div className="col-12 mt-3 mb-2">
                            <span className="text-800 font-bold text-sm flex align-items-center gap-2">
                                <i className="pi pi-clock text-emerald-600" />
                                Jam &amp; Hari Operasional Cabang
                            </span>
                        </div>

                        <div className="field col-12 md:col-3 mb-3">
                            <label htmlFor="jamBuka" className="font-semibold text-xs mb-1 text-800">
                                Jam Buka <span className="text-red-500">*</span>
                            </label>
                            <InputText
                                id="jamBuka"
                                type="time"
                                value={jamBuka}
                                onChange={(e) => setJamBuka(e.target.value)}
                                className="text-sm"
                            />
                        </div>

                        <div className="field col-12 md:col-3 mb-3">
                            <label htmlFor="jamTutup" className="font-semibold text-xs mb-1 text-800">
                                Jam Tutup <span className="text-red-500">*</span>
                            </label>
                            <InputText
                                id="jamTutup"
                                type="time"
                                value={jamTutup}
                                onChange={(e) => setJamTutup(e.target.value)}
                                className="text-sm"
                            />
                        </div>

                        <div className="field col-12 md:col-6 mb-3">
                            <label className="font-semibold text-xs mb-2 block text-800">
                                Hari Operasional (Centang Hari Buka) <span className="text-red-500">*</span>
                            </label>
                            <div className="flex flex-wrap gap-3 align-items-center pt-1">
                                {DAYS_LIST.map((d) => (
                                    <div key={d.num} className="flex align-items-center gap-1">
                                        <Checkbox
                                            inputId={`day-${d.num}`}
                                            value={d.num}
                                            checked={selectedDays.includes(d.num)}
                                            onChange={() => toggleDay(d.num)}
                                        />
                                        <label htmlFor={`day-${d.num}`} className="text-xs font-semibold cursor-pointer text-700">
                                            {d.label}
                                        </label>
                                    </div>
                                ))}
                            </div>
                        </div>

                        {/* Pratinjau Teks Jam Operasional */}
                        <div className="col-12 mb-3">
                            <div className="p-3 border-round-xl bg-emerald-50 border-1 border-emerald-200 flex align-items-center gap-3">
                                <div className="w-2rem h-2rem border-circle bg-emerald-600 text-white flex align-items-center justify-content-center flex-shrink-0">
                                    <i className="pi pi-info text-sm" />
                                </div>
                                <div className="flex-1">
                                    <span className="text-xs text-600 block font-medium">Pratinjau Format Jam di Aplikasi Pasien:</span>
                                    <span className="text-sm font-bold text-emerald-900 font-mono">
                                        {previewJamOperasional}
                                    </span>
                                </div>
                            </div>
                        </div>

                        {/* Sub-bagian 3: Fasilitas Cabang */}
                        <div className="col-12 mt-3 mb-2">
                            <div className="flex align-items-center justify-content-between">
                                <span className="text-800 font-bold text-sm flex align-items-center gap-2">
                                    <i className="pi pi-list text-emerald-600" />
                                    Fasilitas Cabang ({fasilitas.length} fasilitas)
                                </span>
                            </div>
                            <p className="text-xs text-500 m-0 mt-1">
                                Kelola daftar fasilitas khusus cabang ini yang akan tampil sebagai chip pada aplikasi pasien.
                            </p>
                        </div>

                        {/* Toolbar CRUD Fasilitas */}
                        <div className="col-12 mb-2">
                            <div className="flex flex-row flex-wrap align-items-center gap-2 mb-2">
                                <Button
                                    type="button"
                                    size="small"
                                    label="Baru"
                                    icon="pi pi-plus"
                                    outlined
                                    severity="success"
                                    className="border-round-md font-medium px-3"
                                    onClick={handleOpenAddFasilitas}
                                />
                                <span className="text-xs text-500 ml-2">
                                    Gunakan tombol panah di tabel untuk mengatur urutan chip.
                                </span>
                            </div>

                            {/* Mini DataTable Fasilitas */}
                            <DataTable
                                value={fasilitas}
                                className="p-datatable-sm surface-border border-1 border-round-xl overflow-hidden"
                                emptyMessage="Belum ada fasilitas cabang. Klik tombol '+ Baru' di atas untuk menambahkan."
                                responsiveLayout="scroll"
                            >
                                <Column
                                    header="No"
                                    headerStyle={{ width: '4rem', textAlign: 'center' }}
                                    align="center"
                                    body={(_, opt) => <span className="font-semibold text-xs">{opt.rowIndex + 1}</span>}
                                />
                                <Column
                                    header="Ikon"
                                    field="icon"
                                    headerStyle={{ width: '5rem', textAlign: 'center' }}
                                    align="center"
                                    body={(r) => <span style={{ fontSize: '18px' }}>{r.icon || '✨'}</span>}
                                />
                                <Column
                                    header="Nama Fasilitas"
                                    field="nama"
                                    body={(r) => <span className="font-semibold text-sm text-900">{r.nama}</span>}
                                />
                                <Column
                                    header="Urutan"
                                    headerStyle={{ width: '7rem', textAlign: 'center' }}
                                    align="center"
                                    body={(_, opt) => (
                                        <div className="flex align-items-center justify-content-center gap-1">
                                            <Button
                                                type="button"
                                                icon="pi pi-arrow-up"
                                                text
                                                rounded
                                                size="small"
                                                className="p-button-sm text-600"
                                                disabled={opt.rowIndex === 0}
                                                onClick={() => moveFasilitasUp(opt.rowIndex)}
                                                tooltip="Pindah Naik"
                                            />
                                            <Button
                                                type="button"
                                                icon="pi pi-arrow-down"
                                                text
                                                rounded
                                                size="small"
                                                className="p-button-sm text-600"
                                                disabled={opt.rowIndex === fasilitas.length - 1}
                                                onClick={() => moveFasilitasDown(opt.rowIndex)}
                                                tooltip="Pindah Turun"
                                            />
                                        </div>
                                    )}
                                />
                                <Column
                                    header="Aksi"
                                    headerStyle={{ width: '8rem', textAlign: 'center' }}
                                    align="center"
                                    body={(r, opt) => (
                                        <div className="flex align-items-center justify-content-center gap-2">
                                            <Button
                                                type="button"
                                                icon="pi pi-pencil"
                                                outlined
                                                severity="success"
                                                className="p-button-sm border-round-md"
                                                onClick={() => handleOpenEditFasilitas(opt.rowIndex, r)}
                                                tooltip="Edit"
                                            />
                                            <Button
                                                type="button"
                                                icon="pi pi-trash"
                                                outlined
                                                severity="danger"
                                                className="p-button-sm border-round-md"
                                                onClick={() => handleDeleteFasilitas(opt.rowIndex)}
                                                tooltip="Hapus"
                                            />
                                        </div>
                                    )}
                                />
                            </DataTable>
                        </div>

                        {/* Pratinjau Chip Fasilitas */}
                        {fasilitas.length > 0 && (
                            <div className="col-12 mt-2 mb-3">
                                <div className="p-3 border-round-xl surface-50 border-1 surface-border">
                                    <span className="text-xs font-bold text-700 block mb-2">
                                        Pratinjau Chip di Aplikasi Pasien:
                                    </span>
                                    <div className="flex flex-wrap gap-2">
                                        {fasilitas.map((f, i) => (
                                            <div
                                                key={i}
                                                className="px-2 py-1 border-round-md surface-card border-1 surface-border text-xs font-semibold text-800 flex align-items-center gap-1 shadow-1"
                                            >
                                                <span>{f.icon || '✨'}</span>
                                                <span>{f.nama}</span>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        )}

                        {/* Tombol Simpan Section Cabang Tersendiri */}
                        <div className="col-12 mt-4 pt-3 border-top-1 surface-border flex justify-content-end">
                            <Button
                                type="button"
                                label={`Simpan Informasi Cabang (${kodeCabang})`}
                                icon="pi pi-check"
                                severity="success"
                                loading={saving}
                                onClick={handleSaveCabang}
                                className="font-bold border-round-lg px-4 shadow-2"
                            />
                        </div>
                    </div>
                )}
            </div>

            {/* Dialog Tambah / Edit Fasilitas */}
            <Dialog
                header={editFasilitasIndex !== null ? 'Edit Fasilitas Cabang' : 'Tambah Fasilitas Cabang'}
                visible={dialogFasilitasVisible}
                style={{ width: '420px' }}
                modal
                onHide={() => setDialogFasilitasVisible(false)}
            >
                <div className="flex flex-column gap-3 pt-2">
                    <div>
                        <label className="block text-xs font-bold text-700 mb-1">
                            Pilih Ikon Emoji Cepat
                        </label>
                        <div className="flex flex-wrap gap-2 mb-2 p-2 surface-100 border-round-lg">
                            {POPULAR_EMOJIS.map((emoji) => (
                                <button
                                    key={emoji}
                                    type="button"
                                    className={`p-2 border-round-md border-none cursor-pointer text-lg ${fasilitasForm.icon === emoji ? 'bg-emerald-600 text-white shadow-2' : 'bg-white hover:surface-200'}`}
                                    onClick={() => setFasilitasForm({ ...fasilitasForm, icon: emoji })}
                                >
                                    {emoji}
                                </button>
                            ))}
                        </div>
                        <div className="p-inputgroup">
                            <span className="p-inputgroup-addon bg-white">
                                <span style={{ fontSize: '16px' }}>{fasilitasForm.icon || '✨'}</span>
                            </span>
                            <InputText
                                value={fasilitasForm.icon}
                                onChange={(e) => setFasilitasForm({ ...fasilitasForm, icon: e.target.value })}
                                placeholder="Ikon emoji (misal: 🚗 atau 📶)"
                                className="text-sm"
                            />
                        </div>
                    </div>

                    <div>
                        <label className="block text-xs font-bold text-700 mb-1">
                            Nama Fasilitas <span className="text-red-500">*</span>
                        </label>
                        <InputText
                            value={fasilitasForm.nama}
                            onChange={(e) => setFasilitasForm({ ...fasilitasForm, nama: e.target.value })}
                            placeholder="Contoh: Ruang Facial Steril"
                            className="text-sm"
                            autoFocus
                        />
                    </div>
                </div>

                <div className="flex justify-content-end gap-2 mt-4 pt-2 border-top-1 surface-border">
                    <Button
                        type="button"
                        label="Batal"
                        icon="pi pi-times"
                        text
                        onClick={() => setDialogFasilitasVisible(false)}
                    />
                    <Button
                        type="button"
                        label="Simpan"
                        icon="pi pi-check"
                        severity="success"
                        onClick={handleSaveFasilitasModal}
                    />
                </div>
            </Dialog>
        </div>
    );
}
