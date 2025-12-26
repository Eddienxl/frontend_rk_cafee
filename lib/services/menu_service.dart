import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menu_model.dart';
import '../config/api_config.dart';

class MenuService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<MenuModel>> getMenus() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');
    final response = await http.get(url); // Route usually public or doesn't strictly require token for list

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
        'id_menu': DateTime.now().millisecondsSinceEpoch.toString(),
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
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteMenu(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus/$id');
    final response = await http.delete(url, headers: await _headers());
    return response.statusCode == 200;
  }
}
