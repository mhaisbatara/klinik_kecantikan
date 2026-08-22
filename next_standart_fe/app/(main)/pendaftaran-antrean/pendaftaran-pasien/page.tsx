'use client';

import React, { useRef, useState } from 'react';
import { Toast } from 'primereact/toast';
import { TabView, TabPanel } from 'primereact/tabview';
import { TabPendaftaran } from './components/tab_pendaftaran';
import { TabPendaftaranLama } from './components/tab_pendaftaran_lama';
import { TabPasienLama } from './components/tab_pasien_lama';

const PendaftaranPasienPage = () => {
  const toast = useRef<Toast>(null);
  const [activeTab, setActiveTab] = useState(0);
  const [editingPasien, setEditingPasien] = useState<any>(null);

  const handleAddNewPasien = () => {
    setEditingPasien(null);
    setActiveTab(0);
  };

  const handleEditPasien = (pasien: any) => {
    setEditingPasien(pasien);
    setActiveTab(0);
  };

  return (
    <>
      <Toast ref={toast} position="top-right" />

      {/* PAGE TITLE HEADER CARD */}
      <div className="card p-0 mb-3 border-round-xl surface-border shadow-1 overflow-hidden">
        <div className="p-4 bg-blue-50 border-bottom-1 surface-border">
          <h2 className="text-3xl font-bold flex align-items-center gap-2 mb-1 text-blue-900">
            <i className="pi pi-user-plus text-blue-600 text-3xl" />
            Pendaftaran Pasien
          </h2>
          <p className="text-color-secondary m-0 text-sm">
            Registrasi pasien baru & pasien lama, alur pilih layanan treatment & antrean, kelola master data pasien.
          </p>
        </div>
      </div>

      {/* TAB CONTAINER */}
      <TabView
        activeIndex={activeTab}
        onTabChange={(e) => setActiveTab(e.index)}
        className="p-tabview-custom"
      >
        <TabPanel
          header="Pendaftaran Pasien Baru"
          leftIcon="pi pi-user-plus mr-2"
        >
          <TabPendaftaran
            toast={toast}
            editingPasien={editingPasien}
            onCancelEdit={() => setEditingPasien(null)}
          />
        </TabPanel>

        <TabPanel
          header="Pendaftaran Pasien Lama"
          leftIcon="pi pi-search mr-2"
        >
          <TabPendaftaranLama
            toast={toast}
          />
        </TabPanel>

        <TabPanel
          header="Kelola Master Data"
          leftIcon="pi pi-list mr-2"
        >
          <TabPasienLama
            toast={toast}
            onAddNewPasien={handleAddNewPasien}
            onEditPasien={handleEditPasien}
          />
        </TabPanel>
      </TabView>
    </>
  );
};

export default PendaftaranPasienPage;
