import 'package:flutter/material.dart';

/// Konstanta aplikasi untuk UI dan konfigurasi umum
/// Menerapkan prinsip OOP: Encapsulation
class AppConstants {
  AppConstants._();

  // ==================== APP INFO ====================
  static const String appName = 'RK Cafe';
  static const String appVersion = '1.0.0';

  // ==================== COLORS ====================
  static const Color primaryColor = Color(0xFF6F4E37); // Coffee Brown
  static const Color secondaryColor = Color(0xFFC4A484); // Light Coffee
  static const Color accentColor = Color(0xFFD4A574); // Cream
  static const Color backgroundColor = Color(0xFFF5F5DC); // Beige
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA726);

  // ==================== TEXT STYLES ====================
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeTitle = 32.0;

  // ==================== SPACING ====================
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // ==================== BORDER RADIUS ====================
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // ==================== ORDER STATUS ====================
  static const String statusBaru = 'BARU';
  static const String statusSedangDibuat = 'SEDANG DIBUAT';
  static const String statusSelesai = 'SELESAI';

  // ==================== USER ROLES ====================
  static const String roleOwner = 'OWNER';
  static const String roleKasir = 'KASIR';
  static const String roleBarista = 'BARISTA';

  // ==================== KATEGORI MENU ====================
  static const List<String> kategoriMenu = [
    'Semua',
    'Coffee',
    'Non Coffee',
    'Food',
    'Add On',
  ];
}

