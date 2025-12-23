import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/order_model.dart';

/// Service untuk order - berkomunikasi dengan backend order API
/// Menerapkan prinsip OOP:
/// - Abstraction: mendefinisikan kontrak melalui interface
/// - Dependency Injection: menerima dependency dari luar
abstract class IOrderApiService {
  Future<OrderModel> createOrder(Map<String, dynamic> orderData);
  Future<void> updateOrderStatus(String id, String status);
  Future<List<OrderModel>> getKitchenOrders();
}

class OrderApiService implements IOrderApiService {
  final ApiClient _apiClient;

  OrderApiService(this._apiClient);

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    final response = await _apiClient.post(
      ApiConstants.orders,
      body: orderData,
    );

    // API Docs structure: { success: true, message: "...", data: { id_order, total_bayar } }
    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      // Because API only returns id and total, we create a partial model or generic one.
      // Assuming OrderModel has a fromJson that can handle this or we create a specific one.
      // For now, let's assume we return a model with just these fields.
      return OrderModel(
        idOrder: data['id_order'] ?? '',
        idUser: orderData['id_user'] ?? '',
        totalBayar: (data['total_bayar'] ?? 0).toDouble(),
        // other fields empty or default
        items: [],
        tanggal: DateTime.now(),
        statusPesanan: 'BARU',
      );
    }
    throw Exception(response['message'] ?? 'Gagal membuat order');
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    final response = await _apiClient.put(
      '${ApiConstants.orders}/$id',
      body: {'status_pesanan': status},
    );

    if (response['message'] == null || !response['message'].toString().contains('berhasil')) {
      throw Exception(response['message'] ?? 'Gagal update status order');
    }
  }

  @override
  Future<List<OrderModel>> getKitchenOrders() async {
    final response = await _apiClient.get(ApiConstants.kitchenOrders);

    if (response['orders'] != null) {
      final List<dynamic> data = response['orders'];
      return data.map((json) => OrderModel.fromJson(json)).toList();
    }
    return [];
  }
}

