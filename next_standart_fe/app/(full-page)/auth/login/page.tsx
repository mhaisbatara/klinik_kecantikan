'use client';

import { useFormik } from 'formik';
import { useRouter } from 'next/navigation';
import { useRef, useState } from 'react';
import { showError, showSuccess, showWarning } from '../../../../lib/tools/generalTools';
import { signIn } from 'next-auth/react';
import { Toast } from 'primereact/toast';
import axios from 'axios';
import { LoginFormik, LoginState } from './component/interfaces';

export default function LoginPage() {
  const router = useRouter();
  const toast = useRef<Toast>(null);

  const [showPassword, setShowPassword] = useState(false);
  const [lang, setLang] = useState<'ID' | 'EN'>('ID');
  const [state, setState] = useState<LoginState>({
    load: false,
    googleLoad: false,
  });

  const formik = useFormik<LoginFormik>({
    initialValues: {
      username: '',
      password: '',
      remember_me: true,
    },
    validate: (data: LoginFormik) => {
      const errors = {} as Record<keyof LoginFormik, string>;
      if (!data.username) {
        errors.username = 'Username wajib diisi';
      }
      if (!data.password) {
        errors.password = 'Password wajib diisi';
      }
      return errors;
    },
    onSubmit: (data) => {
      handleSubmit(data);
    },
  });

  const handleSubmit = async (data: LoginFormik) => {
    setState((p) => ({ ...p, load: true }));
    try {
      const { data: vaLogin } = await axios.post('/api/auth/login', {
        username: data.username,
        password: data.password,
        remember_me: data.remember_me ? '1' : '0',
      });

      const nAuth = await signIn('credentials', {
        userData: JSON.stringify(vaLogin.data),
        redirect: false,
      });

      if (nAuth?.error) {
        showError(toast, 'Username atau kata sandi tidak sesuai.');
      } else {
        showSuccess(toast, 'Login Berhasil! Mengalihkan ke Dashboard...');
        setTimeout(() => router.push('/dashboard'), 400);
      }
    } catch (error: any) {
      const e = error?.response?.data || error;
      showError(toast, e.message || 'Gagal masuk ke sistem, periksa kembali username dan password Anda');
    } finally {
      setState((p) => ({ ...p, load: false }));
    }
  };

  const handleForgotPassword = (e: React.MouseEvent) => {
    e.preventDefault();
    showWarning(
      toast,
      'Lupa kata sandi? Silakan hubungi Administrator IT atau Super Admin klinik untuk mereset kata sandi akun Anda.'
    );
  };

  return (
    <>
      <Toast ref={toast} position="top-right" />

      {/* Google Fonts & Material Symbols */}
      <link rel="preconnect" href="https://fonts.googleapis.com" />
      <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
      <link
        href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,600&family=Plus+Jakarta+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&display=swap"
        rel="stylesheet"
      />
      <link
        href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap"
        rel="stylesheet"
      />

      <style>{`
        /* Reset & Root Variables */
        * {
          box-sizing: border-box;
        }

        .kk-page-wrapper {
          font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          background-color: #e9fef3;
          color: #0d1f18;
          min-height: 100vh;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          position: relative;
          width: 100%;
          overflow-x: hidden;
        }

        .font-serif-display {
          font-family: 'Playfair Display', Georgia, serif;
        }

        .material-symbols-outlined {
          font-family: 'Material Symbols Outlined', sans-serif;
          font-weight: normal;
          font-style: normal;
          font-size: 20px;
          line-height: 1;
          letter-spacing: normal;
          text-transform: none;
          display: inline-block;
          white-space: nowrap;
          word-wrap: normal;
          direction: ltr;
          -webkit-font-smoothing: antialiased;
        }

        .material-symbols-filled {
          font-variation-settings: 'FILL' 1;
        }

        /* ── HEADER STYLES ── */
        .kk-header {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          width: 100%;
          height: 76px;
          z-index: 50;
          background: rgba(233, 254, 243, 0.92);
          backdrop-filter: blur(16px);
          -webkit-backdrop-filter: blur(16px);
          border-bottom: 1px solid rgba(216, 237, 226, 0.8);
          box-shadow: 0 1px 12px rgba(31, 95, 71, 0.04);
          display: flex;
          align-items: center;
        }

        .kk-header-inner {
          width: 100%;
          max-width: 1240px;
          margin: 0 auto;
          padding: 0 24px;
          display: flex;
          align-items: center;
          justify-content: space-between;
        }

        .kk-brand-logo {
          display: flex;
          align-items: center;
          gap: 12px;
          cursor: pointer;
          text-decoration: none;
        }

        .kk-logo-box {
          width: 42px;
          height: 42px;
          border-radius: 14px;
          background: linear-gradient(135deg, #004731 0%, #2b6953 100%);
          display: flex;
          align-items: center;
          justify-content: center;
          color: #ffffff;
          box-shadow: 0 4px 12px rgba(0, 71, 49, 0.2);
          transition: transform 0.2s ease;
        }

        .kk-brand-logo:hover .kk-logo-box {
          transform: scale(1.04);
        }

        .kk-brand-text {
          display: flex;
          flex-direction: column;
        }

        .kk-brand-title {
          font-size: 17px;
          font-weight: 700;
          color: #004731;
          line-height: 1.15;
          letter-spacing: -0.2px;
        }

        .kk-brand-subtitle {
          font-size: 10px;
          font-weight: 700;
          color: #404944;
          letter-spacing: 0.8px;
          text-transform: uppercase;
          margin-top: 2px;
        }

        .kk-header-right {
          display: flex;
          align-items: center;
          gap: 14px;
        }

        .kk-lang-toggle {
          display: flex;
          align-items: center;
          background: #d8ede2;
          border-radius: 999px;
          padding: 3px;
          border: 1px solid #def3e8;
        }

        .kk-lang-btn {
          border: none;
          padding: 4px 12px;
          border-radius: 999px;
          font-size: 12px;
          font-weight: 700;
          cursor: pointer;
          background: transparent;
          color: #404944;
          transition: all 0.2s;
        }

        .kk-lang-btn.active {
          background: #ffffff;
          color: #004731;
          box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
        }

        .kk-hotline-btn {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          background: #e3f9ed;
          color: #004731;
          padding: 8px 16px;
          border-radius: 999px;
          font-size: 13px;
          font-weight: 600;
          text-decoration: none;
          border: 1px solid rgba(210, 231, 220, 0.8);
          transition: background 0.2s;
        }

        .kk-hotline-btn:hover {
          background: #d8ede2;
        }

        .kk-avatar-circle {
          width: 38px;
          height: 38px;
          border-radius: 50%;
          background: #004731;
          color: #ffffff;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        /* ── MAIN CONTENT & GRID ── */
        .kk-main {
          flex: 1;
          padding-top: 104px;
          padding-bottom: 48px;
          display: flex;
          flex-direction: column;
          justify-content: center;
          width: 100%;
        }

        .kk-container {
          width: 100%;
          max-width: 1240px;
          margin: 0 auto;
          padding: 0 24px;
        }

        .kk-grid {
          display: grid;
          grid-template-columns: 1.35fr 1fr;
          gap: 32px;
          align-items: stretch;
        }

        @media (max-width: 1024px) {
          .kk-grid {
            grid-template-columns: 1fr;
          }
          .kk-header-inner {
            padding: 0 16px;
          }
          .kk-container {
            padding: 0 16px;
          }
        }

        /* ── LEFT SHOWCASE PANEL ── */
        .kk-left-card {
          background: linear-gradient(180deg, #013525 0%, #004731 55%, #04281c 100%);
          border-radius: 28px;
          border: 1px solid rgba(31, 95, 71, 0.5);
          box-shadow: 0 20px 48px rgba(0, 33, 21, 0.28);
          position: relative;
          overflow: hidden;
          padding: 38px 36px;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          min-height: 640px;
        }

        /* Ambient Glows */
        .kk-glow-top {
          position: absolute;
          right: -80px;
          top: -80px;
          width: 320px;
          height: 320px;
          border-radius: 50%;
          background: rgba(176, 240, 209, 0.16);
          filter: blur(60px);
          pointer-events: none;
        }

        .kk-glow-bottom {
          position: absolute;
          left: -80px;
          bottom: -40px;
          width: 300px;
          height: 300px;
          border-radius: 50%;
          background: rgba(43, 105, 83, 0.25);
          filter: blur(60px);
          pointer-events: none;
        }

        /* Background Pattern */
        .kk-dot-pattern {
          position: absolute;
          inset: 0;
          width: 100%;
          height: 100%;
          opacity: 0.2;
          pointer-events: none;
        }

        .kk-tag-pill {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          padding: 6px 14px;
          background: rgba(255, 255, 255, 0.1);
          backdrop-filter: blur(8px);
          border: 1px solid rgba(255, 255, 255, 0.12);
          border-radius: 999px;
          margin-bottom: 16px;
        }

        .kk-pulsing-dot {
          width: 7px;
          height: 7px;
          border-radius: 50%;
          background: #b0f0d1;
          box-shadow: 0 0 8px #b0f0d1;
          animation: pulseAnim 2s infinite ease-in-out;
        }

        @keyframes pulseAnim {
          0%, 100% { transform: scale(1); opacity: 1; }
          50% { transform: scale(0.85); opacity: 0.45; }
        }

        .kk-tag-text {
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 1.5px;
          color: #b0f0d1;
          text-transform: uppercase;
        }

        .kk-headline {
          font-family: 'Playfair Display', Georgia, serif;
          font-size: 38px;
          font-weight: 700;
          color: #ffffff;
          line-height: 1.22;
          margin: 0 0 24px 0;
          letter-spacing: -0.4px;
        }

        .kk-headline-highlight {
          color: #b0f0d1;
          text-decoration: underline;
          text-decoration-style: wavy;
          text-decoration-color: rgba(176, 240, 209, 0.45);
          text-underline-offset: 8px;
        }

        /* Floating Card Stack */
        .kk-floating-stack {
          position: relative;
          z-index: 10;
          margin: 8px 0 20px 0;
        }

        .kk-badge-verified-wrap {
          display: flex;
          justify-content: flex-end;
          margin-bottom: -14px;
          margin-right: 18px;
          position: relative;
          z-index: 20;
        }

        .kk-badge-verified {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          padding: 6px 14px;
          background: #ffffff;
          color: #004731;
          border-radius: 999px;
          font-size: 12px;
          font-weight: 600;
          box-shadow: 0 8px 24px rgba(0, 0, 0, 0.16);
          border: 1px solid #d8ede2;
        }

        .kk-card-katalog {
          background: rgba(255, 255, 255, 0.96);
          backdrop-filter: blur(16px);
          -webkit-backdrop-filter: blur(16px);
          border-radius: 20px;
          padding: 18px 22px;
          box-shadow: 0 16px 36px rgba(0, 0, 0, 0.18);
          border: 1px solid rgba(255, 255, 255, 0.6);
        }

        .kk-katalog-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          border-bottom: 1px solid #def3e8;
          padding-bottom: 12px;
          margin-bottom: 12px;
        }

        .kk-katalog-left {
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .kk-katalog-icon {
          width: 34px;
          height: 34px;
          border-radius: 10px;
          background: #b0f0d3;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #004731;
        }

        .kk-katalog-title {
          font-size: 15px;
          font-weight: 700;
          color: #0d1f18;
          margin: 0;
          line-height: 1.2;
        }

        .kk-katalog-desc {
          font-size: 11.5px;
          color: #404944;
          margin: 2px 0 0 0;
        }

        .kk-badge-reservasi {
          font-size: 11px;
          font-weight: 600;
          padding: 3px 10px;
          background: #def3e8;
          color: #004731;
          border-radius: 999px;
        }

        .kk-item-row {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 10px 14px;
          border-radius: 12px;
          background: #f3fdf8;
          border: 1px solid #d2e7dc;
          margin-bottom: 8px;
        }

        .kk-item-row:last-child {
          margin-bottom: 0;
        }

        .kk-item-left {
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .kk-item-icon-box {
          width: 36px;
          height: 36px;
          border-radius: 10px;
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .kk-item-title {
          font-size: 13px;
          font-weight: 600;
          color: #0d1f18;
          margin: 0;
        }

        .kk-item-subtitle {
          font-size: 11px;
          color: #404944;
          margin: 1px 0 0 0;
        }

        .kk-status-pill {
          display: inline-flex;
          align-items: center;
          gap: 5px;
          padding: 3px 10px;
          border-radius: 999px;
          font-size: 11px;
          font-weight: 700;
          background: #b0f0d3;
          color: #004731;
        }

        .kk-status-dot {
          width: 6px;
          height: 6px;
          border-radius: 50%;
          background: #004731;
        }

        /* 2 Subcards */
        .kk-subcards-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 12px;
          margin-top: 12px;
        }

        .kk-subcard {
          background: rgba(255, 255, 255, 0.94);
          backdrop-filter: blur(12px);
          border-radius: 14px;
          padding: 12px 14px;
          border: 1px solid rgba(255, 255, 255, 0.5);
          box-shadow: 0 6px 18px rgba(0, 0, 0, 0.1);
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .kk-subcard-icon {
          width: 36px;
          height: 36px;
          border-radius: 10px;
          background: #def3e8;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
        }

        .kk-subcard-tag {
          font-size: 10px;
          font-weight: 700;
          letter-spacing: 0.8px;
          text-transform: uppercase;
          display: block;
        }

        .kk-subcard-title {
          font-size: 12px;
          font-weight: 600;
          color: #0d1f18;
          margin-top: 1px;
          display: block;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        /* Bottom Narrative Banner */
        .kk-narrative-banner {
          background: rgba(0, 0, 0, 0.32);
          backdrop-filter: blur(14px);
          -webkit-backdrop-filter: blur(14px);
          border: 1px solid rgba(255, 255, 255, 0.12);
          border-radius: 18px;
          padding: 16px 18px;
          color: #ffffff;
          position: relative;
          z-index: 10;
        }

        .kk-banner-top {
          display: flex;
          align-items: center;
          gap: 12px;
          border-bottom: 1px solid rgba(255, 255, 255, 0.1);
          padding-bottom: 12px;
          margin-bottom: 12px;
        }

        .kk-shield-icon {
          width: 38px;
          height: 38px;
          border-radius: 12px;
          background: rgba(176, 240, 209, 0.18);
          border: 1px solid rgba(176, 240, 209, 0.3);
          display: flex;
          align-items: center;
          justify-content: center;
          color: #b0f0d1;
          flex-shrink: 0;
        }

        .kk-banner-heading-wrap {
          display: flex;
          align-items: center;
          gap: 8px;
          flex-wrap: wrap;
        }

        .kk-banner-heading {
          font-size: 14px;
          font-weight: 700;
          color: #ffffff;
        }

        .kk-spesialis-badge {
          font-size: 10px;
          font-weight: 600;
          background: rgba(176, 240, 209, 0.2);
          color: #b0f0d1;
          padding: 2px 8px;
          border-radius: 999px;
          border: 1px solid rgba(176, 240, 209, 0.3);
        }

        .kk-banner-sub {
          font-size: 11.5px;
          color: rgba(255, 255, 255, 0.82);
          margin: 2px 0 0 0;
        }

        .kk-banner-grid {
          display: grid;
          grid-template-columns: 1fr 1fr 1fr;
          gap: 8px;
        }

        .kk-banner-mini-card {
          background: rgba(255, 255, 255, 0.06);
          border: 1px solid rgba(255, 255, 255, 0.08);
          border-radius: 10px;
          padding: 8px 10px;
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .kk-mini-card-title {
          font-size: 10px;
          font-weight: 700;
          color: #ffffff;
          line-height: 1.2;
          display: block;
        }

        .kk-mini-card-sub {
          font-size: 9.5px;
          color: rgba(255, 255, 255, 0.7);
          display: block;
          margin-top: 2px;
        }

        /* ── RIGHT AUTHENTICATION PANEL ── */
        .kk-right-card {
          background: #ffffff;
          border-radius: 28px;
          padding: 44px 40px;
          box-shadow: 0 16px 40px rgba(0, 71, 49, 0.07);
          border: 1px solid rgba(216, 237, 226, 0.85);
          display: flex;
          flex-direction: column;
          justify-content: center;
        }

        @media (max-width: 640px) {
          .kk-right-card {
            padding: 32px 20px;
          }
          .kk-left-card {
            padding: 28px 20px;
          }
        }

        .kk-auth-brand-center {
          display: flex;
          flex-direction: column;
          align-items: center;
          text-align: center;
          margin-bottom: 20px;
        }

        .kk-auth-icon-box {
          width: 62px;
          height: 62px;
          border-radius: 18px;
          background: linear-gradient(135deg, #004731 0%, #2b6953 100%);
          display: flex;
          align-items: center;
          justify-content: center;
          color: #ffffff;
          box-shadow: 0 6px 16px rgba(0, 71, 49, 0.22);
          margin-bottom: 12px;
        }

        .kk-auth-portal-title {
          font-size: 20px;
          font-weight: 700;
          color: #004731;
          letter-spacing: -0.3px;
        }

        .kk-auth-portal-sub {
          font-size: 11px;
          font-weight: 700;
          color: #404944;
          letter-spacing: 1px;
          text-transform: uppercase;
          margin-top: 3px;
        }

        .kk-auth-welcome {
          font-family: 'Playfair Display', Georgia, serif;
          font-size: 27px;
          font-weight: 700;
          color: #0d1f18;
          text-align: center;
          margin: 0 0 6px 0;
        }

        .kk-auth-welcome-sub {
          font-size: 13.5px;
          color: #404944;
          text-align: center;
          margin: 0 0 24px 0;
        }

        .kk-form-group {
          margin-bottom: 18px;
          text-align: left;
        }

        .kk-label {
          display: block;
          font-size: 13px;
          font-weight: 600;
          color: #0d1f18;
          margin-bottom: 7px;
        }

        .kk-input-wrap {
          position: relative;
          display: flex;
          align-items: center;
        }

        .kk-input-icon {
          position: absolute;
          left: 14px;
          color: #2b6953;
          pointer-events: none;
          font-size: 20px;
        }

        .kk-input {
          width: 100%;
          height: 48px;
          padding-left: 44px;
          padding-right: 16px;
          background: #f4fcf7;
          border: 1px solid #d2e7dc;
          border-radius: 12px;
          font-size: 14px;
          font-family: inherit;
          color: #0d1f18;
          outline: none;
          transition: all 0.2s ease;
        }

        .kk-input.has-eye {
          padding-right: 44px;
        }

        .kk-input:focus {
          background: #ffffff;
          border-color: #2b6953;
          box-shadow: 0 0 0 3px rgba(43, 105, 83, 0.16);
        }

        .kk-input::placeholder {
          color: #707973;
        }

        .kk-eye-btn {
          position: absolute;
          right: 12px;
          background: none;
          border: none;
          cursor: pointer;
          color: #707973;
          padding: 6px;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 6px;
          transition: color 0.2s;
        }

        .kk-eye-btn:hover {
          color: #004731;
        }

        .kk-error-msg {
          font-size: 12px;
          color: #ba1a1a;
          margin-top: 5px;
          font-weight: 500;
        }

        .kk-form-options {
          display: flex;
          align-items: center;
          justify-content: space-between;
          margin: 12px 0 20px 0;
        }

        .kk-remember-label {
          display: flex;
          align-items: center;
          gap: 8px;
          cursor: pointer;
          font-size: 13.5px;
          color: #0d1f18;
          user-select: none;
        }

        .kk-remember-checkbox {
          width: 16px;
          height: 16px;
          accent-color: #004731;
          cursor: pointer;
        }

        .kk-forgot-link {
          font-size: 12.5px;
          font-weight: 600;
          color: #2b6953;
          text-decoration: none;
          cursor: pointer;
        }

        .kk-forgot-link:hover {
          color: #004731;
          text-decoration: underline;
        }

        .kk-submit-btn {
          width: 100%;
          height: 48px;
          border-radius: 999px;
          background: #004731;
          color: #ffffff;
          font-size: 15px;
          font-weight: 700;
          font-family: inherit;
          border: none;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          box-shadow: 0 4px 14px rgba(0, 71, 49, 0.22);
          transition: all 0.2s ease;
        }

        .kk-submit-btn:hover {
          background: #1f5f47;
          box-shadow: 0 6px 18px rgba(0, 71, 49, 0.32);
          transform: translateY(-1px);
        }

        .kk-submit-btn:active {
          transform: translateY(0);
        }

        .kk-submit-btn:disabled {
          opacity: 0.75;
          cursor: not-allowed;
          transform: none;
        }

        .kk-security-badges {
          margin-top: 24px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 22px;
          color: #707973;
          font-size: 11.5px;
        }

        .kk-badge-item {
          display: inline-flex;
          align-items: center;
          gap: 6px;
        }

        /* ── FOOTER STYLES ── */
        .kk-footer {
          width: 100%;
          background: rgba(227, 249, 237, 0.85);
          backdrop-filter: blur(8px);
          border-top: 1px solid rgba(216, 237, 226, 0.8);
          padding: 16px 24px;
          text-align: center;
        }

        .kk-footer-text {
          font-size: 12px;
          color: #404944;
          margin: 0;
        }
      `}</style>

      <div className="kk-page-wrapper">
        {/* ── TOP HEADER / NAV BAR ── */}
        <header className="kk-header">
          <div className="kk-header-inner">
            {/* Logo and Brand */}
            <div className="kk-brand-logo" onClick={() => router.push('/')}>
              <div className="kk-logo-box">
                <span className="material-symbols-outlined" style={{ fontSize: '22px' }}>spa</span>
              </div>
              <div className="kk-brand-text">
                <span className="kk-brand-title">Klinik Kecantikan</span>
                <span className="kk-brand-subtitle">Aesthetic &amp; Wellness Hub</span>
              </div>
            </div>

            {/* Language & Contact Hotline & User Icon */}
            <div className="kk-header-right">
              {/* Language Switch */}
              <div className="kk-lang-toggle">
                <button
                  type="button"
                  onClick={() => setLang('ID')}
                  className={`kk-lang-btn ${lang === 'ID' ? 'active' : ''}`}
                >
                  ID
                </button>
                <button
                  type="button"
                  onClick={() => setLang('EN')}
                  className={`kk-lang-btn ${lang === 'EN' ? 'active' : ''}`}
                >
                  EN
                </button>
              </div>

              {/* Hotline Button */}
              <a href="tel:1500828" className="kk-hotline-btn">
                <span className="material-symbols-outlined" style={{ color: '#2b6953', fontSize: '18px' }}>
                  support_agent
                </span>
                <span style={{ color: '#404944', fontWeight: 'normal' }}>Hotline:</span>
                <span>1500-828</span>
              </a>

              {/* User Avatar Circle */}
              <div className="kk-avatar-circle">
                <span className="material-symbols-outlined" style={{ fontSize: '18px' }}>person</span>
              </div>
            </div>
          </div>
        </header>

        {/* ── MAIN VIEWPORT ── */}
        <main className="kk-main">
          <div className="kk-container">
            <div className="kk-grid">
              {/* ── LEFT COLUMN: Showcase & Stacked Floating Cards ── */}
              <div className="kk-left-card">
                {/* Background Ambient Glows */}
                <div className="kk-glow-top"></div>
                <div className="kk-glow-bottom"></div>

                {/* Dot Matrix SVG Pattern */}
                <svg className="kk-dot-pattern" xmlns="http://www.w3.org/2000/svg">
                  <defs>
                    <pattern id="kk-dots" width="24" height="24" patternUnits="userSpaceOnUse">
                      <circle cx="2" cy="2" r="1.3" fill="#b0f0d1"></circle>
                    </pattern>
                  </defs>
                  <rect width="100%" height="100%" fill="url(#kk-dots)"></rect>
                </svg>

                {/* Top Brand Tag & Headline */}
                <div style={{ position: 'relative', zIndex: 10 }}>
                  <div className="kk-tag-pill">
                    <span className="kk-pulsing-dot"></span>
                    <span className="kk-tag-text">KLINIK KECANTIKAN</span>
                  </div>

                  <h1 className="kk-headline">
                    Eksplorasi Perawatan <br />
                    <span className="kk-headline-highlight">Estetika Terbaik</span>
                  </h1>
                </div>

                {/* Dynamic Showcase Floating Stack */}
                <div className="kk-floating-stack">
                  {/* Floating Top Right Badge */}
                  <div className="kk-badge-verified-wrap">
                    <div className="kk-badge-verified">
                      <span className="material-symbols-outlined material-symbols-filled" style={{ color: '#004731', fontSize: '16px' }}>
                        verified
                      </span>
                      <span>Terverifikasi</span>
                      <span style={{ color: '#bfc9c2' }}>|</span>
                      <span style={{ color: '#2b6953', display: 'inline-flex', alignItems: 'center', gap: '2px' }}>
                        <span>Lihat Semua</span>
                        <span className="material-symbols-outlined" style={{ fontSize: '14px' }}>arrow_forward</span>
                      </span>
                    </div>
                  </div>

                  {/* Main Floating Card: Katalog Perawatan */}
                  <div className="kk-card-katalog">
                    <div className="kk-katalog-header">
                      <div className="kk-katalog-left">
                        <div className="kk-katalog-icon">
                          <span className="material-symbols-outlined" style={{ fontSize: '19px' }}>spa</span>
                        </div>
                        <div>
                          <h2 className="kk-katalog-title">Katalog Perawatan</h2>
                          <p className="kk-katalog-desc">Solusi kecantikan &amp; estetika terpadu</p>
                        </div>
                      </div>
                      <span className="kk-badge-reservasi">Siap Reservasi</span>
                    </div>

                    <div>
                      {/* Item 1: Facial */}
                      <div className="kk-item-row">
                        <div className="kk-item-left">
                          <div className="kk-item-icon-box" style={{ background: 'rgba(176, 240, 209, 0.6)', color: '#004731' }}>
                            <span className="material-symbols-outlined" style={{ fontSize: '20px' }}>face</span>
                          </div>
                          <div>
                            <h3 className="kk-item-title">Facial &amp; Skin Rejuvenation</h3>
                            <p className="kk-item-subtitle">Dermatology Care</p>
                          </div>
                        </div>
                        <span className="kk-status-pill">
                          <span className="kk-status-dot"></span>
                          Aktif
                        </span>
                      </div>

                      {/* Item 2: Laser */}
                      <div className="kk-item-row">
                        <div className="kk-item-left">
                          <div className="kk-item-icon-box" style={{ background: '#fedeb2', color: '#4e3a1b' }}>
                            <span className="material-symbols-outlined" style={{ fontSize: '20px' }}>auto_awesome</span>
                          </div>
                          <div>
                            <h3 className="kk-item-title">Laser &amp; Anti-Aging</h3>
                            <p className="kk-item-subtitle">Teknologi Medis Modern</p>
                          </div>
                        </div>
                        <span className="kk-status-pill">
                          <span className="kk-status-dot"></span>
                          Aktif
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Subcards: Konsultasi & Resep */}
                  <div className="kk-subcards-grid">
                    <div className="kk-subcard">
                      <div className="kk-subcard-icon">
                        <span className="material-symbols-outlined" style={{ color: '#004731', fontSize: '20px' }}>
                          medical_services
                        </span>
                      </div>
                      <div style={{ minWidth: 0 }}>
                        <span className="kk-subcard-tag" style={{ color: '#2b6953' }}>KONSULTASI DOKTER</span>
                        <span className="kk-subcard-title">Dokter Spesialis</span>
                      </div>
                    </div>

                    <div className="kk-subcard">
                      <div className="kk-subcard-icon">
                        <span className="material-symbols-outlined" style={{ color: '#4e3a1b', fontSize: '20px' }}>
                          prescriptions
                        </span>
                      </div>
                      <div style={{ minWidth: 0 }}>
                        <span className="kk-subcard-tag" style={{ color: '#4e3a1b' }}>RESEP &amp; PRODUK</span>
                        <span className="kk-subcard-title">BPOM &amp; Halal Certified</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Bottom Narrative Banner */}
                <div className="kk-narrative-banner">
                  <div className="kk-banner-top">
                    <div className="kk-shield-icon">
                      <span className="material-symbols-outlined material-symbols-filled" style={{ fontSize: '22px' }}>
                        verified_user
                      </span>
                    </div>
                    <div>
                      <div className="kk-banner-heading-wrap">
                        <span className="kk-banner-heading">10.000+ Pasien Terpercaya</span>
                        <span className="kk-spesialis-badge">Spesialis Sp.KK/Sp.DVE</span>
                      </div>
                      <p className="kk-banner-sub">
                        Ditangani dokter spesialis berlisensi resmi &amp; teknologi bersertifikasi FDA
                      </p>
                    </div>
                  </div>

                  <div className="kk-banner-grid">
                    <div className="kk-banner-mini-card">
                      <span className="material-symbols-outlined" style={{ color: '#b0f0d1', fontSize: '18px' }}>
                        clinical_notes
                      </span>
                      <div>
                        <span className="kk-mini-card-title">100% Medis</span>
                        <span className="kk-mini-card-sub">Dokter Berlisensi</span>
                      </div>
                    </div>

                    <div className="kk-banner-mini-card">
                      <span className="material-symbols-outlined" style={{ color: '#b0f0d1', fontSize: '18px' }}>
                        biomedical
                      </span>
                      <div>
                        <span className="kk-mini-card-title">Alat Canggih</span>
                        <span className="kk-mini-card-sub">FDA &amp; CE Approved</span>
                      </div>
                    </div>

                    <div className="kk-banner-mini-card">
                      <span className="material-symbols-outlined" style={{ color: '#b0f0d1', fontSize: '18px' }}>
                        sanitizer
                      </span>
                      <div>
                        <span className="kk-mini-card-title">Higienis &amp; Steril</span>
                        <span className="kk-mini-card-sub">Standar Medis RS</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* ── RIGHT COLUMN: Authentication Form ── */}
              <div className="kk-right-card">
                {/* Brand Center */}
                <div className="kk-auth-brand-center">
                  <div className="kk-auth-icon-box">
                    <span className="material-symbols-outlined" style={{ fontSize: '30px' }}>spa</span>
                  </div>
                  <span className="kk-auth-portal-title">Klinik Kecantikan</span>
                  <span className="kk-auth-portal-sub">Aesthetic &amp; Wellness Portal</span>
                </div>

                {/* Heading */}
                <h2 className="kk-auth-welcome">Selamat Datang</h2>
                <p className="kk-auth-welcome-sub">Silakan masuk ke akun Anda</p>

                {/* Form */}
                <form onSubmit={formik.handleSubmit}>
                  {/* Email / Username */}
                  <div className="kk-form-group">
                    <label className="kk-label" htmlFor="username-input">
                      Email / Username
                    </label>
                    <div className="kk-input-wrap">
                      <span className="material-symbols-outlined kk-input-icon">person</span>
                      <input
                        id="username-input"
                        name="username"
                        type="text"
                        required
                        value={formik.values.username}
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        placeholder="Masukkan username Anda"
                        className="kk-input"
                      />
                    </div>
                    {formik.touched.username && formik.errors.username && (
                      <div className="kk-error-msg">{formik.errors.username}</div>
                    )}
                  </div>

                  {/* Password */}
                  <div className="kk-form-group">
                    <label className="kk-label" htmlFor="password-input">
                      Password
                    </label>
                    <div className="kk-input-wrap">
                      <span className="material-symbols-outlined kk-input-icon">lock</span>
                      <input
                        id="password-input"
                        name="password"
                        type={showPassword ? 'text' : 'password'}
                        required
                        value={formik.values.password}
                        onChange={formik.handleChange}
                        onBlur={formik.handleBlur}
                        placeholder="Masukkan password Anda"
                        className="kk-input has-eye"
                      />
                      <button
                        type="button"
                        aria-label="Tampilkan atau sembunyikan kata sandi"
                        onClick={() => setShowPassword(!showPassword)}
                        className="kk-eye-btn"
                      >
                        <span className="material-symbols-outlined" style={{ fontSize: '20px' }}>
                          {showPassword ? 'visibility_off' : 'visibility'}
                        </span>
                      </button>
                    </div>
                    {formik.touched.password && formik.errors.password && (
                      <div className="kk-error-msg">{formik.errors.password}</div>
                    )}
                  </div>

                  {/* Options: Remember me & Forgot Password */}
                  <div className="kk-form-options">
                    <label className="kk-remember-label">
                      <input
                        type="checkbox"
                        name="remember_me"
                        checked={Boolean(formik.values.remember_me)}
                        onChange={formik.handleChange}
                        className="kk-remember-checkbox"
                      />
                      <span>Ingat Saya</span>
                    </label>

                    <a href="#" onClick={handleForgotPassword} className="kk-forgot-link">
                      Lupa password?
                    </a>
                  </div>

                  {/* Submit Button */}
                  <button type="submit" disabled={state.load} className="kk-submit-btn">
                    {state.load ? (
                      <>
                        <span className="material-symbols-outlined" style={{ animation: 'spin 1s linear infinite' }}>
                          progress_activity
                        </span>
                        <span>Memproses Masuk...</span>
                      </>
                    ) : (
                      <>
                        <span>Masuk</span>
                        <span className="material-symbols-outlined" style={{ fontSize: '18px' }}>
                          arrow_forward
                        </span>
                      </>
                    )}
                  </button>
                </form>

                {/* Security Badges */}
                <div className="kk-security-badges">
                  <span className="kk-badge-item">
                    <span className="material-symbols-outlined" style={{ color: '#004731', fontSize: '15px' }}>
                      lock
                    </span>
                    Enkripsi 256-bit SSL
                  </span>
                  <span className="kk-badge-item">
                    <span className="material-symbols-outlined" style={{ color: '#004731', fontSize: '15px' }}>
                      security
                    </span>
                    ISO 27001 Certified
                  </span>
                </div>
              </div>
            </div>
          </div>
        </main>

        {/* ── FOOTER ── */}
        <footer className="kk-footer">
          <p className="kk-footer-text">
            &copy; 2024 Klinik Kecantikan. Seluruh hak cipta dilindungi.
          </p>
        </footer>
      </div>
    </>
  );
}