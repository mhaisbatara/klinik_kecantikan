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
import { InputSwitch } from 'primereact/inputswitch';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
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
    const [submitted, setSubmitted] = useState<boolean>(false);
    const [formData, setFormData] = useState<any>({
        kode_ruangan: '',
        nama_ruangan: '',
        status: 'aktif',
    });
    const [saving, setSaving] = useState<boolean>(false);

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await postData('/master/ruangan-data', { page, perPage: rows, keyword });
            setData(res.data.data || []);
            setTotalRecords(res.data.total_data || 0);
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal memuat data ruangan');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadData();
    }, [page, rows, keyword]);

    const handleOpenCreate = () => {
        setIsEdit(false);
        setSubmitted(false);
        setFormData({ kode_ruangan: '', nama_ruangan: '', status: 'aktif' });
        setDialogVisible(true);
    };

    const handleOpenEdit = (rowData: any) => {
        setIsEdit(true);
        setSubmitted(false);
        setFormData({ ...rowData });
        setDialogVisible(true);
    };

    const handleSave = async () => {
        setSubmitted(true);
        if (!formData.nama_ruangan || !formData.nama_ruangan.trim()) {
            showError(toast, 'Nama Ruangan wajib diisi!');
            return;
        }
        setSaving(true);
        try {
            const endpoint = isEdit ? '/master/ruangan-update' : '/master/ruangan-create';
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
            message: `Apakah Anda yakin ingin menghapus ${codes.length} data ruangan ini?`,
            header: 'Konfirmasi Hapus',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: async () => {
                try {
                    const res = await postData('/master/ruangan-delete', { kode_ruangan: codes });
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
                {/* Page Header */}
                <div className="mb-4 pb-3 border-bottom-1 surface-border">
                    <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
                        <i className="pi pi-building text-purple-600 text-2xl" />
                        Kelola Master Data Ruangan
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Tambah, edit, atau nonaktifkan ruangan tindakan, perawatan, dan konsultasi klinik.
                    </p>
                </div>

                <div className="flex flex-row flex-wrap align-items-center justify-content-between gap-3 mb-3">
                    <div className="flex flex-row flex-wrap align-items-center gap-2">
                        <Button
                            size="small"
                            label="Baru"
                            icon="pi pi-plus"
                            outlined
                            severity="success"
                            className="border-round-md font-semibold px-3"
                            onClick={handleOpenCreate}
                        />
                        <Divider layout="vertical" className="m-0 h-2rem" />
                        <Button
                            size="small"
                            label="Cetak"
                            icon="pi pi-print"
                            outlined
                            className="border-round-md font-semibold px-3 border-purple-600 text-purple-600"
                            onClick={() => window.print()}
                        />
                        <Divider layout="vertical" className="m-0 h-2rem" />
                        <Button
                            size="small"
                            label="Refresh"
                            icon="pi pi-refresh"
                            outlined
                            className="border-round-md font-semibold px-3 border-purple-600 text-purple-600"
                            loading={loading}
                            onClick={loadData}
                        />
                        {selectedRows.length > 0 && (
                            <>
                                <Divider layout="vertical" className="m-0 h-2rem" />
                                <Button
                                    size="small"
                                    label={`Hapus (${selectedRows.length})`}
                                    icon="pi pi-trash"
                                    severity="danger"
                                    outlined
                                    className="border-round-md font-semibold px-3"
                                    onClick={() => handleDelete(selectedRows.map((r) => r.kode_ruangan))}
                                />
                            </>
                        )}
                    </div>

                    
                </div>

                {/* Box Keterangan Status Legend */}
                <div className="surface-100 p-2 px-3 border-round-md flex align-items-center gap-4 text-xs font-semibold text-700 mb-4 border-1 surface-border">
                    <span className="flex align-items-center gap-1">
                        <i className="pi pi-info-circle text-primary text-sm"></i>
                        KETERANGAN STATUS:
                    </span>
                    <span className="flex align-items-center gap-2">
                        <span className="w-1rem h-1rem border-round bg-green-500 inline-flex align-items-center justify-content-center text-white text-xs">
                            <i className="pi pi-check" style={{ fontSize: '0.6rem' }}></i>
                        </span>
                        Aktif
                    </span>
                    <span className="flex align-items-center gap-2">
                        <span className="w-1rem h-1rem border-round bg-red-500 inline-flex align-items-center justify-content-center text-white text-xs">
                            <i className="pi pi-times" style={{ fontSize: '0.6rem' }}></i>
                        </span>
                        Tidak Aktif
                    </span>
                </div>

                {/* Section Title */}
                

                <div className="flex flex-row flex-wrap align-items-center justify-content-between gap-3 mb-3">
                    <h4 className="text-xl font-bold text-900 m-0">Tabel Data</h4>
                    <div className="flex align-items-center gap-2 w-full md:w-22rem">
                    <IconField iconPosition="left" className="w-full">
                        <InputIcon className="pi pi-search" />
                        <InputText value={keyword} onChange={(e) => setKeyword(e.target.value)} placeholder="Cari Data..." className="w-full text-sm border-round-md" />
                    </IconField>
                    <Button
                        icon="pi pi-filter-slash"
                        outlined
                        severity="danger"
                        className="border-round-md p-button-sm flex-shrink-0"
                        tooltip="Reset Filter"
                        onClick={() => setKeyword('')}
                    />
                </div>
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
                    dataKey="kode_ruangan"
                    className="p-datatable-sm"
                    emptyMessage="Data ruangan tidak ditemukan."
                    responsiveLayout="scroll"
                >
                    <Column selectionMode="multiple" headerStyle={{ width: '3rem' }}></Column>
                    <Column
                        header="Status"
                        headerStyle={{ width: '4rem' }}
                        body={(r) => (
                            <span
                                className={`w-2rem h-2rem border-round inline-flex align-items-center justify-content-center text-white shadow-1 ${r.status === 'aktif' ? 'bg-green-500' : 'bg-red-500'}`}
                                tooltip={r.status === 'aktif' ? 'Status: Aktif' : 'Status: Tidak Aktif'}
                            >
                                <i className={`pi ${r.status === 'aktif' ? 'pi-check' : 'pi-times'}`} style={{ fontSize: '0.8rem' }}></i>
                            </span>
                        )}
                    ></Column>
                    <Column field="kode_ruangan" header="Kode" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama_ruangan" header="Nama Ruangan" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column
                        header="Aksi"
                        body={(r) => (
                            <div className="flex gap-2 justify-content-center">
                                <Button icon="pi pi-pencil" outlined severity="success" className="p-button-sm border-round-md" onClick={() => handleOpenEdit(r)} tooltip="Edit" />
                                <Button icon="pi pi-trash" outlined severity="danger" className="p-button-sm border-round-md" onClick={() => handleDelete([r.kode_ruangan])} tooltip="Hapus" />
                            </div>
                        )}
                    ></Column>
                </DataTable>
            </div>

            <Dialog header={isEdit ? 'Edit Data Ruangan' : 'Tambah Data Ruangan'} visible={dialogVisible} style={{ width: '480px' }} modal onHide={() => setDialogVisible(false)}>
                <div className="flex flex-column gap-3 pt-2">
                    {isEdit && (
                        <div>
                            <label className="block text-sm font-semibold mb-1">Kode Ruangan</label>
                            <InputText value={formData.kode_ruangan} disabled className="w-full text-sm border-round-md" />
                        </div>
                    )}
                    <div>
                        <label className="block text-sm font-semibold mb-1">Nama Ruangan *</label>
                        <InputText
                            value={formData.nama_ruangan}
                            onChange={(e) => setFormData({ ...formData, nama_ruangan: e.target.value })}
                            placeholder="contoh : Ruang Perawatan 1"
                            className={`w-full text-sm border-round-md ${submitted && !formData.nama_ruangan?.trim() ? 'p-invalid' : ''}`}
                        />
                        {submitted && !formData.nama_ruangan?.trim() && (
                            <small className="p-error text-red-500 text-xs block mt-1">Nama ruangan wajib diisi.</small>
                        )}
                    </div>
                    <div className="surface-50 p-3 border-round-md border-1 surface-border">
                        <div className="flex align-items-center justify-content-between mb-2">
                            <span className="font-bold text-sm text-900">Status Ruangan</span>
                            <InputSwitch
                                checked={formData.status === 'aktif'}
                                onChange={(e) => setFormData({ ...formData, status: e.value ? 'aktif' : 'nonaktif' })}
                            />
                        </div>
                        <span className="text-xs text-600 block">
                            <strong>Status: {formData.status === 'aktif' ? 'Aktif' : 'Non-aktif'}</strong>. {formData.status === 'aktif' ? 'Ruangan aktif dan dapat digunakan dalam seluruh transaksi.' : 'Ruangan dinonaktifkan dari transaksi.'}
                        </span>
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
