import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/menu_model.dart';

class DataService {
  // Helper untuk ambil token tersimpan
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

  Future<String?> _getUserId() async {
     // Di implementasi real, userId sebaiknya disimpan di prefs saat login
     // Tapi API createOrder butuh id_user
     // Kita simpan manual/logic sementara
     return "MOCK_USER_ID"; // TODO: Implement get user id from prefs
  }

  // 1. GET ALL MENU
  Future<List<MenuModel>> getMenus() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // API Docs: { message, data: [...] }
      final List data = json['data'] ?? [];
      return data.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil menu: ${response.statusCode}");
    }
  }

  // 2. CREATE ORDER (Checkout)
  Future<bool> createOrder(String userId, List<Map<String, dynamic>> items) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token' // Wajib kirim token
      },
      body: jsonEncode({
        'id_user': userId, // Sesuaikan dengan API
        'items': items,
        'status_pesanan': 'BARU',
        'total_bayar': 0 // Backend usually calculates this, but send placeholder
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print("Gagal Order: ${response.body}");
      return false;
    }
  }
}
