'use client';

import { useEffect, useRef, useState } from 'react';
import postData from '@/lib/axios/postData';
import { Toast } from 'primereact/toast';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { Dialog } from 'primereact/dialog';
import { Tag } from 'primereact/tag';
import { Dropdown } from 'primereact/dropdown';
import { Divider } from 'primereact/divider';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { showError, showSuccess } from '@/lib/tools/generalTools';

const Page = () => {
    const toast = useRef<Toast>(null);

    const [data, setData] = useState<any[]>([]);
    const [loading, setLoading] = useState<boolean>(false);
    const [totalRecords, setTotalRecords] = useState<number>(0);
    const [page, setPage] = useState<number>(1);
    const [rows, setRows] = useState<number>(10);
    const [keyword, setKeyword] = useState<string>('');
    const [selectedRows, setSelectedRows] = useState<any[]>([]);

    const [dialogVisible, setDialogVisible] = useState<boolean>(false);
    const [isEdit, setIsEdit] = useState<boolean>(false);
    const [formData, setFormData] = useState<any>({
        no_sip: '',
        kode_user: '',
        nama: '',
        jabatan: 'dokter',
        no_hp: '',
        email: '',
        status: 'aktif',
    });
    const [saving, setSaving] = useState<boolean>(false);

    const jabatanOptions = [
        { label: 'Dokter', value: 'dokter' },
        { label: 'Perawat', value: 'perawat' },
        { label: 'Admin', value: 'admin' },
        { label: 'Kasir', value: 'kasir' },
        { label: 'Apoteker', value: 'apoteker' },
        { label: 'Terapis', value: 'terapis' },
    ];

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await postData('/master/karyawan-data', { page, perPage: rows, keyword });
            setData(res.data.data || []);
            setTotalRecords(res.data.total_data || 0);
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal memuat data karyawan');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadData();
    }, [page, rows, keyword]);

    const handleOpenCreate = () => {
        setIsEdit(false);
        setFormData({ no_sip: '', kode_user: '', nama: '', jabatan: 'dokter', no_hp: '', email: '', status: 'aktif' });
        setDialogVisible(true);
    };

    const handleOpenEdit = (rowData: any) => {
        setIsEdit(true);
        setFormData({ ...rowData });
        setDialogVisible(true);
    };

    const handleSave = async () => {
        if (!formData.nama || !formData.no_sip || !formData.jabatan) {
            showError(toast, 'Nama, No SIP, dan Jabatan wajib diisi!');
            return;
        }
        setSaving(true);
        try {
            const endpoint = isEdit ? '/master/karyawan-update' : '/master/karyawan-create';
            const res = await postData(endpoint, formData);
            showSuccess(toast, res.data.message || 'Berhasil disimpan');
            setDialogVisible(false);
            loadData();
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal menyimpan data');
        } finally {
            setSaving(false);
        }
    };

    const handleDelete = (codes: string[]) => {
        confirmDialog({
            message: `Apakah Anda yakin ingin menghapus ${codes.length} data karyawan ini?`,
            header: 'Konfirmasi Hapus',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: async () => {
                try {
                    const res = await postData('/master/karyawan-delete', { no_sip: codes });
                    showSuccess(toast, res.data.message || 'Berhasil dihapus');
                    setSelectedRows([]);
                    loadData();
                } catch (error: any) {
                    showError(toast, error?.response?.data?.message || 'Gagal menghapus data');
                }
            }
        });
    };

    return (
        <div className="p-4">
            <Toast ref={toast} />
            <ConfirmDialog />

            <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
                <div className="mb-4">
                    <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
                        <i className="pi pi-users text-purple-600 text-2xl" />
                        Kelola Karyawan & Dokter
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Tambah, edit, atau nonaktifkan dokter, perawat, terapis, dan staf klinik.
                    </p>
                </div>

                <div className="flex flex-row flex-wrap align-items-center justify-content-between gap-2 mb-4">
                    <div className="flex flex-row flex-wrap align-items-center gap-2">
                        <Button
                            size="small"
                            label="Baru"
                            icon="pi pi-plus"
                            outlined
                            severity="success"
                            className="border-round-md font-medium px-3"
                            onClick={handleOpenCreate}
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
                            onClick={() => handleDelete(selectedRows.map((r) => r.no_sip))}
                        />
                        <Divider layout="vertical" className="m-0 h-2rem" />
                        <Button
                            size="small"
                            label="Refresh"
                            icon="pi pi-refresh"
                            outlined
                            severity="success"
                            className="border-round-md font-medium px-3"
                            loading={loading}
                            onClick={loadData}
                        />
                    </div>

                    <span className="p-input-icon-left w-full md:w-20rem">
                        <i className="pi pi-search" />
                        <InputText value={keyword} onChange={(e) => setKeyword(e.target.value)} placeholder="Cari..." className="w-full text-sm" />
                    </span>
                </div>

                <DataTable
                    value={data}
                    loading={loading}
                    paginator
                    rows={rows}
                    totalRecords={totalRecords}
                    lazy
                    first={(page - 1) * rows}
                    onPage={(e) => { setPage((e.page || 0) + 1); setRows(e.rows); }}
                    selection={selectedRows}
                    onSelectionChange={(e) => setSelectedRows(e.value as any[])}
                    dataKey="no_sip"
                    className="p-datatable-sm"
                    emptyMessage="Data karyawan tidak ditemukan."
                    responsiveLayout="scroll"
                >
                    <Column selectionMode="multiple" headerStyle={{ width: '3rem' }}></Column>
                    <Column field="no_sip" header="No SIP" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama" header="Nama Karyawan" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="jabatan" header="Jabatan" body={(r) => <Tag value={r.jabatan?.toUpperCase()} severity="info" />}></Column>
                    <Column field="no_hp" header="No HP" body={(r) => r.no_hp || '-'}></Column>
                    <Column field="email" header="Email" body={(r) => r.email || '-'}></Column>
                    <Column
                        field="status"
                        header="Status"
                        body={(r) => <Tag value={r.status.toUpperCase()} severity={r.status === 'aktif' ? 'success' : 'danger'} />}
                    ></Column>
                    <Column
                        header="Aksi"
                        body={(r) => (
                            <div className="flex gap-2 justify-content-center">
                                <Button icon="pi pi-pencil" outlined className="p-button-sm border-round-md" onClick={() => handleOpenEdit(r)} tooltip="Edit" />
                                <Button icon="pi pi-trash" outlined severity="danger" className="p-button-sm border-round-md" onClick={() => handleDelete([r.no_sip])} tooltip="Hapus" />
                            </div>
                        )}
                    ></Column>
                </DataTable>
            </div>

            <Dialog header={isEdit ? 'Edit Data Karyawan' : 'Tambah Data Karyawan'} visible={dialogVisible} style={{ width: '500px' }} modal onHide={() => setDialogVisible(false)}>
                <div className="flex flex-column gap-3 pt-2">
                    <div>
                        <label className="block text-sm font-semibold mb-1">No SIP *</label>
                        <InputText value={formData.no_sip} onChange={(e) => setFormData({ ...formData, no_sip: e.target.value })} disabled={isEdit} placeholder="masukkan No SIP" className="w-full text-sm" />
                    </div>
                    <div>
                        <label className="block text-sm font-semibold mb-1">Nama Lengkap *</label>
                        <InputText value={formData.nama} onChange={(e) => setFormData({ ...formData, nama: e.target.value })} placeholder="Masukkan nama lengkap" className="w-full text-sm" />
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Jabatan *</label>
                            <Dropdown
                                value={formData.jabatan}
                                options={jabatanOptions}
                                onChange={(e) => setFormData({ ...formData, jabatan: e.value })}
                                placeholder="Pilih Jabatan"
                                className="w-full text-sm"
                            />
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Status *</label>
                            <Dropdown
                                value={formData.status}
                                options={[{ label: 'Aktif', value: 'aktif' }, { label: 'Nonaktif', value: 'nonaktif' }]}
                                onChange={(e) => setFormData({ ...formData, status: e.value })}
                                className="w-full text-sm"
                            />
                        </div>
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">No HP</label>
                            <InputText value={formData.no_hp || ''} onChange={(e) => setFormData({ ...formData, no_hp: e.target.value })} placeholder="misal: 08123456789" className="w-full text-sm" />
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Email</label>
                            <InputText value={formData.email || ''} onChange={(e) => setFormData({ ...formData, email: e.target.value })} placeholder="email@karyawan.com" className="w-full text-sm" />
                        </div>
                    </div>
                </div>
                <div className="flex justify-content-end gap-2 mt-4">
                    <Button label="Batal" icon="pi pi-times" text onClick={() => setDialogVisible(false)} />
                    <Button label="Simpan" icon="pi pi-check" loading={saving} onClick={handleSave} className="bg-primary border-none" />
                </div>
            </Dialog>
        </div>
    );
};

export default Page;
