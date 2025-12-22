import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/menu_model.dart';

/// Service untuk menu - berkomunikasi dengan backend menu API
/// Menerapkan prinsip OOP:
/// - Interface Segregation: interface terpisah untuk abstraksi
/// - Dependency Injection: menerima ApiClient dari luar
abstract class IMenuApiService {
  Future<List<MenuModel>> getAllMenus();
  Future<MenuModel> createMenu(Map<String, dynamic> menuData);
  Future<void> updateMenu(String id, Map<String, dynamic> menuData);
  Future<void> deleteMenu(String id);
  Future<List<MenuModel>> bulkCreateMenu(List<Map<String, dynamic>> menus);
}

class MenuApiService implements IMenuApiService {
  final ApiClient _apiClient;

  MenuApiService(this._apiClient);

  @override
  Future<List<MenuModel>> getAllMenus() async {
    final response = await _apiClient.get(ApiConstants.menus);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => MenuModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<MenuModel> createMenu(Map<String, dynamic> menuData) async {
    final response = await _apiClient.post(
      ApiConstants.menus,
      body: menuData,
    );

    if (response['success'] == true && response['data'] != null) {
      return MenuModel.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Gagal membuat menu');
  }

  @override
  Future<void> updateMenu(String id, Map<String, dynamic> menuData) async {
    final response = await _apiClient.put(
      '${ApiConstants.menus}/$id',
      body: menuData,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal update menu');
    }
  }

  @override
  Future<void> deleteMenu(String id) async {
    final response = await _apiClient.delete('${ApiConstants.menus}/$id');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal hapus menu');
    }
  }

  @override
  Future<List<MenuModel>> bulkCreateMenu(List<Map<String, dynamic>> menus) async {
    final response = await _apiClient.post(
      ApiConstants.menusBulk,
      body: {'menus': menus},
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => MenuModel.fromJson(json)).toList();
    }
    throw Exception(response['message'] ?? 'Gagal bulk create menu');
  }
}

