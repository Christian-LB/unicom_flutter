import 'package:flutter/material.dart';

class AppColors {
  // Primary colors (matching your emerald theme)
  static const Color primary = Color(0xFF059669); // emerald-600
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF10B981); // emerald-500
  static const Color primaryDark = Color(0xFF047857); // emerald-700
  
  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFF8FAFC); // slate-50
  static const Color mutedForeground = Color(0xFF64748B); // slate-500
  
  // Text colors
  static const Color foreground = Color(0xFF0F172A); // slate-900
  static const Color secondary = Color(0xFF475569); // slate-600
  
  // Status colors
  static const Color success = Color(0xFF059669); // emerald-600
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6); // blue-500
  
  // Border colors
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderLight = Color(0xFFF1F5F9); // slate-100
  
  // Shadow colors
  static const Color shadow = Color(0x1A000000); // black with 10% opacity
  
  // Rating colors
  static const Color rating = Color(0xFFFBBF24); // amber-400
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Surface colors for different states
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF8FAFC);
  static const Color surfacePressed = Color(0xFFF1F5F9);
  
  // Badge colors
  static const Color badgeSuccess = Color(0xFF059669);
  static const Color badgeError = Color(0xFFEF4444);
  static const Color badgeWarning = Color(0xFFF59E0B);
  static const Color badgeInfo = Color(0xFF3B82F6);
}
