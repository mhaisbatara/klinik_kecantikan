'use client';

import React, { useState } from 'react';
import { Toast } from 'primereact/toast';
import { PasienFormCard, PasienFormData } from './PasienFormCard';
import { KarcisAntrianModal } from './dialogs/KarcisAntrianModal';
import { KarcisAntrianLayananModal } from './dialogs/KarcisAntrianLayananModal';
import { StepPilihLayanan } from './StepPilihLayanan';

interface Props {
  toast: React.RefObject<Toast>;
  editingPasien?: Partial<PasienFormData> | null;
  onCancelEdit?: () => void;
  onRefreshVisits?: () => void;
}

export const TabPendaftaran: React.FC<Props> = ({
  toast,
  editingPasien,
  onCancelEdit,
  onRefreshVisits,
}) => {
  // Step state: 1 = Form Pendaftaran Pasien, 2 = Pilih Layanan & Menerbitkan Kunjungan
  const [step, setStep] = useState<number>(1);
  const [selectedPasien, setSelectedPasien] = useState<any>(null);

  // Success Ticket Modals
  const [karcisVisible, setKarcisVisible] = useState(false);
  const [ticketData, setTicketData] = useState<any>(null);

  const [antrianLayananModalVisible, setAntrianLayananModalVisible] = useState(false);
  const [antrianLayananData, setAntrianLayananData] = useState<any>(null);

  const handleRegistrationSuccess = (resultData: any) => {
    if (resultData && (resultData.no_rm || resultData.id)) {
      setSelectedPasien(resultData);
      setStep(2); // Move to Step 2: Pilih Layanan & Paket
    }
  };

  const handleLayananSuccess = (resultData: any) => {
    if (resultData.antrian_layanan && resultData.antrian_layanan.length > 0) {
      setAntrianLayananData(resultData);
      setAntrianLayananModalVisible(true);
    } else {
      setTicketData({
        no_rm: resultData.no_rm,
        nama: resultData.nama_pasien,
        kode_kunjungan: resultData.kode_kunjungan,
        nomor_antrian: resultData.nomor_antrian_awal,
        kode_antrian: resultData.kode_antrian_awal,
        tanggal_kunjungan: resultData.tanggal_kunjungan,
        jam_datang: resultData.jam_datang,
      });
      setKarcisVisible(true);
    }

    if (onRefreshVisits) onRefreshVisits();
    setStep(1);
    setSelectedPasien(null);
    if (onCancelEdit) onCancelEdit();
  };

  // Render Step 2 if active (Pilih Layanan & Paket)
  if (step === 2 && selectedPasien) {
    return (
      <>
        <StepPilihLayanan
          pasienData={selectedPasien}
          toast={toast}
          onSuccess={handleLayananSuccess}
          onBack={() => {
            setStep(1);
            setSelectedPasien(null);
          }}
        />

        {/* TICKET MODALS */}
        <KarcisAntrianModal
          visible={karcisVisible}
          onHide={() => setKarcisVisible(false)}
          data={ticketData}
        />

        <KarcisAntrianLayananModal
          visible={antrianLayananModalVisible}
          onHide={() => setAntrianLayananModalVisible(false)}
          data={antrianLayananData}
        />
      </>
    );
  }

  // Render Step 1 (Form Pendaftaran Pasien Langsung Inline)
  return (
    <>
      <PasienFormCard
        initialData={editingPasien}
        onSuccess={handleRegistrationSuccess}
        onCancel={editingPasien ? onCancelEdit : undefined}
        toast={toast}
      />

      {/* TICKET MODALS */}
      <KarcisAntrianModal
        visible={karcisVisible}
        onHide={() => setKarcisVisible(false)}
        data={ticketData}
      />

      <KarcisAntrianLayananModal
        visible={antrianLayananModalVisible}
        onHide={() => setAntrianLayananModalVisible(false)}
        data={antrianLayananData}
      />
    </>
  );
};
