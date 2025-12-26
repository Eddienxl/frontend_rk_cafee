import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/menu_model.dart';

class OwnerService {
  
  // Helper: Get Token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper: Headers
  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================= USERS =================
  Future<List<UserModel>> getUsers() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List data = json['data'];
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<bool> createUser(String username, String password, String role) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'id_user': DateTime.now().millisecondsSinceEpoch, // Backend need ID? Check Controller. Yes, it takes id_user from body.
        'username': username,
        'password': password,
        'role': role
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateUser(String id, String? password, String? role) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
    final body = <String, dynamic>{};
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (role != null) body['role'] = role;

    final response = await http.put(
      url, 
      headers: await _headers(),
      body: jsonEncode(body)
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteUser(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
    final response = await http.delete(url, headers: await _headers());
    return response.statusCode == 200;
  }

  // ================= MENUS =================
  Future<List<MenuModel>> getMenus() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');
    // Public endpoint sometimes? Or Protected? Route says: get /menus is public (no verifyToken).
    // But good practice to send headers if we have them.
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List data = json['data'];
        return data.map((e) => MenuModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<bool> createMenu(String nama, int harga, String kategori) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'id_menu': DateTime.now().millisecondsSinceEpoch.toString(), // Backend expects String/Int ID? DB is usually AutoInc or Provided. Controller takes id_menu.
        'nama_menu': nama,
        'harga': harga,
        'kategori': kategori,
        'status_tersedia': true 
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateMenu(String id, String nama, int harga, String kategori) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus/$id');
    final response = await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'nama_menu': nama,
        'harga': harga,
        'kategori': kategori,
        // 'status_tersedia': true // Keep existing status logic if needed
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteMenu(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus/$id');
    final response = await http.delete(url, headers: await _headers());
    return response.statusCode == 200;
  }

  // ================= LAPORAN =================
  Future<Map<String, dynamic>> getLaporanPenjualan({String? startDate, String? endDate}) async {
    // Default date: This Month
    final now = DateTime.now();
    final start = startDate ?? DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    final end = endDate ?? DateFormat('yyyy-MM-dd').format(now);

    final url = Uri.parse('${ApiConfig.baseUrl}/laporan/penjualan?startDate=$start&endDate=$end');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Backend returns directly the object structure { periode, total_order, ... }
      return json;
    }
    return {};
  }

  // ================= BOM / RESEP =================
  Future<List<Map<String, dynamic>>> getBOM() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bom');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        // Backend returns: data: [ { id_menu, nama_menu, resep: [...] }, ... ]
        return List<Map<String, dynamic>>.from(json['data']);
      }
    }
    return [];
  }

  // ================= BAHAN BAKU =================
  Future<List<Map<String, dynamic>>> getBahanBaku() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bahan');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        // Backend data: [ { id_bahan, nama_bahan, stok_awal, stok_masuk, stok_keluar, sisa_stok, satuan... } ]
        return List<Map<String, dynamic>>.from(json['data']);
      }
    }
    return [];
  }
}
