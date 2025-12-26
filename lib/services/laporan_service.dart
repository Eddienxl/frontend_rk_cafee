import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class LaporanService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getLaporanPenjualan({String? startDate, String? endDate}) async {
    final now = DateTime.now();
    final start = startDate ?? DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
    final end = endDate ?? DateFormat('yyyy-MM-dd').format(now);

    final url = Uri.parse('${ApiConfig.baseUrl}/laporan/penjualan?startDate=$start&endDate=$end');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json;
    }
    return {};
  }
}
