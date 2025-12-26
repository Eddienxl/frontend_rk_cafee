import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bahan_baku_model.dart';
import '../config/api_config.dart';

class BahanService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<BahanBakuModel>> getBahanBaku() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bahan');
    try {
      final response = await http.get(url, headers: await _headers());

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          final List data = json['data'];
          return data.map((e) => BahanBakuModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print("GetBahanBaku Error: $e");
    }
    return [];
  }

  Future<bool> createBahan({
    required String nama,
    required double stok,
    required String satuan,
    required double min,
    String? idBahan,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bahan');
    try {
      final response = await http.post(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'id_bahan': idBahan ?? 'BB-${DateTime.now().millisecondsSinceEpoch}',
          'nama_bahan': nama,
          'stok_saat_ini': stok,
          'stok_minimum': min,
          'satuan': satuan,
          'satuan_input': satuan,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("CreateBahan Error: $e");
      return false;
    }
  }

  Future<bool> updateBahanStok({
    required String idBahan,
    required double jumlah,
    required String satuanInput,
    String keterangan = 'Update Manual',
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bahan/$idBahan');
    try {
      final response = await http.put(
        url,
        headers: await _headers(),
        body: jsonEncode({
          'jumlah': jumlah,
          'satuan_input': satuanInput,
          'keterangan': keterangan,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("UpdateBahanStok Error: $e");
      return false;
    }
  }
  
  Future<bool> deleteBahan(String idBahan) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/bahan/$idBahan');
    try {
      final response = await http.delete(url, headers: await _headers());
      return response.statusCode == 200;
    } catch (e) {
      print("DeleteBahan Error: $e");
      return false;
    }
  }
}
