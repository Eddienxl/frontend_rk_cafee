import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/bom_model.dart';

/// Service untuk Bill of Materials - mengelola resep/komposisi bahan per menu
/// Menerapkan prinsip OOP:
/// - Interface Segregation: kontrak jelas untuk operasi BOM
/// - Dependency Injection: menerima ApiClient dari luar
abstract class IBomApiService {
  Future<List<BomModel>> getAllBom();
  Future<List<BomModel>> getBomByMenu(String idMenu);
  Future<BomModel> createBom(Map<String, dynamic> bomData);
  Future<void> updateBom(String id, Map<String, dynamic> bomData);
  Future<void> deleteBom(String id);
}

class BomApiService implements IBomApiService {
  final ApiClient _apiClient;

  BomApiService(this._apiClient);

  @override
  Future<List<BomModel>> getAllBom() async {
    final response = await _apiClient.get(ApiConstants.bom);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => BomModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<List<BomModel>> getBomByMenu(String idMenu) async {
    final response = await _apiClient.get('${ApiConstants.bom}/menu/$idMenu');

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => BomModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<BomModel> createBom(Map<String, dynamic> bomData) async {
    final response = await _apiClient.post(
      ApiConstants.bom,
      body: bomData,
    );

    if (response['success'] == true && response['data'] != null) {
      return BomModel.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Gagal membuat BOM');
  }

  @override
  Future<void> updateBom(String id, Map<String, dynamic> bomData) async {
    final response = await _apiClient.put(
      '${ApiConstants.bom}/$id',
      body: bomData,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal update BOM');
    }
  }

  @override
  Future<void> deleteBom(String id) async {
    final response = await _apiClient.delete('${ApiConstants.bom}/$id');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal hapus BOM');
    }
  }
}

