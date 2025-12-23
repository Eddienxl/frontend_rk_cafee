import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/menu_model.dart'; // Untuk Top Selling items jika ada

class AdminService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ================= USER MANAGEMENT =================

  // GET ALL USERS
  Future<List<UserModel>> getUsers() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/users');
    
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'] ?? [];
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil data user: ${response.statusCode}");
    }
  }

  // CREATE USER
  Future<bool> createUser(String username, String password, String role) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/users');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // UPDATE USER
  Future<bool> updateUser(String id, String? password, String? role) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');

    final body = <String, dynamic>{};
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (role != null) body['role'] = role;

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  // DELETE USER
  Future<bool> deleteUser(String id) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // ================= LAPORAN KEUANGAN =================

  // GET LAPORAN PENJUALAN
  // Return Map karena struktur laporan biasanya kompleks (total omzet, list transaksi, dll)
  Future<Map<String, dynamic>> getLaporanPenjualan({String? period}) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/laporan/penjualan'); 
    // TODO: Add query params ?start_date=... if needed

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal ambil laporan");
    }
  }
  
  // ================= MENU MANAGEMENT (OWNER ONLY) =================
  
  // DELETE MENU (Restricted to Owner usually)
  Future<bool> deleteMenu(String idMenu) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/menus/$idMenu');

    final response = await http.delete(
      url, 
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
}
