/// Konstanta API untuk koneksi ke backend
/// Menerapkan prinsip OOP: Encapsulation - menyembunyikan detail konfigurasi
class ApiConstants {
  // Private constructor untuk mencegah instansiasi
  ApiConstants._();

  /// Base URL backend server.
  /// Default di-set ke `http://10.0.2.2:3000/api` agar bekerja pada
  /// Android emulator di Windows. Untuk mengganti saat build/run,
  /// jalankan Flutter dengan:
  ///
  /// flutter run --dart-define=API_BASE_URL="http://localhost:3000/api"
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Default ke localhost agar berjalan pada web/desktop/iOS simulator.
    // Jika menjalankan pada Android emulator, override dengan:
    // --dart-define=API_BASE_URL="http://10.0.2.2:3000/api"
    defaultValue: 'http://backendrkcafee-production-ec5d.up.railway.app/api',
  );

  /// Timeout duration dalam detik
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // ==================== AUTH ENDPOINTS ====================
  static const String login = '/login';
  static const String users = '/users';

  // ==================== MENU ENDPOINTS ====================
  static const String menus = '/menus';
  static const String menusBulk = '/menus/bulk';

  // ==================== ORDER ENDPOINTS ====================
  static const String orders = '/orders';
  static const String kitchenOrders = '/kitchen/orders';

  // ==================== BAHAN BAKU ENDPOINTS ====================
  static const String bahan = '/bahan';

  // ==================== BOM ENDPOINTS ====================
  static const String bom = '/bom';

  // ==================== RIWAYAT STOK ENDPOINTS ====================
  static const String riwayatStok = '/riwayat-stok';
}

