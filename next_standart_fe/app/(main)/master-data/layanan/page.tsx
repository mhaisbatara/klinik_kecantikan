'use client';

import { useEffect, useRef, useState } from 'react';
import postData from '@/lib/axios/postData';
import { Toast } from 'primereact/toast';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Button } from 'primereact/button';
import { InputText } from 'primereact/inputtext';
import { InputNumber } from 'primereact/inputnumber';
import { Dialog } from 'primereact/dialog';
import { Tag } from 'primereact/tag';
import { Dropdown } from 'primereact/dropdown';
import { Divider } from 'primereact/divider';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { showError, showSuccess } from '@/lib/tools/generalTools';

const Page = () => {
    const toast = useRef<Toast>(null);

    const [data, setData] = useState<any[]>([]);
    const [kategoriList, setKategoriList] = useState<any[]>([]);
    const [ruanganList, setRuanganList] = useState<any[]>([]);
    const [loading, setLoading] = useState<boolean>(false);
    const [totalRecords, setTotalRecords] = useState<number>(0);
    const [page, setPage] = useState<number>(1);
    const [rows, setRows] = useState<number>(10);
    const [keyword, setKeyword] = useState<string>('');
    const [selectedRows, setSelectedRows] = useState<any[]>([]);

    const [dialogVisible, setDialogVisible] = useState<boolean>(false);
    const [isEdit, setIsEdit] = useState<boolean>(false);
    const [formData, setFormData] = useState<any>({
        kode_layanan: '',
        kode_kategori_layanan: '',
        kode_ruangan: '',
        nama: '',
        harga: 0,
        durasi_menit: 30,
        status: 'aktif',
    });
    const [saving, setSaving] = useState<boolean>(false);

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await postData('/master/layanan-data', { page, perPage: rows, keyword });
            setData(res.data.data || []);
            setTotalRecords(res.data.total_data || 0);
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal memuat data layanan');
        } finally {
            setLoading(false);
        }
    };

    const loadKategori = async () => {
        try {
            const res = await postData('/master/kategori-layanan-data', { status: 'aktif' });
            const list = (res.data.data || []).map((k: any) => ({ label: k.nama, value: k.kode_kategori_layanan }));
            setKategoriList(list);
        } catch (error) {
            console.error('Failed to fetch kategori list');
        }
    };

    const loadRuangan = async () => {
        try {
            const res = await postData('/master/ruangan-dropdown', {});
            const list = (res.data.data || []).map((r: any) => ({ label: `${r.kode_ruangan} - ${r.nama_ruangan}`, value: r.kode_ruangan }));
            setRuanganList(list);
        } catch (error) {
            console.error('Failed to fetch ruangan list');
        }
    };

    useEffect(() => {
        loadData();
    }, [page, rows, keyword]);

    useEffect(() => {
        loadKategori();
        loadRuangan();
    }, []);

    const handleOpenCreate = () => {
        setIsEdit(false);
        setFormData({ kode_layanan: '', kode_kategori_layanan: kategoriList[0]?.value || '', kode_ruangan: ruanganList[0]?.value || '', nama: '', harga: 0, durasi_menit: 30, status: 'aktif' });
        setDialogVisible(true);
    };

    const handleOpenEdit = (rowData: any) => {
        setIsEdit(true);
        setFormData({
            ...rowData,
            kode_ruangan: rowData.kode_ruangan || '',
        });
        setDialogVisible(true);
    };

    const handleSave = async () => {
        if (!formData.nama || !formData.kode_kategori_layanan) {
            showError(toast, 'Nama dan Kategori Layanan wajib diisi!');
            return;
        }
        setSaving(true);
        try {
            const endpoint = isEdit ? '/master/layanan-update' : '/master/layanan-create';
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
            message: `Apakah Anda yakin ingin menghapus ${codes.length} data layanan ini?`,
            header: 'Konfirmasi Hapus',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: async () => {
                try {
                    const res = await postData('/master/layanan-delete', { kode_layanan: codes });
                    showSuccess(toast, res.data.message || 'Berhasil dihapus');
                    setSelectedRows([]);
                    loadData();
                } catch (error: any) {
                    showError(toast, error?.response?.data?.message || 'Gagal menghapus data');
                }
            }
        });
    };

    const formatRupiah = (val: number) => {
        return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val || 0);
    };

    return (
        <div className="p-4">
            <Toast ref={toast} />
            <ConfirmDialog />

            <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
                <div className="mb-4">
                    <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
                        <i className="pi pi-briefcase text-purple-600 text-2xl" />
                        Kelola Data Layanan
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Tambah, edit, atau nonaktifkan treatment dan layanan klinik kecantikan.
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
                            onClick={() => handleDelete(selectedRows.map((r) => r.kode_layanan))}
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
                    dataKey="kode_layanan"
                    className="p-datatable-sm"
                    emptyMessage="Data layanan tidak ditemukan."
                    responsiveLayout="scroll"
                >
                    <Column selectionMode="multiple" headerStyle={{ width: '3rem' }}></Column>
                    <Column field="kode_layanan" header="Kode" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama" header="Nama Layanan" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama_kategori" header="Kategori" body={(r) => r.nama_kategori || r.kode_kategori_layanan || '-'}></Column>
                    <Column field="nama_ruangan" header="Ruangan" body={(r) => r.nama_ruangan ? `${r.kode_ruangan ? r.kode_ruangan + ' - ' : ''}${r.nama_ruangan}` : (r.kode_ruangan || '-')}></Column>
                    <Column field="harga" header="Harga" body={(r) => <span className="font-semibold text-green-600">{formatRupiah(r.harga)}</span>}></Column>
                    <Column field="durasi_menit" header="Durasi" body={(r) => `${r.durasi_menit} Menit`}></Column>
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
                                <Button icon="pi pi-trash" outlined severity="danger" className="p-button-sm border-round-md" onClick={() => handleDelete([r.kode_layanan])} tooltip="Hapus" />
                            </div>
                        )}
                    ></Column>
                </DataTable>
            </div>

            <Dialog header={isEdit ? 'Edit Data Layanan' : 'Tambah Data Layanan'} visible={dialogVisible} style={{ width: '500px' }} modal onHide={() => setDialogVisible(false)}>
                <div className="flex flex-column gap-3 pt-2">
                    {isEdit && (
                        <div>
                            <label className="block text-sm font-semibold mb-1">Kode Layanan</label>
                            <InputText value={formData.kode_layanan} disabled className="w-full text-sm" />
                        </div>
                    )}
                    <div>
                        <label className="block text-sm font-semibold mb-1">Nama Layanan *</label>
                        <InputText value={formData.nama} onChange={(e) => setFormData({ ...formData, nama: e.target.value })} placeholder="Masukkan nama layanan" className="w-full text-sm" />
                    </div>
                    <div>
                        <label className="block text-sm font-semibold mb-1">Kategori Layanan *</label>
                        <Dropdown
                            value={formData.kode_kategori_layanan}
                            options={kategoriList}
                            onChange={(e) => setFormData({ ...formData, kode_kategori_layanan: e.value })}
                            placeholder="Pilih Kategori"
                            className="w-full text-sm"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-semibold mb-1">Ruangan</label>
                        <Dropdown
                            value={formData.kode_ruangan}
                            options={ruanganList}
                            onChange={(e) => setFormData({ ...formData, kode_ruangan: e.value })}
                            placeholder="Pilih Ruangan"
                            showClear
                            className="w-full text-sm"
                        />
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Harga (Rp) *</label>
                            <InputNumber value={formData.harga} onValueChange={(e) => setFormData({ ...formData, harga: e.value })} mode="currency" currency="IDR" locale="id-ID" className="w-full text-sm" />
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Durasi (Menit) *</label>
                            <InputNumber value={formData.durasi_menit} onValueChange={(e) => setFormData({ ...formData, durasi_menit: e.value })} suffix=" menit" className="w-full text-sm" />
                        </div>
                    </div>
                    <div>
                        <label className="block text-sm font-semibold mb-1">Status *</label>
                        <Dropdown
                            value={formData.status}
                            options={[{ label: 'Aktif', value: 'aktif' }, { label: 'Nonaktif', value: 'nonaktif' }]}
                            onChange={(e) => setFormData({ ...formData, status: e.value })}
                            className="w-full text-sm"
                        />
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
