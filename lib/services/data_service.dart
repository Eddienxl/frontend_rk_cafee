import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_rk_cafee/config/api_config.dart';
import 'package:frontend_rk_cafee/models/menu_model.dart';

class DataService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

  // 1. GET ALL MENU (Public/Shared used by Owner too)
  Future<List<MenuModel>> getMenus() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'] ?? [];
      return data.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil menu: ${response.statusCode}");
    }
  }
}
