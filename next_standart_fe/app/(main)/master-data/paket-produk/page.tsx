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
import { InputSwitch } from 'primereact/inputswitch';
import { confirmDialog, ConfirmDialog } from 'primereact/confirmdialog';
import { IconField } from 'primereact/iconfield';
import { InputIcon } from 'primereact/inputicon';
import { showError, showSuccess } from '@/lib/tools/generalTools';

const Page = () => {
    const toast = useRef<Toast>(null);

    const [data, setData] = useState<any[]>([]);
    const [produkOptions, setProdukOptions] = useState<any[]>([]);
    const [loading, setLoading] = useState<boolean>(false);
    const [totalRecords, setTotalRecords] = useState<number>(0);
    const [page, setPage] = useState<number>(1);
    const [rows, setRows] = useState<number>(10);
    const [keyword, setKeyword] = useState<string>('');
    const [selectedRows, setSelectedRows] = useState<any[]>([]);
    const [expandedRows, setExpandedRows] = useState<any>(null);

    const [dialogVisible, setDialogVisible] = useState<boolean>(false);
    const [isEdit, setIsEdit] = useState<boolean>(false);
    const [submitted, setSubmitted] = useState<boolean>(false);
    const [formData, setFormData] = useState<any>({
        kode_paket_produk: '',
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
            const res = await postData('/master/paket-produk-data', { page, perPage: rows, keyword });
            setData(res.data.data || []);
            setTotalRecords(res.data.total_data || 0);
        } catch (error: any) {
            showError(toast, error?.response?.data?.message || 'Gagal memuat data paket produk');
        } finally {
            setLoading(false);
        }
    };

    const loadProduk = async () => {
        try {
            const res = await postData('/master/produk-data', { status: 'aktif' });
            const list = (res.data.data || []).map((p: any) => ({ label: `${p.nama} (${p.kode_produk})`, value: p.kode_produk, nama: p.nama }));
            setProdukOptions(list);
        } catch (error) {
            console.error('Failed to load produk options');
        }
    };

    useEffect(() => {
        loadData();
    }, [page, rows, keyword]);

    useEffect(() => {
        loadProduk();
    }, []);

    const handleOpenCreate = () => {
        setIsEdit(false);
        setSubmitted(false);
        setFormData({
            kode_paket_produk: '',
            nama: '',
            harga_paket: 0,
            masa_berlaku_hari: 365,
            status: 'aktif',
            details: produkOptions.length > 0 ? [{ kode_produk: produkOptions[0].value, jumlah: 1 }] : []
        });
        setDialogVisible(true);
    };

    const handleOpenEdit = (rowData: any) => {
        setIsEdit(true);
        setSubmitted(false);
        setFormData({
            ...rowData,
            details: (rowData.details || []).map((d: any) => ({
                kode_produk: d.kode_produk,
                jumlah: d.jumlah
            }))
        });
        setDialogVisible(true);
    };

    const toggleRowExpansion = (rowData: any) => {
        let _expandedRows = { ...expandedRows };
        if (_expandedRows[rowData.kode_paket_produk]) {
            delete _expandedRows[rowData.kode_paket_produk];
        } else {
            _expandedRows[rowData.kode_paket_produk] = true;
        }
        setExpandedRows(_expandedRows);
    };

    const handleAddDetail = () => {
        if (produkOptions.length === 0) return;
        setFormData((prev: any) => ({
            ...prev,
            details: [...prev.details, { kode_produk: produkOptions[0].value, jumlah: 1 }]
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
        setSubmitted(true);
        if (!formData.nama || !formData.nama.trim()) {
            showError(toast, 'Nama Paket wajib diisi!');
            return;
        }
        if (!formData.details || formData.details.length === 0) {
            showError(toast, 'Minimal tambahkan 1 detail produk!');
            return;
        }
        setSaving(true);
        try {
            const endpoint = isEdit ? '/master/paket-produk-update' : '/master/paket-produk-create';
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
            message: `Apakah Anda yakin ingin menghapus ${codes.length} paket produk ini?`,
            header: 'Konfirmasi Hapus',
            icon: 'pi pi-exclamation-triangle',
            acceptLabel: 'Ya, Hapus',
            rejectLabel: 'Batal',
            acceptClassName: 'p-button-danger',
            accept: async () => {
                try {
                    const res = await postData('/master/paket-produk-delete', { kode_paket_produk: codes });
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

    const rowExpansionTemplate = (data: any) => {
        return (
            <div className="p-3 surface-50 border-round border-1 surface-border my-2">
                <div className="flex align-items-center justify-content-between mb-2">
                    <h5 className="m-0 font-bold text-sm text-900 flex align-items-center gap-2">
                        <i className="pi pi-list text-purple-600"></i>
                        Detail Produk Paket: {data.nama} ({data.kode_paket_produk})
                    </h5>
                    <span className="text-xs text-500 font-medium">Total: {data.details?.length || 0} Produk</span>
                </div>
                <div className="border-1 surface-border border-round overflow-hidden surface-card">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="surface-200 text-800 text-xs">
                                <th className="p-2 border-bottom-1 surface-border" style={{ width: '3rem' }}>No</th>
                                <th className="p-2 border-bottom-1 surface-border">Kode Produk</th>
                                <th className="p-2 border-bottom-1 surface-border">Nama Produk</th>
                                <th className="p-2 border-bottom-1 surface-border text-right" style={{ width: '120px' }}>Jumlah Pcs</th>
                            </tr>
                        </thead>
                        <tbody>
                            {(data.details || []).map((item: any, idx: number) => (
                                <tr key={idx} className="border-bottom-1 surface-border text-sm hover:surface-100">
                                    <td className="p-2 text-500">{idx + 1}</td>
                                    <td className="p-2 text-primary font-medium">{item.kode_produk}</td>
                                    <td className="p-2 font-medium">{item.nama_produk || item.kode_produk}</td>
                                    <td className="p-2 text-right">
                                        <Tag value={`${item.jumlah} Pcs`} severity="info" />
                                    </td>
                                </tr>
                            ))}
                            {(!data.details || data.details.length === 0) && (
                                <tr>
                                    <td colSpan={4} className="p-3 text-center text-500 text-sm">Tidak ada detail produk.</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        );
    };

    return (
        <div className="p-4">
            <Toast ref={toast} />
            <ConfirmDialog />

            {/* Header Action Bar */}
            <div className="card border-round-xl p-4 shadow-1 surface-card mb-4">
                {/* Page Header */}
                <div className="mb-4 pb-3 border-bottom-1 surface-border">
                    <h3 className="text-2xl font-bold text-900 flex align-items-center gap-2 mb-1">
                        <i className="pi pi-inbox text-purple-600 text-2xl" />
                        Kelola Paket Produk & Skincare
                    </h3>
                    <p className="text-500 text-sm m-0">
                        Tambah, edit, atau nonaktifkan bundel paket produk dan skincare klinik.
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
                                    onClick={() => handleDelete(selectedRows.map((r) => r.kode_paket_produk))}
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
                    expandedRows={expandedRows}
                    onRowToggle={(e) => setExpandedRows(e.data)}
                    rowExpansionTemplate={rowExpansionTemplate}
                    dataKey="kode_paket_produk"
                    className="p-datatable-sm"
                    emptyMessage="Data paket produk tidak ditemukan."
                    responsiveLayout="scroll"
                >
                    <Column expander style={{ width: '3rem' }} />
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
                    <Column field="kode_paket_produk" header="Kode" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column field="nama" header="Nama Paket" sortable headerStyle={{ fontWeight: 'bold' }}></Column>
                    <Column
                        header="Detail Produk"
                        body={(r) => (
                            <Button
                                label={`Lihat Detail (${r.details?.length || 0})`}
                                icon="pi pi-eye"
                                text
                                size="small"
                                className="p-button-sm text-primary font-semibold p-1"
                                onClick={() => toggleRowExpansion(r)}
                            />
                        )}
                    ></Column>
                    <Column field="harga_paket" header="Harga Paket" body={(r) => <span className="font-semibold text-green-600">{formatRupiah(r.harga_paket)}</span>}></Column>
                    <Column field="masa_berlaku_hari" header="Masa Berlaku" body={(r) => `${r.masa_berlaku_hari} Hari`}></Column>
                    <Column
                        header="Aksi"
                        body={(r) => (
                            <div className="flex gap-2 justify-content-center">
                                <Button icon="pi pi-pencil" outlined severity="success" className="p-button-sm border-round-md" onClick={() => handleOpenEdit(r)} tooltip="Edit" />
                                <Button icon="pi pi-trash" outlined severity="danger" className="p-button-sm border-round-md" onClick={() => handleDelete([r.kode_paket_produk])} tooltip="Hapus" />
                            </div>
                        )}
                    ></Column>
                </DataTable>
            </div>

            {/* Modal Create/Edit */}
            <Dialog header={isEdit ? 'Edit Paket Produk' : 'Tambah Paket Produk'} visible={dialogVisible} style={{ width: '600px' }} modal onHide={() => setDialogVisible(false)}>
                <div className="flex flex-column gap-3 pt-2">
                    {isEdit && (
                        <div>
                            <label className="block text-sm font-semibold mb-1">Kode Paket</label>
                            <InputText value={formData.kode_paket_produk} disabled className="w-full text-sm border-round-md" />
                        </div>
                    )}
                    <div>
                        <label className="block text-sm font-semibold mb-1">Nama Paket *</label>
                        <InputText
                            value={formData.nama}
                            onChange={(e) => setFormData({ ...formData, nama: e.target.value })}
                            placeholder="contoh : Paket Acne Care Complete"
                            className={`w-full text-sm border-round-md ${submitted && !formData.nama?.trim() ? 'p-invalid' : ''}`}
                        />
                        {submitted && !formData.nama?.trim() && (
                            <small className="p-error text-red-500 text-xs block mt-1">Nama paket wajib diisi.</small>
                        )}
                    </div>
                    <div className="grid">
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Harga Paket (Rp) *</label>
                            <InputNumber value={formData.harga_paket} onValueChange={(e) => setFormData({ ...formData, harga_paket: e.value })} mode="currency" currency="IDR" locale="id-ID" className="w-full text-sm border-round-md" />
                        </div>
                        <div className="col-6">
                            <label className="block text-sm font-semibold mb-1">Masa Berlaku (Hari) *</label>
                            <InputNumber value={formData.masa_berlaku_hari} onValueChange={(e) => setFormData({ ...formData, masa_berlaku_hari: e.value })} suffix=" hari" className="w-full text-sm border-round-md" />
                        </div>
                    </div>

                    <div className="surface-50 p-3 border-round-md border-1 surface-border">
                        <div className="flex align-items-center justify-content-between mb-2">
                            <span className="font-bold text-sm text-900">Status Paket</span>
                            <InputSwitch
                                checked={formData.status === 'aktif'}
                                onChange={(e) => setFormData({ ...formData, status: e.value ? 'aktif' : 'nonaktif' })}
                            />
                        </div>
                        <span className="text-xs text-600 block">
                            <strong>Status: {formData.status === 'aktif' ? 'Aktif' : 'Non-aktif'}</strong>. {formData.status === 'aktif' ? 'Paket aktif dan dapat digunakan dalam seluruh transaksi.' : 'Paket dinonaktifkan dari transaksi.'}
                        </span>
                    </div>

                    <div className="mt-2 border-top-1 surface-border pt-3">
                        <div className="flex align-items-center justify-content-between mb-2">
                            <label className="font-bold text-sm text-900">Detail Produk Dalam Paket *</label>
                            <Button label="Tambah Produk" icon="pi pi-plus" text size="small" onClick={handleAddDetail} />
                        </div>
                        {submitted && (!formData.details || formData.details.length === 0) && (
                            <small className="p-error text-red-500 text-xs block mb-2">Minimal tambahkan 1 detail produk dalam paket.</small>
                        )}

                        {(formData.details || []).map((det: any, idx: number) => (
                            <div key={idx} className="flex align-items-center gap-2 mb-2 p-2 surface-100 border-round">
                                <div className="flex-grow-1">
                                    <Dropdown
                                        value={det.kode_produk}
                                        options={produkOptions}
                                        onChange={(e) => handleDetailChange(idx, 'kode_produk', e.value)}
                                        placeholder="Pilih Produk..."
                                        className="w-full text-sm"
                                    />
                                </div>
                                <div style={{ width: '120px' }}>
                                    <InputNumber
                                        value={det.jumlah}
                                        onValueChange={(e) => handleDetailChange(idx, 'jumlah', e.value || 1)}
                                        suffix=" Pcs"
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
