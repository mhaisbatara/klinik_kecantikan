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
    const [layananOptions, setLayananOptions] = useState<any[]>([]);
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
        kode_paket_layanan: '',
        kode_ruangan: '',
        nama: '',
        harga_paket: 0,
        masa_berlaku_hari: 365,
        status: 'aktif',
        details: []
    });
    const [saving, setSaving] = useState<boolean>(false);

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await postData('/master/paket-layanan-data', { page, perPage: rows, keyword });
            setData(res.data.data || []);
            setTotalRecords(res.data.total_data || 0);
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal memuat data paket layanan');
        } finally {
            setLoading(false);
        }
    };

    const loadLayanan = async () => {
        try {
            const res = await postData('/master/layanan-data', { status: 'aktif' });
            const list = (res.data.data || []).map((l: any) => ({ label: `${l.nama} (${l.kode_layanan})`, value: l.kode_layanan, nama: l.nama }));
            setLayananOptions(list);
        } catch (error) {
            console.error('Failed to load layanan options');
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
        loadLayanan();
        loadRuangan();
    }, []);

    const handleOpenCreate = () => {
        setIsEdit(false);
        setFormData({
            kode_paket_layanan: '',
            kode_ruangan: ruanganList[0]?.value || '',
            nama: '',
            harga_paket: 0,
            masa_berlaku_hari: 365,
            status: 'aktif',
            details: layananOptions.length > 0 ? [{ kode_layanan: layananOptions[0].value, jumlah_sesi: 1 }] : []
        });
        setDialogVisible(true);
    };

    const handleOpenEdit = (rowData: any) => {
        setIsEdit(true);
        setFormData({
            ...rowData,
            kode_ruangan: rowData.kode_ruangan || '',
            details: (rowData.details || []).map((d: any) => ({
                kode_layanan: d.kode_layanan,
                jumlah_sesi: d.jumlah_sesi
            }))
        });
        setDialogVisible(true);
    };

    const handleAddDetail = () => {
        if (layananOptions.length === 0) return;
        setFormData((prev: any) => ({
            ...prev,
            details: [...prev.details, { kode_layanan: layananOptions[0].value, jumlah_sesi: 1 }]
        }));
    };

    const handleRemoveDetail = (index: number) => {
        setFormData((prev: any) => ({
            ...prev,
            details: prev.details.filter((_: any, i: number) => i !== index)
        }));
    };

    const handleDetailChange = (index: number, field: string, val: any) => {
        setFormData((prev: any) => {
            const updated = [...prev.details];
            updated[index] = { ...updated[index], [field]: val };
            return { ...prev, details: updated };
        });
    };

    const handleSave = async () => {
        if (!formData.nama) {
            showError(toast, 'Nama Paket wajib diisi!');
            return;
        }
        if (!formData.details || formData.details.length === 0) {
            showError(toast, 'Minimal tambahkan 1 detail layanan!');
            return;
        }
        setSaving(true);
        try {
            const endpoint = isEdit ? '/master/paket-layanan-update' : '/master/paket-layanan-create';
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
            message: `Apakah Anda yakin ingin menghapus ${codes.length} paket layanan ini?`,
            header: 'Konfirmasi Hapus',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: async () => {
                try {
                    const res = await postData('/master/paket-layanan-delete', { kode_paket_layanan: codes });
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
                        <i className="pi pi-box text-purple-600 text-2xl" />
                        Kelola Paket Layanan
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Tambah, edit, atau nonaktifkan bundel paket treatment dan sesi layanan.
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
                            onClick={() => handleDelete(selectedRows.map((r) => r.kode_paket_layanan))}
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
                    dataKey="kode_paket_layanan"
                    className="p-datatable-sm"
                    emptyMessage="Data paket layanan tidak ditemukan."
                    responsiveLayout="scroll"
                >
                    <Column selectionMode="multiple" headerStyle={{ width: '3rem' }}></Column>
                    <Column field="kode_paket_layanan" header="Kode Paket" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama" header="Nama Paket" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama_ruangan" header="Ruangan" body={(r) => r.nama_ruangan ? `${r.kode_ruangan ? r.kode_ruangan + ' - ' : ''}${r.nama_ruangan}` : (r.kode_ruangan || '-')}></Column>
                    <Column
                        header="Detail Layanan"
                        body={(r) => (
                            <div className="flex flex-column gap-1">
                                {(r.details || []).map((d: any, i: number) => (
                                    <span key={i} className="text-xs text-700">
                                        • {d.nama_layanan || d.kode_layanan} (<strong>{d.jumlah_sesi} sesi</strong>)
                                    </span>
                                ))}
                            </div>
                        )}
                    ></Column>
                    <Column field="harga_paket" header="Harga Paket" body={(r) => <span className="font-semibold text-green-600">{formatRupiah(r.harga_paket)}</span>}></Column>
                    <Column field="masa_berlaku_hari" header="Masa Berlaku" body={(r) => `${r.masa_berlaku_hari} Hari`}></Column>
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
                                <Button icon="pi pi-trash" outlined severity="danger" className="p-button-sm border-round-md" onClick={() => handleDelete([r.kode_paket_layanan])} tooltip="Hapus" />
                            </div>
                        )}
                    ></Column>
                </DataTable>
            </div>

            <Dialog header={isEdit ? 'Edit Paket Layanan' : 'Tambah Paket Layanan'} visible={dialogVisible} style={{ width: '600px' }} modal onHide={() => setDialogVisible(false)}>
                <div className="flex flex-column gap-3 pt-2">
                    {isEdit && (
                        <div>
                            <label className="block text-sm font-semibold mb-1">Kode Paket</label>
                            <InputText value={formData.kode_paket_layanan} disabled className="w-full text-sm" />
                        </div>
                    )}
                    <div>
                        <label className="block text-sm font-semibold mb-1">Nama Paket *</label>
                        <InputText value={formData.nama} onChange={(e) => setFormData({ ...formData, nama: e.target.value })} placeholder="Masukkan nama paket layanan" className="w-full text-sm" />
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
                        <div className="col-4">
                            <label className="block text-sm font-semibold mb-1">Harga Paket (Rp) *</label>
                            <InputNumber value={formData.harga_paket} onValueChange={(e) => setFormData({ ...formData, harga_paket: e.value })} mode="currency" currency="IDR" locale="id-ID" className="w-full text-sm" />
                        </div>
                        <div className="col-4">
                            <label className="block text-sm font-semibold mb-1">Masa Berlaku (Hari) *</label>
                            <InputNumber value={formData.masa_berlaku_hari} onValueChange={(e) => setFormData({ ...formData, masa_berlaku_hari: e.value })} suffix=" hari" className="w-full text-sm" />
                        </div>
                        <div className="col-4">
                            <label className="block text-sm font-semibold mb-1">Status *</label>
                            <Dropdown
                                value={formData.status}
                                options={[{ label: 'Aktif', value: 'aktif' }, { label: 'Nonaktif', value: 'nonaktif' }]}
                                onChange={(e) => setFormData({ ...formData, status: e.value })}
                                className="w-full text-sm"
                            />
                        </div>
                    </div>

                    <div className="mt-2 border-top-1 surface-border pt-3">
                        <div className="flex align-items-center justify-content-between mb-2">
                            <label className="font-bold text-sm text-900">Detail Layanan Dalam Paket</label>
                            <Button label="Tambah Layanan" icon="pi pi-plus" text size="small" onClick={handleAddDetail} />
                        </div>

                        {(formData.details || []).map((det: any, idx: number) => (
                            <div key={idx} className="flex align-items-center gap-2 mb-2 p-2 surface-100 border-round">
                                <div className="flex-grow-1">
                                    <Dropdown
                                        value={det.kode_layanan}
                                        options={layananOptions}
                                        onChange={(e) => handleDetailChange(idx, 'kode_layanan', e.value)}
                                        placeholder="Pilih Layanan"
                                        className="w-full text-sm"
                                    />
                                </div>
                                <div style={{ width: '120px' }}>
                                    <InputNumber
                                        value={det.jumlah_sesi}
                                        onValueChange={(e) => handleDetailChange(idx, 'jumlah_sesi', e.value || 1)}
                                        suffix=" Sesi"
                                        min={1}
                                        className="w-full text-sm"
                                    />
                                </div>
                                <Button icon="pi pi-trash" rounded text severity="danger" onClick={() => handleRemoveDetail(idx)} tooltip="Hapus" />
                            </div>
                        ))}
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
