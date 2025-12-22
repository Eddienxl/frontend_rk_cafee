import 'package:flutter/foundation.dart';
import '../../data/datasources/bahan_baku_api_service.dart';
import '../../data/models/bahan_baku_model.dart';

/// Provider untuk state management inventory/bahan baku
/// Menerapkan prinsip OOP:
/// - Encapsulation: state internal di-protect
/// - Computed Properties: filtered list dihitung otomatis
class InventoryProvider extends ChangeNotifier {
  final BahanBakuApiService _bahanService;

  List<BahanBakuModel> _bahanList = [];
  List<BahanBakuModel> _filteredList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterStatus = 'Semua'; // Semua, Rendah, Habis, Aman

  InventoryProvider(this._bahanService);

  // ==================== GETTERS ====================
  List<BahanBakuModel> get bahanList => _bahanList;
  List<BahanBakuModel> get filteredList => _filteredList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;

  /// Bahan dengan stok rendah
  List<BahanBakuModel> get bahanStokRendah => 
      _bahanList.where((b) => b.isStokRendah && !b.isStokHabis).toList();

  /// Bahan dengan stok habis
  List<BahanBakuModel> get bahanStokHabis => 
      _bahanList.where((b) => b.isStokHabis).toList();

  /// Total jenis bahan
  int get totalJenisBahan => _bahanList.length;

  /// Jumlah bahan perlu restock
  int get jumlahPerluRestock => 
      _bahanList.where((b) => b.isStokRendah).length;

  // ==================== METHODS ====================

  /// Fetch semua bahan baku dari API
  Future<void> fetchBahanBaku() async {
    _setLoading(true);
    _clearError();

    try {
      _bahanList = await _bahanService.getAllBahan();
      _applyFilter();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Search bahan baku
  void searchBahan(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Filter berdasarkan status stok
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilter();
    notifyListeners();
  }

  /// Tambah bahan baku baru
  Future<bool> createBahan(Map<String, dynamic> bahanData) async {
    _setLoading(true);
    _clearError();

    try {
      final newBahan = await _bahanService.createBahan(bahanData);
      _bahanList.add(newBahan);
      _applyFilter();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update stok bahan baku
  Future<bool> updateStok(String id, double jumlah, String keterangan) async {
    _setLoading(true);
    _clearError();

    try {
      await _bahanService.updateStokBahan(id, jumlah, keterangan);
      await fetchBahanBaku(); // Refresh data
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Hapus bahan baku
  Future<bool> deleteBahan(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _bahanService.deleteBahan(id);
      _bahanList.removeWhere((bahan) => bahan.idBahan == id);
      _applyFilter();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // ==================== PRIVATE METHODS ====================

  void _applyFilter() {
    _filteredList = _bahanList.where((bahan) {
      // Filter by search
      final matchSearch = _searchQuery.isEmpty ||
          bahan.namaBahan.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by status
      bool matchStatus = true;
      switch (_filterStatus) {
        case 'Rendah':
          matchStatus = bahan.isStokRendah && !bahan.isStokHabis;
          break;
        case 'Habis':
          matchStatus = bahan.isStokHabis;
          break;
        case 'Aman':
          matchStatus = bahan.isStokAman;
          break;
      }

      return matchSearch && matchStatus;
    }).toList();
  }

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

