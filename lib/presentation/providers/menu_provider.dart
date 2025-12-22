import 'package:flutter/foundation.dart';
import '../../data/datasources/menu_api_service.dart';
import '../../data/models/menu_model.dart';

/// Provider untuk state management menu
/// Menerapkan prinsip OOP:
/// - Encapsulation: state di-protect dengan getter
/// - Single Responsibility: hanya mengelola state menu
class MenuProvider extends ChangeNotifier {
  final MenuApiService _menuService;

  List<MenuModel> _menus = [];
  List<MenuModel> _filteredMenus = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedKategori = 'Semua';
  String _searchQuery = '';

  MenuProvider(this._menuService);

  // ==================== GETTERS ====================
  List<MenuModel> get menus => _menus;
  List<MenuModel> get filteredMenus => _filteredMenus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedKategori => _selectedKategori;
  String get searchQuery => _searchQuery;

  // ==================== METHODS ====================

  /// Fetch semua menu dari API
  Future<void> fetchMenus() async {
    _setLoading(true);
    _clearError();

    try {
      _menus = await _menuService.getAllMenus();
      _applyFilter();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Filter menu berdasarkan kategori
  void filterByKategori(String kategori) {
    _selectedKategori = kategori;
    _applyFilter();
    notifyListeners();
  }

  /// Search menu berdasarkan nama
  void searchMenu(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Create menu baru
  Future<bool> createMenu(Map<String, dynamic> menuData) async {
    _setLoading(true);
    _clearError();

    try {
      final newMenu = await _menuService.createMenu(menuData);
      _menus.add(newMenu);
      _applyFilter();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update menu
  Future<bool> updateMenu(String id, Map<String, dynamic> menuData) async {
    _setLoading(true);
    _clearError();

    try {
      await _menuService.updateMenu(id, menuData);
      await fetchMenus(); // Refresh data
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Delete menu
  Future<bool> deleteMenu(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _menuService.deleteMenu(id);
      _menus.removeWhere((menu) => menu.idMenu == id);
      _applyFilter();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Get menu yang tersedia saja
  List<MenuModel> get availableMenus => 
      _filteredMenus.where((menu) => menu.statusTersedia).toList();

  // ==================== PRIVATE METHODS ====================

  void _applyFilter() {
    _filteredMenus = _menus.where((menu) {
      // Filter by kategori
      final menuKat = menu.kategori?.trim().toLowerCase() ?? '';
      final selectedKat = _selectedKategori.trim().toLowerCase();
      
      final matchKategori = selectedKat == 'semua' || menuKat == selectedKat;
      
      // Filter by search query
      final matchSearch = _searchQuery.isEmpty ||
          menu.namaMenu.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchKategori && matchSearch;
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

