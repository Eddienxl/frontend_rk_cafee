import 'package:flutter/foundation.dart';
import '../../data/datasources/order_api_service.dart';
import '../../data/models/order_model.dart';
import '../../data/models/cart_item_model.dart';

/// Provider untuk state management order
/// Menerapkan prinsip OOP:
/// - Encapsulation: logika order tersembunyi
/// - State Management: mengelola list orders dan status
class OrderProvider extends ChangeNotifier {
  final OrderApiService _orderService;

  List<OrderModel> _orders = [];
  List<OrderModel> _kitchenOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  OrderProvider(this._orderService);

  // ==================== GETTERS ====================
  List<OrderModel> get orders => _orders;
  List<OrderModel> get kitchenOrders => _kitchenOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Orders dengan status BARU
  List<OrderModel> get ordersBaru => 
      _kitchenOrders.where((o) => o.isBaru).toList();

  /// Orders dengan status SEDANG DIBUAT
  List<OrderModel> get ordersSedangDibuat => 
      _kitchenOrders.where((o) => o.isSedangDibuat).toList();

  /// Orders dengan status SELESAI
  List<OrderModel> get ordersSelesai => 
      _kitchenOrders.where((o) => o.isSelesai).toList();

  // ==================== METHODS ====================

  /// Create order baru
  Future<bool> createOrder({
    required String namaMenu,
    required int jumlahOrder,
    required String idUser,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      await _orderService.createOrder({
        'nama_menu': namaMenu,
        'jumlah_order': jumlahOrder,
        'id_user': idUser,
      });
      
      _successMessage = 'Order berhasil dibuat!';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Create multiple orders (dari cart)
  Future<bool> createOrderFromCart({
    required List<CartItemModel> cartItems,
    required String idUser,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      // Proses setiap item di cart sebagai order terpisah
      // (sesuai dengan struktur API backend yang ada)
      for (final item in cartItems) {
        await _orderService.createOrder({
          'nama_menu': item.menu.namaMenu,
          'jumlah_order': item.jumlah,
          'id_user': idUser,
        });
      }
      
      _successMessage = 'Semua order berhasil dibuat!';
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Fetch orders untuk kitchen display
  Future<void> fetchKitchenOrders() async {
    _setLoading(true);
    _clearMessages();

    try {
      _kitchenOrders = await _orderService.getKitchenOrders();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Update status order
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _setLoading(true);
    _clearMessages();

    try {
      await _orderService.updateOrderStatus(orderId, newStatus.value);
      
      // Update local state
      final index = _kitchenOrders.indexWhere((o) => o.idOrder == orderId);
      if (index >= 0) {
        _kitchenOrders[index] = _kitchenOrders[index].copyWith(
          statusPesanan: newStatus,
        );
      }
      
      _successMessage = 'Status order berhasil diupdate!';
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Clear messages
  void clearMessages() => _clearMessages();

  // ==================== PRIVATE METHODS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}

