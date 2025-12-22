import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/laporan_model.dart';

/// Service untuk Laporan Penjualan
/// Menerapkan prinsip OOP:
/// - Single Responsibility: hanya menangani operasi laporan
/// - Abstraction: interface mendefinisikan kontrak
abstract class ILaporanApiService {
  Future<List<LaporanItem>> getLaporanPenjualan({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class LaporanApiService implements ILaporanApiService {
  final ApiClient _apiClient;

  LaporanApiService(this._apiClient);

  @override
  Future<List<LaporanItem>> getLaporanPenjualan({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Build query params
    String endpoint = ApiConstants.kitchenOrders; // Menggunakan endpoint orders
    
    if (startDate != null || endDate != null) {
      final params = <String>[];
      if (startDate != null) {
        params.add('start_date=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        params.add('end_date=${endDate.toIso8601String()}');
      }
      if (params.isNotEmpty) {
        endpoint = '$endpoint?${params.join('&')}';
      }
    }

    final response = await _apiClient.get(endpoint);

    // Handle response - backend mengembalikan 'orders' bukan 'data'
    if (response['orders'] != null) {
      final List<dynamic> data = response['orders'];
      return data
          .where((json) => json['status_pesanan'] == 'SELESAI' || json['status'] == 'SELESAI')
          .map((json) => LaporanItem.fromJson(json))
          .toList();
    }
    
    if (response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => LaporanItem.fromJson(json)).toList();
    }
    
    return [];
  }
}

