import 'package:flutter/foundation.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/menu_model.dart';

/// Provider untuk state management shopping cart
/// Menerapkan prinsip OOP:
/// - Encapsulation: logika cart tersembunyi dalam methods
/// - Single Responsibility: hanya mengelola shopping cart
class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  // ==================== GETTERS ====================
  List<CartItemModel> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.length;
  
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.jumlah);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  String get totalPriceFormatted {
    return 'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  // ==================== METHODS ====================

  /// Tambah item ke cart
  void addItem(MenuModel menu, {int quantity = 1, String? catatan}) {
    // Cek apakah menu sudah ada di cart
    final existingIndex = _items.indexWhere((item) => item.menu.idMenu == menu.idMenu);

    if (existingIndex >= 0) {
      // Update jumlah jika sudah ada
      _items[existingIndex] = _items[existingIndex].copyWith(
        jumlah: _items[existingIndex].jumlah + quantity,
      );
    } else {
      // Tambah item baru
      _items.add(CartItemModel(
        menu: menu,
        jumlah: quantity,
        catatan: catatan,
      ));
    }
    notifyListeners();
  }

  /// Hapus item dari cart
  void removeItem(String menuId) {
    _items.removeWhere((item) => item.menu.idMenu == menuId);
    notifyListeners();
  }

  /// Update jumlah item
  void updateQuantity(String menuId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuId);
      return;
    }

    final index = _items.indexWhere((item) => item.menu.idMenu == menuId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(jumlah: quantity);
      notifyListeners();
    }
  }

  /// Increment jumlah item
  void incrementItem(String menuId) {
    final index = _items.indexWhere((item) => item.menu.idMenu == menuId);
    if (index >= 0) {
      _items[index] = _items[index].increment();
      notifyListeners();
    }
  }

  /// Decrement jumlah item
  void decrementItem(String menuId) {
    final index = _items.indexWhere((item) => item.menu.idMenu == menuId);
    if (index >= 0) {
      if (_items[index].jumlah > 1) {
        _items[index] = _items[index].decrement();
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Update catatan item
  void updateCatatan(String menuId, String catatan) {
    final index = _items.indexWhere((item) => item.menu.idMenu == menuId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(catatan: catatan);
      notifyListeners();
    }
  }

  /// Clear semua item di cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Get item berdasarkan menu ID
  CartItemModel? getItem(String menuId) {
    try {
      return _items.firstWhere((item) => item.menu.idMenu == menuId);
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah menu ada di cart
  bool containsItem(String menuId) {
    return _items.any((item) => item.menu.idMenu == menuId);
  }

  /// Convert cart ke JSON untuk API
  List<Map<String, dynamic>> toJsonList() {
    return _items.map((item) => item.toJson()).toList();
  }
}

