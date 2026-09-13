import 'package:flutter/material.dart';

/// Centralized brand color palette for Freshly.
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color primary = Color(0xFF166534); // Deep Forest Green
  static const Color freshGreen = Color(0xFF22C55E); // Vibrant Leaf Green
  static const Color lightGreen = Color(0xFFF0FDF4); // Soft Tint Background
  static const Color background = Color(0xFFFAFAF7); // Warm Paper Canvas
  static const Color text = Color(0xFF172018); // Deep Organic Charcoal

  // Supporting & Neutral Palette
  static const Color textSecondary = Color(0xFF536758); // Muted Sage Slate
  static const Color textMuted = Color(0xFF8B9E90); // Light Olive Grey
  static const Color surface = Color(0xFFFFFFFF); // Pure Card White
  static const Color surfaceMuted = Color(0xFFF4F6F2); // Subtle Grey White
  static const Color border = Color(0xFFE5EBE4); // Crisp Light Border
  static const Color borderLight = Color(0xFFF1F5F0); // Subtle Border

  // Accent Badges & Badging
  static const Color accentMint = Color(0xFFDCFCE7); // Mint Badge
  static const Color accentGold = Color(0xFFF59E0B); // Amber Organic Accent

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF22C55E),
      Color(0xFF166534),
    ],
  );

  static const LinearGradient leafGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x2E22C55E),
      Color(0x00FAFAF7),
    ],
  );

  static const LinearGradient logoBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF0FDF4),
    ],
  );
}
