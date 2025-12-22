import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/laporan_model.dart';

/// Service untuk Laporan Penjualan
/// Menerapkan prinsip OOP:
/// - Single Responsibility: hanya menangani operasi laporan
/// - Abstraction: interface mendefinisikan kontrak
abstract class ILaporanApiService {
  Future<LaporanPenjualanResponse> getLaporanPenjualan({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class LaporanApiService implements ILaporanApiService {
  final ApiClient _apiClient;

  LaporanApiService(this._apiClient);

  @override
  Future<LaporanPenjualanResponse> getLaporanPenjualan({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Build query params
    String endpoint = ApiConstants.laporanPenjualan;
    
    if (startDate != null || endDate != null) {
      final params = <String>[];
      if (startDate != null) {
        params.add('startDate=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        params.add('endDate=${endDate.toIso8601String()}');
      }
      if (params.isNotEmpty) {
        endpoint = '$endpoint?${params.join('&')}';
      }
    }

    final response = await _apiClient.get(endpoint);

    // Backend mengembalikan object langsung (bukan wrapped in 'data')
    // Response format:
    // {
    //   "periode": { "dari": "...", "sampai": "..." },
    //   "total_order": 10,
    //   "total_omzet": 150000,
    //   "total_item": 25,
    //   "menu_terlaris": [...]
    // }
    return LaporanPenjualanResponse.fromJson(response);
  }
}
