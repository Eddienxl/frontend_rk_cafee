import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- KASIR: Buat Order Baru ---
  Future<bool> createOrder(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id'); // Pastikan user_id disimpan saat login

    if (userId == null) return false;

    final url = Uri.parse('${ApiConfig.baseUrl}/orders');
    
    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'id_user': userId,
          'items': items.map((e) => e.toJson()).toList(),
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Create Order Error: $e");
      return false;
    }
  }

  // --- BARISTA: Ambil Daftar Order (Kitchen) ---
  Future<List<OrderModel>> getKitchenOrders() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/kitchen/orders');
    try {
      final response = await http.get(url, headers: await _headers());

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['orders'] is List) {
          return (json['orders'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      print("Get Kitchen Orders Error: $e");
    }
    return [];
  }

  // --- BARISTA: Update Status Order ---
  Future<bool> updateStatus(String orderId, String newStatus) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/orders/$orderId');
    try {
      final response = await http.put(
        url,
        headers: await _headers(),
        body: jsonEncode({'status_pesanan': newStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Update Status Error: $e");
      return false;
    }
  }
}
