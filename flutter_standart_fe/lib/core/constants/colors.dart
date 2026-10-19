import 'package:flutter/material.dart';

class AppColors {
  // Emerald Primary Palette (Identik dengan Web Klinik Kecantikan)
  static const Color primary = Color(0xFF10B981);       // Emerald 500
  static const Color primaryDark = Color(0xFF059669);   // Emerald 600
  static const Color primaryDeep = Color(0xFF047857);   // Emerald 700
  static const Color primaryDarkest = Color(0xFF064E3B);// Emerald 900
  
  // Background & Ambient
  static const Color bgMint = Color(0xFFF0FDF4);
  static const Color bgMintLight = Color(0xFFE6FAF2);
  static const Color bgMintSoft = Color(0xFFE1F7EC);
  static const Color white = Color(0xFFFFFFFF);
  
  // Form Inputs
  static const Color inputBg = Color(0xFFF8FDFA);
  static const Color inputBorder = Color(0xFFD1FAE5);
  static const Color inputBorderFocus = Color(0xFF10B981);
  
  // Text Colors
  static const Color textDark = Color(0xFF0D1F18);
  static const Color textMuted = Color(0xFF526359);
  static const Color textLight = Color(0xFF94A39B);
  
  // States
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF059669);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ambientGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0FDF4), Color(0xFFE1F7EC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
