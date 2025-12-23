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
  /// Fetch menus (MOCKED for UI Testing)
  Future<void> fetchMenus() async {
    _setLoading(true);
    _clearError();

    // DUMMY DATA - LOGIC REMOVED
    await Future.delayed(const Duration(milliseconds: 500)); // Fake delay
    _menus = [
      const MenuModel(idMenu: '1', namaMenu: 'Kopi Susu Gula Aren', harga: 18000, kategori: 'Coffee', imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '2', namaMenu: 'Americano', harga: 15000, kategori: 'Coffee', imageUrl: 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '3', namaMenu: 'Cappuccino', harga: 20000, kategori: 'Coffee', imageUrl: 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '4', namaMenu: 'Latte', harga: 22000, kategori: 'Coffee', imageUrl: 'https://images.unsplash.com/photo-1461023058943-716d30d94c8f?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '5', namaMenu: 'Es Teh Manis', harga: 5000, kategori: 'Non Coffee', imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '6', namaMenu: 'Matcha Latte', harga: 23000, kategori: 'Non Coffee', imageUrl: 'https://images.unsplash.com/photo-1515825838458-f2a94b20105a?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '7', namaMenu: 'Nasi Goreng', harga: 25000, kategori: 'Food', imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '8', namaMenu: 'Kentang Goreng', harga: 15000, kategori: 'Food', imageUrl: 'https://images.unsplash.com/photo-1573080496987-aeb4d9171d55?q=80&w=1000', statusTersedia: true),
      const MenuModel(idMenu: '9', namaMenu: 'Extra Shot', harga: 5000, kategori: 'Add On', imageUrl: '', statusTersedia: true),
    ];
    _applyFilter();
    _setLoading(false);
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

