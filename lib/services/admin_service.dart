import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AdminService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ================= USER MANAGEMENT =================

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

  Future<bool> createUser(String username, String password, String role) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/users');

    // Generate ID User (Backend requires ID)
    // Format: USR + last 6 digits of timestamp
    final idUser = 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'id_user': idUser,
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

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

  Future<Map<String, dynamic>> getLaporanPenjualan({String? startDate, String? endDate}) async {
    final token = await _getToken();
    
    // Default URL
    String urlString = '${ApiConfig.baseUrl}/laporan/penjualan';
    
    // Add Query Params
    if (startDate != null && endDate != null) {
      urlString += '?startDate=$startDate&endDate=$endDate';
    }

    final url = Uri.parse(urlString); 

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal ambil laporan: ${response.body}");
    }
  }
  
  // ================= MENU MANAGEMENT =================
  
  // CREATE MENU
  Future<bool> createMenu(String nama, int harga, String kategori) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'nama_menu': nama,
        'harga': harga,
        'kategori': kategori,
        'status_tersedia': true
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // UPDATE MENU
  Future<bool> updateMenu(String id, String nama, int harga, String kategori) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/menus/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'nama_menu': nama,
        'harga': harga,
        'kategori': kategori,
      }),
    );

    return response.statusCode == 200;
  }

  // DELETE MENU (Restricted to Owner)
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
