import 'package:flutter/foundation.dart';
import '../../data/datasources/bom_api_service.dart';
import '../../data/models/bom_model.dart';

/// Provider untuk state management Bill of Materials
/// Menerapkan prinsip OOP:
/// - Encapsulation: state internal di-protect
/// - Observer Pattern: notifikasi perubahan ke listeners
class BomProvider extends ChangeNotifier {
  final BomApiService _bomService;

  List<BomModel> _bomList = [];
  List<BomModel> _bomByMenu = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedMenuId;

  BomProvider(this._bomService);

  // ==================== GETTERS ====================
  List<BomModel> get bomList => _bomList;
  List<BomModel> get bomByMenu => _bomByMenu;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedMenuId => _selectedMenuId;

  // ==================== METHODS ====================

  /// Fetch semua BOM
  Future<void> fetchAllBom() async {
    _setLoading(true);
    _clearError();

    try {
      _bomList = await _bomService.getAllBom();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Fetch BOM by menu ID
  Future<void> fetchBomByMenu(String idMenu) async {
    _setLoading(true);
    _clearError();
    _selectedMenuId = idMenu;

    try {
      _bomByMenu = await _bomService.getBomByMenu(idMenu);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Create BOM baru
  Future<bool> createBom({
    required String idMenu,
    required String idBahan,
    required double jumlahDibutuhkan,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newBom = await _bomService.createBom({
        'id_menu': idMenu,
        'id_bahan': idBahan,
        'jumlah_dibutuhkan': jumlahDibutuhkan,
      });
      _bomList.add(newBom);
      if (_selectedMenuId == idMenu) {
        _bomByMenu.add(newBom);
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update BOM
  Future<bool> updateBom(String id, double jumlahDibutuhkan) async {
    _setLoading(true);
    _clearError();

    try {
      await _bomService.updateBom(id, {
        'jumlah_dibutuhkan': jumlahDibutuhkan,
      });
      // Refresh data
      if (_selectedMenuId != null) {
        await fetchBomByMenu(_selectedMenuId!);
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete BOM
  Future<bool> deleteBom(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _bomService.deleteBom(id);
      _bomList.removeWhere((bom) => bom.idBom == id);
      _bomByMenu.removeWhere((bom) => bom.idBom == id);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Clear selected menu
  void clearSelectedMenu() {
    _selectedMenuId = null;
    _bomByMenu = [];
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

