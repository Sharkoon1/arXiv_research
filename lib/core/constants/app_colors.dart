import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand — indigo/violet gradient
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF8B5CF6);

  // Backgrounds
  static const Color backgroundDark = Color(0xFF0F0F14);
  static const Color surfaceDark = Color(0xFF1A1A24);
  static const Color cardDark = Color(0xFF22223A);

  static const Color backgroundLight = Color(0xFFF5F5FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF9898B8);
  static const Color textMuted = Color(0xFF5A5A7A);

  static const Color textPrimaryLight = Color(0xFF16162A);
  static const Color textSecondaryLight = Color(0xFF6B6B8A);

  // Accents
  static const Color newBadge = Color(0xFF6366F1);
  static const Color readBadge = Color(0xFF3A3A54);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // Gradient for fetch button
  static const LinearGradient fetchGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category pill colors
  static const Map<String, Color> categoryColors = {
    'cs.AI': Color(0xFF6366F1),
    'cs.LG': Color(0xFF8B5CF6),
    'cs.CV': Color(0xFF06B6D4),
    'cs.CL': Color(0xFF10B981),
    'cs.NE': Color(0xFFF59E0B),
    'stat.ML': Color(0xFFEC4899),
  };
}
