import 'package:flutter/material.dart';
class AppColors {
  static const Color primary = Color(0xFF059669); 
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF10B981); 
  static const Color primaryDark = Color(0xFF047857); 
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFF8FAFC); 
  static const Color mutedForeground = Color(0xFF64748B); 
  static const Color foreground = Color(0xFF0F172A); 
  static const Color secondary = Color(0xFF475569); 
  static const Color success = Color(0xFF059669); 
  static const Color warning = Color(0xFFF59E0B); 
  static const Color error = Color(0xFFEF4444); 
  static const Color info = Color(0xFF3B82F6); 
  static const Color border = Color(0xFFE2E8F0); 
  static const Color borderLight = Color(0xFFF1F5F9); 
  static const Color shadow = Color(0x1A000000); 
  static const Color rating = Color(0xFFFBBF24); 
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF8FAFC);
  static const Color surfacePressed = Color(0xFFF1F5F9);
  static const Color badgeSuccess = Color(0xFF059669);
  static const Color badgeError = Color(0xFFEF4444);
  static const Color badgeWarning = Color(0xFFF59E0B);
  static const Color badgeInfo = Color(0xFF3B82F6);
}
