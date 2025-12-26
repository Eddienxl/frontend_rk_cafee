import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bom_model.dart';
import '../config/api_config.dart';

class BOMService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<BOMModel>> getBOM() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bom');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List data = json['data'];
        return data.map((e) => BOMModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<bool> createBOM(String idMenu, String idBahan, double jumlah) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bom');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'id_menu': idMenu,
        'bahan': [
          {
            'id_bahan': idBahan,
            'jumlah_dibutuhkan': jumlah
          }
        ]
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteBOM(String idBom) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bom/$idBom');
    final response = await http.delete(url, headers: await _headers());
    return response.statusCode == 200;
  }
}
