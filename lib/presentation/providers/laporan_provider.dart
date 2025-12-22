import 'package:flutter/foundation.dart';
import '../../data/datasources/laporan_api_service.dart';
import '../../data/models/laporan_model.dart';

/// Provider untuk state management Laporan Penjualan
/// Menerapkan prinsip OOP:
/// - Encapsulation: state internal di-protect
/// - Aggregation: menggunakan LaporanPenjualanResponse untuk ringkasan
class LaporanProvider extends ChangeNotifier {
  final LaporanApiService _laporanService;

  LaporanPenjualanResponse? _laporan;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;

  LaporanProvider(this._laporanService);

  // ==================== GETTERS ====================
  LaporanPenjualanResponse? get laporan => _laporan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Computed properties dari laporan
  int get totalOrder => _laporan?.totalOrder ?? 0;
  double get totalOmzet => _laporan?.totalOmzet ?? 0;
  int get totalItem => _laporan?.totalItem ?? 0;
  List<MenuTerlaris> get menuTerlaris => _laporan?.menuTerlaris ?? [];
  
  String get totalOmzetFormatted => _laporan?.totalOmzetFormatted ?? 'Rp 0';
  String get rataRataPerOrderFormatted => _laporan?.rataRataPerOrderFormatted ?? 'Rp 0';
  String get periodeFormatted => _laporan?.periodeFormatted ?? '-';

  // ==================== METHODS ====================

  /// Fetch laporan penjualan
  Future<void> fetchLaporan({DateTime? startDate, DateTime? endDate}) async {
    _setLoading(true);
    _clearError();
    _startDate = startDate;
    _endDate = endDate;

    try {
      final laporan = await _laporanService.getLaporanPenjualan(
        startDate: startDate,
        endDate: endDate,
      );
      
      _laporan = laporan;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Fetch laporan hari ini
  Future<void> fetchLaporanHariIni() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    await fetchLaporan(startDate: startOfDay, endDate: endOfDay);
  }

  /// Fetch laporan minggu ini
  Future<void> fetchLaporanMingguIni() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    await fetchLaporan(startDate: startDate, endDate: now);
  }

  /// Fetch laporan bulan ini
  Future<void> fetchLaporanBulanIni() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    await fetchLaporan(startDate: startDate, endDate: now);
  }

  /// Set date range dan fetch
  Future<void> setDateRange(DateTime start, DateTime end) async {
    await fetchLaporan(startDate: start, endDate: end);
  }

  /// Clear laporan
  void clearLaporan() {
    _laporan = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // ==================== PRIVATE METHODS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
