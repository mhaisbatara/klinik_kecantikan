'use client';

import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Dialog } from 'primereact/dialog';
import { Button } from 'primereact/button';
import { Slider } from 'primereact/slider';
import { Tag } from 'primereact/tag';

interface Props {
  visible: boolean;
  onHide: () => void;
  imageSrc: string; // URL or Data URL or Blob URL
  aspectRatio?: number; // width / height (e.g. 16/9 or 2/1)
  targetWidth?: number;
  targetHeight?: number;
  onSave: (croppedFile: File, previewUrl: string) => void;
  previewTitle?: string;
  previewCategory?: string;
  previewPrice?: number;
  previewDuration?: number;
}

export const ImageCropDialog: React.FC<Props> = ({
  visible,
  onHide,
  imageSrc,
  aspectRatio = 1.4, // ~4:3 / 1.4 ratio (e.g. 560x400) matching the taller card layout
  targetWidth = 560,
  targetHeight = 400,
  onSave,
  previewTitle = 'Contoh Nama Layanan',
  previewCategory = 'LAYANAN',
  previewPrice = 100000,
  previewDuration = 30,
}) => {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [imageObj, setImageObj] = useState<HTMLImageElement | null>(null);
  const [zoom, setZoom] = useState<number>(1);
  const [minZoom, setMinZoom] = useState<number>(0.1);
  const [maxZoom, setMaxZoom] = useState<number>(3);
  const [offset, setOffset] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState<boolean>(false);
  const [dragStart, setDragStart] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [previewDataUrl, setPreviewDataUrl] = useState<string>('');
  const [bgColor, setBgColor] = useState<string>('#ffffff');
  const [rotation, setRotation] = useState<number>(0);

  // Load image
  useEffect(() => {
    if (!imageSrc || !visible) return;

    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => {
      setImageObj(img);

      // Calculate initial zoom based on contain
      const cw = targetWidth;
      const ch = targetHeight;
      const fitZoom = Math.min(cw / img.width, ch / img.height);
      const coverZoom = Math.max(cw / img.width, ch / img.height);

      setMinZoom(Math.max(0.05, fitZoom * 0.5));
      setMaxZoom(Math.max(4, coverZoom * 3));

      // Default: fit the entire image with subtle padding if it's wide logo, or cover
      // Let's set default to fit so entire image/logo is visible by default
      setZoom(fitZoom * 0.95);
      setOffset({ x: 0, y: 0 });
      setRotation(0);
    };
    img.src = imageSrc;
  }, [imageSrc, visible, targetWidth, targetHeight]);

  // Draw on Canvas
  const drawCanvas = useCallback(() => {
    const canvas = canvasRef.current;
    if (!canvas || !imageObj) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    canvas.width = targetWidth;
    canvas.height = targetHeight;

    // 1. Fill background
    ctx.fillStyle = bgColor;
    ctx.fillRect(0, 0, targetWidth, targetHeight);

    // 2. Draw transformed image
    ctx.save();
    ctx.translate(targetWidth / 2 + offset.x, targetHeight / 2 + offset.y);
    ctx.rotate((rotation * Math.PI) / 180);
    ctx.scale(zoom, zoom);

    ctx.drawImage(
      imageObj,
      -imageObj.width / 2,
      -imageObj.height / 2,
      imageObj.width,
      imageObj.height
    );
    ctx.restore();

    // 3. Update preview data URL
    try {
      const dataUrl = canvas.toDataURL('image/jpeg', 0.9);
      setPreviewDataUrl(dataUrl);
    } catch {
      // Ignore security error if tainted
    }
  }, [imageObj, zoom, offset, rotation, bgColor, targetWidth, targetHeight]);

  useEffect(() => {
    if (visible && imageObj) {
      drawCanvas();
    }
  }, [visible, imageObj, drawCanvas]);

  // Preset Handlers
  const handleFitContain = () => {
    if (!imageObj) return;
    const fitZoom = Math.min(targetWidth / imageObj.width, targetHeight / imageObj.height) * 0.92;
    setZoom(fitZoom);
    setOffset({ x: 0, y: 0 });
  };

  const handleFitCover = () => {
    if (!imageObj) return;
    const coverZoom = Math.max(targetWidth / imageObj.width, targetHeight / imageObj.height);
    setZoom(coverZoom);
    setOffset({ x: 0, y: 0 });
  };

  const handleCenter = () => {
    setOffset({ x: 0, y: 0 });
  };

  const handleRotate = () => {
    setRotation((prev) => (prev + 90) % 360);
  };

  // Mouse / Touch Drag Events on Canvas
  const handleMouseDown = (e: React.MouseEvent<HTMLCanvasElement>) => {
    setIsDragging(true);
    setDragStart({ x: e.clientX - offset.x, y: e.clientY - offset.y });
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!isDragging) return;
    setOffset({
      x: e.clientX - dragStart.x,
      y: e.clientY - dragStart.y,
    });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  // Wheel Zoom
  const handleWheel = (e: React.WheelEvent<HTMLCanvasElement>) => {
    e.preventDefault();
    const delta = e.deltaY > 0 ? -0.05 : 0.05;
    setZoom((prev) => Math.min(maxZoom, Math.max(minZoom, prev + delta)));
  };

  // Apply & Save
  const handleApply = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    canvas.toBlob(
      (blob) => {
        if (!blob) return;
        const file = new File([blob], `foto_${Date.now()}.jpg`, { type: 'image/jpeg' });
        const previewUrl = URL.createObjectURL(blob);
        onSave(file, previewUrl);
        onHide();
      },
      'image/jpeg',
      0.92
    );
  };

  const formatRupiah = (val: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(val || 0);
  };

  return (
    <Dialog
      visible={visible}
      onHide={onHide}
      header={
        <div className="flex align-items-center gap-2">
          <i className="pi pi-sliders-h text-primary text-xl" />
          <div>
            <span className="font-bold text-lg text-900 block">Atur & Sesuaikan Tampilan Foto</span>
            <span className="text-xs text-500 font-normal">
              Geser, atur zoom, atau pilih preset agar foto pas dan tidak terpotong di kartu
            </span>
          </div>
        </div>
      }
      style={{ width: '90vw', maxWidth: '820px' }}
      modal
      footer={
        <div className="flex align-items-center justify-content-between w-full pt-2">
          <div className="flex align-items-center gap-2">
            <span className="text-xs text-500 hidden sm:inline">
              <i className="pi pi-info-circle mr-1" />
              Tahan & geser foto untuk mengubah posisi
            </span>
          </div>
          <div className="flex gap-2">
            <Button
              label="Batal"
              icon="pi pi-times"
              severity="secondary"
              outlined
              size="small"
              onClick={onHide}
            />
            <Button
              label="Terapkan & Simpan Foto"
              icon="pi pi-check"
              size="small"
              className="font-bold px-3"
              onClick={handleApply}
            />
          </div>
        </div>
      }
    >
      <div className="grid pt-2">
        {/* LEFT COLUMN: INTERACTIVE EDITOR */}
        <div className="col-12 md:col-7 flex flex-column gap-3">
          {/* Canvas Viewport */}
          <div className="surface-50 p-3 border-round-xl border-1 surface-border flex flex-column align-items-center">
            <div className="w-full flex align-items-center justify-content-between mb-2">
              <span className="text-xs font-bold text-700 uppercase tracking-wider flex align-items-center gap-1">
                <i className="pi pi-pencil text-xs" /> Area Bingkai Kartu (4 : 3)
              </span>
              <span className="text-xs text-500">Bisa di-drag & zoom</span>
            </div>

            <div
              className="relative border-round-lg overflow-hidden border-2 border-primary surface-card shadow-2"
              style={{
                width: '100%',
                maxWidth: '440px',
                aspectRatio: `${aspectRatio}`,
                cursor: isDragging ? 'grabbing' : 'grab',
              }}
            >
              <canvas
                ref={canvasRef}
                onMouseDown={handleMouseDown}
                onMouseMove={handleMouseMove}
                onMouseUp={handleMouseUp}
                onMouseLeave={handleMouseUp}
                onWheel={handleWheel}
                style={{
                  width: '100%',
                  height: '100%',
                  display: 'block',
                }}
              />
            </div>

            {/* Quick Preset Buttons */}
            <div className="flex flex-wrap align-items-center justify-content-center gap-2 mt-3 w-full">
              <Button
                type="button"
                label="Muat Utuh (Fit)"
                icon="pi pi-arrows-alt"
                size="small"
                outlined
                severity="info"
                className="text-xs font-semibold py-1 px-2"
                onClick={handleFitContain}
                tooltip="Tampilkan seluruh foto/logo secara utuh tanpa terpotong"
                tooltipOptions={{ position: 'top' }}
              />
              <Button
                type="button"
                label="Penuhi Bingkai (Cover)"
                icon="pi pi-expand"
                size="small"
                outlined
                severity="secondary"
                className="text-xs font-semibold py-1 px-2"
                onClick={handleFitCover}
                tooltip="Perbesar agar memenuhi seluruh area bingkai"
                tooltipOptions={{ position: 'top' }}
              />
              <Button
                type="button"
                label="Pusatkan"
                icon="pi pi-align-center"
                size="small"
                outlined
                severity="secondary"
                className="text-xs font-semibold py-1 px-2"
                onClick={handleCenter}
                tooltip="Pusatkan posisi foto ke tengah bingkai"
                tooltipOptions={{ position: 'top' }}
              />
              <Button
                type="button"
                icon="pi pi-refresh"
                size="small"
                outlined
                severity="secondary"
                className="text-xs font-semibold py-1 px-2"
                onClick={handleRotate}
                tooltip="Putar 90 derajat"
                tooltipOptions={{ position: 'top' }}
              />
            </div>
          </div>

          {/* Zoom Slider Control */}
          <div className="surface-card p-3 border-round-xl border-1 surface-border">
            <div className="flex align-items-center justify-content-between mb-2">
              <label className="text-xs font-bold text-700 flex align-items-center gap-1">
                <i className="pi pi-search-plus text-xs" /> Perbesaran (Zoom)
              </label>
              <span className="text-xs font-semibold text-primary">{Math.round(zoom * 100)}%</span>
            </div>
            <div className="flex align-items-center gap-3">
              <Button
                type="button"
                icon="pi pi-minus"
                size="small"
                text
                rounded
                severity="secondary"
                onClick={() => setZoom((prev) => Math.max(minZoom, prev - 0.1))}
              />
              <div className="flex-1">
                <Slider
                  value={Math.round(zoom * 100)}
                  min={Math.round(minZoom * 100)}
                  max={Math.round(maxZoom * 100)}
                  onChange={(e) => setZoom((Number(e.value) || 100) / 100)}
                />
              </div>
              <Button
                type="button"
                icon="pi pi-plus"
                size="small"
                text
                rounded
                severity="secondary"
                onClick={() => setZoom((prev) => Math.min(maxZoom, prev + 0.1))}
              />
            </div>
          </div>

          {/* Background Color Picker (For letterboxing) */}
          <div className="surface-card p-2 px-3 border-round-xl border-1 surface-border flex align-items-center justify-content-between">
            <span className="text-xs font-semibold text-700">Warna Latar Belakang Padding:</span>
            <div className="flex items-center gap-2">
              {[
                { label: 'Putih', color: '#ffffff' },
                { label: 'Abu Terang', color: '#f8fafc' },
                { label: 'Abu-Abu', color: '#f1f5f9' },
                { label: 'Gelap', color: '#0f172a' },
              ].map((c) => (
                <button
                  key={c.color}
                  type="button"
                  onClick={() => setBgColor(c.color)}
                  style={{
                    backgroundColor: c.color,
                    border: bgColor === c.color ? '2px solid #3b82f6' : '1px solid #cbd5e1',
                  }}
                  className="w-2rem h-2rem border-round-md cursor-pointer transition-all shadow-1"
                  title={c.label}
                />
              ))}
            </div>
          </div>
        </div>

        {/* RIGHT COLUMN: REALTIME STEP 2 CARD PREVIEW */}
        <div className="col-12 md:col-5 flex flex-column">
          <div className="surface-50 p-3 border-round-xl border-1 surface-border h-full flex flex-column">
            <div className="mb-3">
              <span className="text-xs font-bold text-700 uppercase tracking-wider block mb-1">
                Pratinjau Hasil di Kartu
              </span>
              <span className="text-xs text-500">
                Tampilan persis yang akan dilihat kasir/pasien pada Step 2 Pendaftaran
              </span>
            </div>

            {/* Step 2 Simulated Card */}
            <div className="flex-1 flex align-items-center justify-content-center p-2">
              <div
                className="w-full bg-white border-round-xl border-1 border-blue-500 overflow-hidden shadow-3 flex flex-column justify-content-between select-none"
                style={{
                  maxWidth: '300px',
                  boxShadow: '0 4px 14px 0 rgba(37, 99, 235, 0.15)',
                }}
              >
                {/* Top Image Banner */}
                <div
                  className="w-full relative overflow-hidden flex align-items-center justify-content-center"
                  style={{ height: '185px', backgroundColor: '#f8fafc' }}
                >
                  {previewDataUrl ? (
                    <img
                      src={previewDataUrl}
                      alt="Preview Card"
                      style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        objectPosition: 'center',
                        display: 'block',
                      }}
                    />
                  ) : (
                    <div className="flex flex-column align-items-center text-400 gap-1">
                      <i className="pi pi-image text-3xl opacity-60" />
                    </div>
                  )}

                  {/* Top Right Checkbox Simulation */}
                  <div className="absolute top-0 right-0 m-2 z-2 bg-white border-round-lg shadow-2 px-2 py-1 flex align-items-center justify-content-center">
                    <i className="pi pi-check text-blue-600 text-xs font-bold" />
                  </div>
                </div>

                {/* Card Content Body */}
                <div className="p-3 flex flex-column gap-1 bg-white">
                  <div className="flex align-items-center gap-1 flex-wrap mb-1">
                    <Tag value={previewCategory || 'LAYANAN'} severity="info" className="text-xs font-medium" />
                    <Tag value="Tidak Perlu Konsul" severity="success" className="text-[10px] font-bold" />
                  </div>

                  <h4 className="text-sm font-bold text-900 m-0 line-height-2">
                    {previewTitle || 'Nama Layanan'}
                  </h4>

                  <div className="pt-2 mt-2 border-top-1 surface-border flex align-items-center justify-content-between">
                    <span className="text-xs text-600 flex align-items-center gap-1 font-medium">
                      <i className="pi pi-clock text-xs text-500" /> {previewDuration} Menit
                    </span>
                    <span className="text-sm font-extrabold text-blue-600">
                      {formatRupiah(previewPrice || 0)}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Dialog>
  );
};
