'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Toast } from 'primereact/toast';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Tag } from 'primereact/tag';
import { Button } from 'primereact/button';
import { Dialog } from 'primereact/dialog';
import { InputText } from 'primereact/inputtext';
import { InputTextarea } from 'primereact/inputtextarea';
import { InputNumber } from 'primereact/inputnumber';
import { Dropdown } from 'primereact/dropdown';
import { Divider } from 'primereact/divider';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { ConfirmDialog, confirmDialog } from 'primereact/confirmdialog';
import postData from '@/lib/axios/postData';
import formUpload from '@/lib/axios/formData';
import { showError, showSuccess } from '@/lib/tools/generalTools';
import { useSession } from 'next-auth/react';
import KeteranganStatus from '@/app/components/KeteranganStatus';

interface MetodePembayaranRecord {
    id?: number;
    kode_metode: string;
    tipe: 'rekening' | 'qris';
    nama_bank?: string | null;
    no_rekening?: string | null;
    atas_nama?: string | null;
    gambar_qris?: string | null;
    gambar_qris_url?: string | null;
    urutan: number;
    status: 'aktif' | 'nonaktif';
    kode_cabang?: string | null;
    nama_cabang?: string | null;
    created_at?: string;
    updated_at?: string;
}

export default function MetodePembayaranPage() {
    const toast = useRef<Toast>(null);
    const { data: session } = useSession();

    const [dataList, setDataList] = useState<any[]>([]);
    const [cabangOptions, setCabangOptions] = useState<{ label: string; value: string | null }[]>([]);
    const [loading, setLoading] = useState<boolean>(true);
    const [keyword, setKeyword] = useState<string>('');
    const [filterStatus, setFilterStatus] = useState<string | null>(null);
    const [filterTipe, setFilterTipe] = useState<string | null>(null);
    const [selectedRows, setSelectedRows] = useState<any[]>([]);

    // Modal Create / Edit
    const [showModal, setShowModal] = useState<boolean>(false);
    const [isEdit, setIsEdit] = useState<boolean>(false);
    const [formData, setFormData] = useState<{
        kode_metode?: string;
        tipe: 'rekening' | 'qris';
        nama_bank: string;
        no_rekening: string;
        atas_nama: string;
        urutan: number;
        status: 'aktif' | 'nonaktif';
        kode_cabang: string | null;
        gambar_qris_file?: File | null;
        preview_qris?: string | null;
        existing_qris?: string | null;
    }>({
        tipe: 'rekening',
        nama_bank: '',
        no_rekening: '',
        atas_nama: '',
        urutan: 0,
        status: 'aktif',
        kode_cabang: null,
        gambar_qris_file: null,
        preview_qris: null,
        existing_qris: null,
    });
    const [formLoading, setFormLoading] = useState<boolean>(false);

    // Modal Preview QRIS
    const [previewDialogVisible, setPreviewDialogVisible] = useState<boolean>(false);
    const [previewImageSrc, setPreviewImageSrc] = useState<string>('');
    const [previewImageTitle, setPreviewImageTitle] = useState<string>('');

    const fileInputRef = useRef<HTMLInputElement>(null);

    const isSuperAdmin = (session?.user?.role || '').toLowerCase() === 'superadmin';

    // Fetch data cabang untuk dropdown
    const fetchCabangOptions = async () => {
        try {
            const res = await postData('/master/cabang-data', {});
            if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
                const list = res?.data?.data || [];
                const options = [
                    { label: 'Semua Cabang (Berlaku Global)', value: null },
                    ...list.map((c: any) => ({
                        label: `${c.kode_cabang} - ${c.nama_cabang}`,
                        value: c.kode_cabang,
                    })),
                ];
                setCabangOptions(options);
            }
        } catch {
            // fallback minimal
            setCabangOptions([{ label: 'Semua Cabang (Berlaku Global)', value: null }]);
        }
    };

    // Fetch master data metode pembayaran
    const fetchMetodePembayaran = async () => {
        setLoading(true);
        try {
            const payload: any = {};
            if (keyword.trim()) payload.search = keyword.trim();
            if (filterStatus) payload.status = filterStatus;
            if (filterTipe) payload.tipe = filterTipe;

            const res = await postData('/master/metode-pembayaran-data', payload);
            if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
                setDataList(res.data.data || []);
            } else {
                showError(toast, res?.data?.message || 'Gagal memuat data metode pembayaran');
            }
        } catch (err: any) {
            showError(toast, err?.message || 'Gagal terhubung ke server');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchCabangOptions();
    }, []);

    useEffect(() => {
        fetchMetodePembayaran();
    }, [filterStatus, filterTipe]);

    const openCreateModal = () => {
        setIsEdit(false);
        setFormData({
            tipe: 'rekening',
            nama_bank: '',
            no_rekening: '',
            atas_nama: '',
            urutan: (dataList.length + 1),
            status: 'aktif',
            kode_cabang: null,
            gambar_qris_file: null,
            preview_qris: null,
            existing_qris: null,
        });
        if (fileInputRef.current) fileInputRef.current.value = '';
        setShowModal(true);
    };

    const openEditModal = (item: MetodePembayaranRecord) => {
        setIsEdit(true);
        setFormData({
            kode_metode: item.kode_metode,
            tipe: item.tipe,
            nama_bank: item.nama_bank || '',
            no_rekening: item.no_rekening || '',
            atas_nama: item.atas_nama || '',
            urutan: item.urutan || 0,
            status: item.status,
            kode_cabang: item.kode_cabang || null,
            gambar_qris_file: null,
            preview_qris: null,
            existing_qris: item.gambar_qris_url || null,
        });
        if (fileInputRef.current) fileInputRef.current.value = '';
        setShowModal(true);
    };

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        // Validasi ekstensi
        const allowedExtensions = ['image/jpeg', 'image/png', 'image/webp'];
        if (!allowedExtensions.includes(file.type)) {
            showError(toast, 'Format file harus JPG, JPEG, PNG, atau WEBP!');
            if (fileInputRef.current) fileInputRef.current.value = '';
            return;
        }

        // Validasi ukuran maksimal 2MB
        if (file.size > 2 * 1024 * 1024) {
            showError(toast, 'Ukuran gambar maksimal 2 MB!');
            if (fileInputRef.current) fileInputRef.current.value = '';
            return;
        }

        const reader = new FileReader();
        reader.onloadend = () => {
            setFormData((prev) => ({
                ...prev,
                gambar_qris_file: file,
                preview_qris: reader.result as string,
            }));
        };
        reader.readAsDataURL(file);
    };

    const handleSave = async () => {
        // Validasi Tipe Rekening
        if (formData.tipe === 'rekening') {
            if (!formData.nama_bank.trim()) {
                showError(toast, 'Nama Bank wajib diisi!');
                return;
            }
            if (!formData.no_rekening.trim()) {
                showError(toast, 'Nomor Rekening wajib diisi!');
                return;
            }
            if (!/^\d+$/.test(formData.no_rekening.trim())) {
                showError(toast, 'Nomor Rekening hanya boleh berupa angka!');
                return;
            }
            if (!formData.atas_nama.trim()) {
                showError(toast, 'Atas Nama pemilik rekening wajib diisi!');
                return;
            }
        }

        // Validasi Tipe QRIS
        if (formData.tipe === 'qris') {
            if (!isEdit && !formData.gambar_qris_file) {
                showError(toast, 'File gambar QRIS wajib diunggah!');
                return;
            }
            if (isEdit && !formData.gambar_qris_file && !formData.existing_qris) {
                showError(toast, 'File gambar QRIS wajib diunggah!');
                return;
            }
        }

        setFormLoading(true);
        try {
            const endpoint = isEdit ? '/master/metode-pembayaran-update' : '/master/metode-pembayaran-create';
            const fd = new FormData();

            if (isEdit && formData.kode_metode) {
                fd.append('kode_metode', formData.kode_metode);
            }

            fd.append('tipe', formData.tipe);
            fd.append('status', formData.status);
            fd.append('urutan', String(formData.urutan || 0));
            const cleanKodeCabang = typeof formData.kode_cabang === 'string'
                ? formData.kode_cabang.trim()
                : (formData.kode_cabang as any)?.value || '';
            fd.append('kode_cabang', cleanKodeCabang === '[object Object]' ? '' : cleanKodeCabang);

            if (formData.tipe === 'rekening') {
                fd.append('nama_bank', formData.nama_bank.trim());
                fd.append('no_rekening', formData.no_rekening.trim());
                fd.append('atas_nama', formData.atas_nama.trim());
            } else if (formData.tipe === 'qris') {
                if (formData.gambar_qris_file) {
                    fd.append('gambar_qris', formData.gambar_qris_file);
                }
            }

            const res = await formUpload(endpoint, fd, { 'X-Level': '1' });

            if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
                showSuccess(toast, res?.data?.message || (isEdit ? 'Metode pembayaran berhasil diperbarui' : 'Metode pembayaran baru berhasil ditambahkan'));
                setShowModal(false);
                fetchMetodePembayaran();
            } else {
                showError(toast, res?.data?.message || 'Gagal menyimpan data metode pembayaran');
            }
        } catch (err: any) {
            showError(toast, err?.response?.data?.message || err?.message || 'Terjadi kesalahan sistem saat menyimpan');
        } finally {
            setFormLoading(false);
        }
    };

    const handleDelete = (item: MetodePembayaranRecord) => {
        const itemLabel = item.tipe === 'rekening'
            ? `${item.nama_bank} - ${item.no_rekening} (${item.atas_nama})`
            : `QRIS Klinik (${item.kode_metode})`;

        confirmDialog({
            message: `Apakah Anda yakin ingin menghapus metode pembayaran "${itemLabel}"?`,
            header: 'Konfirmasi Hapus Metode Pembayaran',
            icon: 'pi pi-exclamation-triangle',
            acceptClassName: 'p-button-danger',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            accept: async () => {
                try {
                    const res = await postData('/master/metode-pembayaran-delete', { kode_metode: item.kode_metode });
                    if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
                        showSuccess(toast, res?.data?.message || 'Metode pembayaran berhasil dihapus');
                        fetchMetodePembayaran();
                    } else {
                        showError(toast, res?.data?.message || 'Gagal menghapus metode pembayaran');
                    }
                } catch (err: any) {
                    showError(toast, err?.response?.data?.message || 'Gagal memproses penghapusan');
                }
            },
        });
    };

    const handleDeleteMultiple = (rows: MetodePembayaranRecord[]) => {
        if (rows.length === 0) return;

        confirmDialog({
            message: `Apakah Anda yakin ingin menghapus ${rows.length} metode pembayaran terpilih?`,
            header: 'Konfirmasi Hapus Metode Pembayaran',
            icon: 'pi pi-exclamation-triangle',
            acceptClassName: 'p-button-danger',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            accept: async () => {
                try {
                    const codes = rows.map((r) => r.kode_metode);
                    const res = await postData('/master/metode-pembayaran-delete', { kode_metode: codes });
                    if (['00', '0000', 200].includes(res?.data?.status) || res?.status === 200) {
                        showSuccess(toast, res?.data?.message || `${rows.length} data berhasil dihapus`);
                        setSelectedRows([]);
                        fetchMetodePembayaran();
                    } else {
                        showError(toast, res?.data?.message || 'Gagal menghapus data');
                    }
                } catch (err: any) {
                    showError(toast, err?.response?.data?.message || 'Gagal memproses penghapusan');
                }
            },
        });
    };

    const openQrisPreview = (src: string, title: string) => {
        setPreviewImageSrc(src);
        setPreviewImageTitle(title);
        setPreviewDialogVisible(true);
    };

    return (
        <div className="w-full">
            <Toast ref={toast} />
            <ConfirmDialog />

            <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
                {/* Page Header */}
                <div className="mb-4">
                    <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
                        <i className="pi pi-wallet text-purple-600 text-2xl" />
                        Kelola Data Metode Pembayaran
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Tambah, edit, atau nonaktifkan rekening bank dan QRIS klinik yang akan ditampilkan di aplikasi mobile.
                    </p>
                </div>

                {/* Action Buttons Toolbar */}
                <div className="flex flex-row flex-wrap align-items-center gap-2 mb-4">
                    {isSuperAdmin && (
                        <>
                            <Button
                                size="small"
                                label="Baru"
                                icon="pi pi-plus"
                                outlined
                                severity="success"
                                className="border-round-md font-medium px-3"
                                onClick={openCreateModal}
                            />
                            <Divider layout="vertical" className="m-0 h-2rem" />
                            <Button
                                size="small"
                                label="Cetak"
                                icon="pi pi-print"
                                outlined
                                className="border-round-md font-medium px-3 border-purple-600 text-purple-600"
                                onClick={() => window.print()}
                            />
                            <Divider layout="vertical" className="m-0 h-2rem" />
                            <Button
                                size="small"
                                label={`Hapus${selectedRows.length > 0 ? ` (${selectedRows.length})` : ''}`}
                                icon="pi pi-trash"
                                severity="danger"
                                outlined
                                disabled={selectedRows.length === 0}
                                className="border-round-md font-medium px-3"
                                onClick={() => {
                                    if (selectedRows.length < 1) return;
                                    handleDeleteMultiple(selectedRows);
                                }}
                            />
                            <Divider layout="vertical" className="m-0 h-2rem" />
                        </>
                    )}
                    <Button
                        size="small"
                        label="Refresh"
                        icon="pi pi-refresh"
                        outlined
                        severity="success"
                        className="border-round-md font-medium px-3"
                        loading={loading}
                        onClick={fetchMetodePembayaran}
                    />
                </div>

                {/* Keterangan Status */}
                <KeteranganStatus className="mb-3" />

                {/* DataTable Metode Pembayaran */}
                <DataTable
                    value={dataList}
                    loading={loading}
                    paginator
                    rows={10}
                    rowsPerPageOptions={[10, 25, 50]}
                    selection={selectedRows}
                    onSelectionChange={(e: any) => setSelectedRows(e.value as any[])}
                    dataKey="kode_metode"
                    className="p-datatable-sm"
                    emptyMessage="Data metode pembayaran tidak ditemukan."
                    responsiveLayout="scroll"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    currentPageReportTemplate="Menampilkan {first} - {last} dari {totalRecords} data"
                    header={
                        <div className="flex flex-column gap-3">
                            <div className="flex flex-wrap align-items-center justify-content-between gap-2">
                                <span className="text-xl font-bold">Data Metode Pembayaran</span>
                                <div className="flex flex-wrap align-items-center gap-2 ml-auto w-full md:w-auto">
                                    <Dropdown
                                        value={filterStatus}
                                        options={[
                                            { label: 'Semua Status', value: null },
                                            { label: 'Aktif', value: 'aktif' },
                                            { label: 'Tidak Aktif', value: 'nonaktif' },
                                        ]}
                                        onChange={(e) => setFilterStatus(e.value)}
                                        placeholder="Filter Status"
                                        className="p-inputtext-sm w-full sm:w-11rem"
                                    />
                                    <Dropdown
                                        value={filterTipe}
                                        options={[
                                            { label: 'Semua Tipe', value: null },
                                            { label: 'Rekening Bank', value: 'rekening' },
                                            { label: 'QRIS', value: 'qris' },
                                        ]}
                                        onChange={(e) => setFilterTipe(e.value)}
                                        placeholder="Filter Tipe"
                                        className="p-inputtext-sm w-full sm:w-11rem"
                                    />
                                    <IconField iconPosition="left" className="w-full sm:w-18rem">
                                        <InputIcon className="pi pi-search" />
                                        <InputText
                                            value={keyword}
                                            onChange={(e) => setKeyword(e.target.value)}
                                            onKeyDown={(e) => e.key === 'Enter' && fetchMetodePembayaran()}
                                            placeholder="Cari bank / atas nama / no. rekening..."
                                            className="w-full text-sm"
                                        />
                                    </IconField>
                                    <Button
                                        type="button"
                                        icon="pi pi-filter-slash"
                                        outlined
                                        severity="danger"
                                        tooltip="Reset Filter"
                                        onClick={() => {
                                            setKeyword('');
                                            setFilterStatus(null);
                                            setFilterTipe(null);
                                            fetchMetodePembayaran();
                                        }}
                                    />
                                </div>
                            </div>
                        </div>
                    }
                >
                    <Column selectionMode="multiple" headerStyle={{ width: '3rem' }} />
                    <Column
                        header=""
                        headerStyle={{ width: '3rem' }}
                        align="center"
                        body={(r: MetodePembayaranRecord) => {
                            const isActive = r.status === 'aktif';
                            return (
                                <span
                                    style={{
                                        display: 'inline-block',
                                        width: '12px',
                                        height: '12px',
                                        borderRadius: '3px',
                                        backgroundColor: isActive ? '#22c55e' : '#ef4444',
                                        boxShadow: `0 1px 3px ${isActive ? '#22c55e55' : '#ef444455'}`,
                                    }}
                                    title={isActive ? 'Status: Aktif' : 'Status: Tidak Aktif'}
                                />
                            );
                        }}
                    />
                    <Column
                        field="kode_metode"
                        header="Kode"
                        sortable
                        className="font-bold text-blue-700"
                        headerStyle={{ minWidth: '7rem' }}
                    />
                    <Column
                        field="tipe"
                        header="Tipe"
                        sortable
                        headerStyle={{ minWidth: '8rem' }}
                        body={(r: MetodePembayaranRecord) => (
                            r.tipe === 'rekening' ? (
                                <Tag value="Rekening" severity="info" icon="pi pi-credit-card" className="text-xs" />
                            ) : (
                                <Tag value="QRIS" severity="warning" icon="pi pi-qrcode" className="text-xs bg-amber-500 text-white" />
                            )
                        )}
                    />
                    <Column
                        field="nama_bank"
                        header="Bank"
                        sortable
                        className="font-semibold text-900"
                        headerStyle={{ minWidth: '11rem' }}
                        body={(r: MetodePembayaranRecord) => r.nama_bank || '-'}
                    />
                    <Column
                        field="no_rekening"
                        header="No. Rekening"
                        headerStyle={{ minWidth: '11rem' }}
                        body={(r: MetodePembayaranRecord) => (
                            r.no_rekening ? (
                                <span className="font-mono font-semibold text-slate-800">{r.no_rekening}</span>
                            ) : '-'
                        )}
                    />
                    <Column
                        field="atas_nama"
                        header="Atas Nama"
                        sortable
                        headerStyle={{ minWidth: '12rem' }}
                        body={(r: MetodePembayaranRecord) => r.atas_nama || '-'}
                    />
                    <Column
                        header="QRIS"
                        headerStyle={{ minWidth: '6rem', textAlign: 'center' }}
                        align="center"
                        body={(r: MetodePembayaranRecord) => {
                            if (r.tipe !== 'qris' || !r.gambar_qris_url) {
                                return <span className="text-400 italic text-xs">-</span>;
                            }
                            return (
                                <div
                                    onClick={() => openQrisPreview(r.gambar_qris_url || '', `QRIS ${r.kode_metode}`)}
                                    className="cursor-pointer border-round shadow-1 hover:shadow-3 transition-all inline-flex align-items-center justify-content-center p-1 bg-white border-1 border-slate-200"
                                    style={{ width: '42px', height: '42px' }}
                                    title="Klik untuk memperbesar QRIS"
                                >
                                    <img
                                        src={r.gambar_qris_url}
                                        alt={`QRIS ${r.kode_metode}`}
                                        style={{ width: '100%', height: '100%', objectFit: 'contain' }}
                                        onError={(e: any) => {
                                            e.currentTarget.style.display = 'none';
                                            if (e.currentTarget.parentElement) {
                                                e.currentTarget.parentElement.innerHTML = '<i class="pi pi-qrcode text-amber-500 text-lg"></i>';
                                            }
                                        }}
                                    />
                                </div>
                            );
                        }}
                    />
                    <Column
                        field="kode_cabang"
                        header="Cabang"
                        sortable
                        headerStyle={{ minWidth: '11rem' }}
                        body={(r: MetodePembayaranRecord) => (
                            r.kode_cabang ? (
                                <span className="font-semibold text-slate-800">{r.nama_cabang || r.kode_cabang}</span>
                            ) : (
                                <Tag value="Semua Cabang" severity="secondary" className="text-xs bg-slate-100 text-slate-600 border-1 border-slate-300" />
                            )
                        )}
                    />

                    {isSuperAdmin && (
                        <Column
                            header="Aksi"
                            align="center"
                            headerStyle={{ width: '8rem', textAlign: 'center' }}
                            body={(r: MetodePembayaranRecord) => (
                                <div className="flex align-items-center justify-content-center gap-2">
                                    <Button
                                        icon="pi pi-pencil"
                                        outlined
                                        severity="success"
                                        size="small"
                                        className="border-round-md"
                                        tooltip="Edit Metode Pembayaran"
                                        onClick={() => openEditModal(r)}
                                    />
                                    <Button
                                        icon="pi pi-trash"
                                        outlined
                                        severity="danger"
                                        size="small"
                                        className="border-round-md"
                                        tooltip="Hapus Metode Pembayaran"
                                        onClick={() => handleDelete(r)}
                                    />
                                </div>
                            )}
                        />
                    )}
                </DataTable>
            </div>

            {/* Modal Dialog Tambah / Edit */}
            <Dialog
                header={isEdit ? 'Edit Metode Pembayaran' : 'Tambah Metode Pembayaran Baru'}
                visible={showModal}
                style={{ width: '560px', maxWidth: '95vw' }}
                modal
                onHide={() => setShowModal(false)}
                footer={
                    <div className="flex justify-content-end gap-2 pt-3 border-top-1 surface-border">
                        <Button
                            label="Batal"
                            icon="pi pi-times"
                            outlined
                            severity="secondary"
                            onClick={() => setShowModal(false)}
                        />
                        <Button
                            label={isEdit ? 'Simpan Perubahan' : 'Simpan Metode'}
                            icon="pi pi-check"
                            severity="success"
                            onClick={handleSave}
                            loading={formLoading}
                        />
                    </div>
                }
            >
                <div className="flex flex-column gap-3 pt-2">
                    {/* Kode Metode (Hanya tampil saat Edit) */}
                    {isEdit && (
                        <div>
                            <label className="text-xs font-bold text-gray-700 block mb-1">Kode Metode</label>
                            <InputText
                                value={formData.kode_metode || ''}
                                disabled
                                className="w-full p-inputtext-sm bg-gray-100 font-bold text-blue-700"
                            />
                        </div>
                    )}

                    {/* Pilih Tipe */}
                    <div>
                        <label className="text-xs font-bold text-gray-700 block mb-1">
                            Tipe Metode Pembayaran <span className="text-red-500">*</span>
                        </label>
                        <Dropdown
                            value={formData.tipe}
                            options={[
                                { label: '💳 Rekening Bank (Transfer)', value: 'rekening' },
                                { label: '📱 QRIS Klinik (Scan QR)', value: 'qris' },
                            ]}
                            optionValue="value"
                            onChange={(e) => setFormData((prev) => ({ ...prev, tipe: e.value }))}
                            placeholder="Pilih Tipe Metode"
                            className="w-full p-inputtext-sm"
                        />
                    </div>

                    {/* Form Dinamis: Tipe = Rekening */}
                    {formData.tipe === 'rekening' && (
                        <div className="p-3 border-round-lg bg-blue-50 border-1 border-blue-200 flex flex-column gap-3">
                            <div className="text-xs font-bold text-blue-800 uppercase tracking-wider flex align-items-center gap-1">
                                <i className="pi pi-credit-card" /> Informasi Rekening Bank
                            </div>

                            <div>
                                <label className="text-xs font-bold text-gray-700 block mb-1">
                                    Nama Bank <span className="text-red-500">*</span>
                                </label>
                                <InputText
                                    value={formData.nama_bank}
                                    onChange={(e) => setFormData((prev) => ({ ...prev, nama_bank: e.target.value }))}
                                    placeholder="Contoh: Bank Central Asia (BCA)"
                                    className="w-full p-inputtext-sm"
                                />
                            </div>

                            <div>
                                <label className="text-xs font-bold text-gray-700 block mb-1">
                                    Nomor Rekening <span className="text-red-500">*</span>
                                </label>
                                <InputText
                                    value={formData.no_rekening}
                                    onChange={(e) => {
                                        // Filter hanya angka
                                        const cleanVal = e.target.value.replace(/\D/g, '');
                                        setFormData((prev) => ({ ...prev, no_rekening: cleanVal }));
                                    }}
                                    placeholder="Contoh: 8830123456 (Hanya angka)"
                                    className="w-full p-inputtext-sm font-mono"
                                />
                            </div>

                            <div>
                                <label className="text-xs font-bold text-gray-700 block mb-1">
                                    Atas Nama Pemilik Rekening <span className="text-red-500">*</span>
                                </label>
                                <InputText
                                    value={formData.atas_nama}
                                    onChange={(e) => setFormData((prev) => ({ ...prev, atas_nama: e.target.value }))}
                                    placeholder="Contoh: PT Klinik Kecantikan Indonesia"
                                    className="w-full p-inputtext-sm"
                                />
                            </div>
                        </div>
                    )}

                    {/* Form Dinamis: Tipe = QRIS */}
                    {formData.tipe === 'qris' && (
                        <div className="p-3 border-round-lg bg-amber-50 border-1 border-amber-200 flex flex-column gap-3">
                            <div className="text-xs font-bold text-amber-800 uppercase tracking-wider flex align-items-center gap-1">
                                <i className="pi pi-qrcode" /> Unggah Gambar QRIS Klinik
                            </div>

                            <div>
                                <label className="text-xs font-bold text-gray-700 block mb-1">
                                    File Gambar QRIS <span className="text-red-500">*</span>
                                </label>
                                <input
                                    ref={fileInputRef}
                                    type="file"
                                    accept="image/png, image/jpeg, image/jpg, image/webp"
                                    onChange={handleFileChange}
                                    className="w-full text-xs text-slate-500 file:mr-3 file:py-2 file:px-3 file:rounded-md file:border-0 file:text-xs file:font-semibold file:bg-amber-100 file:text-amber-800 hover:file:bg-amber-200 cursor-pointer"
                                />
                                <div className="text-[11px] text-slate-500 mt-1">
                                    Format: JPG, JPEG, PNG, WEBP. Maksimal 2 MB.
                                </div>
                            </div>

                            {/* Preview QRIS */}
                            {(formData.preview_qris || formData.existing_qris) && (
                                <div className="flex flex-column align-items-center justify-content-center p-2 bg-white border-round border-1 border-slate-200">
                                    <div className="text-xs text-slate-500 font-semibold mb-1">
                                        {formData.preview_qris ? 'Pratinjau File Baru:' : 'QRIS Saat Ini:'}
                                    </div>
                                    <img
                                        src={formData.preview_qris || formData.existing_qris || ''}
                                        alt="Pratinjau QRIS"
                                        style={{ maxWidth: '180px', maxHeight: '180px', objectFit: 'contain' }}
                                        className="border-round shadow-1"
                                    />
                                </div>
                            )}
                        </div>
                    )}

                    {/* Field Umum: Cabang & Urutan */}
                    <div className="grid">
                        <div className="col-12 md:col-6">
                            <label className="text-xs font-bold text-gray-700 block mb-1">Berlaku untuk Cabang</label>
                            <Dropdown
                                value={formData.kode_cabang}
                                options={cabangOptions}
                                optionValue="value"
                                onChange={(e) => setFormData((prev) => ({ ...prev, kode_cabang: e.value }))}
                                placeholder="Pilih Cabang"
                                className="w-full p-inputtext-sm"
                            />
                        </div>
                        <div className="col-12 md:col-6">
                            <label className="text-xs font-bold text-gray-700 block mb-1">Urutan Tampilan</label>
                            <InputNumber
                                value={formData.urutan}
                                onValueChange={(e) => setFormData((prev) => ({ ...prev, urutan: e.value ?? 0 }))}
                                min={0}
                                max={999}
                                className="w-full p-inputtext-sm"
                                placeholder="0"
                            />
                        </div>
                    </div>

                    {/* Status */}
                    <div>
                        <label className="text-xs font-bold text-gray-700 block mb-1">
                            Status <span className="text-red-500">*</span>
                        </label>
                        <Dropdown
                            value={formData.status}
                            options={[
                                { label: 'Aktif', value: 'aktif' },
                                { label: 'Tidak Aktif', value: 'nonaktif' },
                            ]}
                            optionValue="value"
                            onChange={(e) => setFormData((prev) => ({ ...prev, status: e.value }))}
                            className="w-full p-inputtext-sm"
                        />
                    </div>
                </div>
            </Dialog>

            {/* Dialog Perbesar Gambar QRIS */}
            <Dialog
                header={previewImageTitle || 'QRIS Pembayaran Klinik'}
                visible={previewDialogVisible}
                style={{ width: '400px', maxWidth: '95vw' }}
                modal
                onHide={() => setPreviewDialogVisible(false)}
                footer={
                    <div className="flex justify-content-end gap-2 pt-2">
                        <Button
                            label="Tutup"
                            icon="pi pi-times"
                            outlined
                            severity="secondary"
                            onClick={() => setPreviewDialogVisible(false)}
                        />
                        <a
                            href={previewImageSrc}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="p-button p-component p-button-success no-underline inline-flex align-items-center gap-1"
                        >
                            <i className="pi pi-external-link" /> Buka Asli
                        </a>
                    </div>
                }
            >
                <div className="flex flex-column align-items-center justify-content-center p-3 text-center">
                    <img
                        src={previewImageSrc}
                        alt="QRIS Detail"
                        style={{ maxWidth: '100%', maxHeight: '350px', objectFit: 'contain' }}
                        className="border-round shadow-2"
                    />
                    <div className="text-xs text-slate-500 mt-3">
                        Gunakan aplikasi perbankan atau e-wallet (BCA, Mandiri, GoPay, OVO, Dana) untuk scan kode QR di atas.
                    </div>
                </div>
            </Dialog>
        </div>
    );
}
