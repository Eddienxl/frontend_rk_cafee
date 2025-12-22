import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/bahan_baku_model.dart';

/// Service untuk bahan baku/inventory - berkomunikasi dengan backend API
/// Menerapkan prinsip OOP:
/// - Abstraction: interface mendefinisikan kontrak
/// - Single Responsibility: hanya menangani operasi bahan baku
abstract class IBahanBakuApiService {
  Future<List<BahanBakuModel>> getAllBahan();
  Future<BahanBakuModel> createBahan(Map<String, dynamic> bahanData);
  Future<void> updateStokBahan(String id, double jumlah, String keterangan);
  Future<void> deleteBahan(String id);
}

class BahanBakuApiService implements IBahanBakuApiService {
  final ApiClient _apiClient;

  BahanBakuApiService(this._apiClient);

  @override
  Future<List<BahanBakuModel>> getAllBahan() async {
    final response = await _apiClient.get(ApiConstants.bahan);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => BahanBakuModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<BahanBakuModel> createBahan(Map<String, dynamic> bahanData) async {
    final response = await _apiClient.post(
      ApiConstants.bahan,
      body: bahanData,
    );

    if (response['success'] == true && response['data'] != null) {
      return BahanBakuModel.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Gagal membuat bahan baku');
  }

  @override
  Future<void> updateStokBahan(String id, double jumlah, String keterangan) async {
    final response = await _apiClient.put(
      '${ApiConstants.bahan}/$id',
      body: {
        'jumlah': jumlah,
        'keterangan': keterangan,
      },
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal update stok');
    }
  }

  @override
  Future<void> deleteBahan(String id) async {
    final response = await _apiClient.delete('${ApiConstants.bahan}/$id');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal hapus bahan baku');
    }
  }
}

