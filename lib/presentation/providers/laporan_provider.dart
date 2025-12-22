import 'package:flutter/foundation.dart';
import '../../data/datasources/laporan_api_service.dart';
import '../../data/models/laporan_model.dart';

/// Provider untuk state management Laporan Penjualan
/// Menerapkan prinsip OOP:
/// - Encapsulation: state internal di-protect
/// - Aggregation: menggunakan LaporanSummary untuk ringkasan
class LaporanProvider extends ChangeNotifier {
  final LaporanApiService _laporanService;

  LaporanSummary? _summary;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;

  LaporanProvider(this._laporanService);

  // ==================== GETTERS ====================
  LaporanSummary? get summary => _summary;
  List<LaporanItem> get items => _summary?.items ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Computed properties dari summary
  double get totalPendapatan => _summary?.totalPendapatan ?? 0;
  int get totalTransaksi => _summary?.totalTransaksi ?? 0;
  int get totalItemTerjual => _summary?.totalItemTerjual ?? 0;
  String get totalPendapatanFormatted => _summary?.totalPendapatanFormatted ?? 'Rp 0';
  String get rataRataFormatted => _summary?.rataRataFormatted ?? 'Rp 0';
  Map<String, int> get menuTerlaris => _summary?.menuTerlaris ?? {};

  // ==================== METHODS ====================

  /// Fetch laporan penjualan
  Future<void> fetchLaporan({DateTime? startDate, DateTime? endDate}) async {
    _setLoading(true);
    _clearError();
    _startDate = startDate;
    _endDate = endDate;

    try {
      final items = await _laporanService.getLaporanPenjualan(
        startDate: startDate,
        endDate: endDate,
      );
      
      _summary = LaporanSummary(
        items: items,
        startDate: startDate,
        endDate: endDate,
      );
      
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
    _summary = null;
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

