import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Service untuk autentikasi - berkomunikasi dengan backend auth API
/// Menerapkan prinsip OOP:
/// - Single Responsibility: hanya menangani auth operations
/// - Dependency Injection: menerima ApiClient dari luar
abstract class IAuthApiService {
  Future<UserModel> login(String username, String password);
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> createUser(Map<String, dynamic> userData);
  Future<void> updateUser(String id, Map<String, dynamic> userData);
  Future<void> deleteUser(String id);
}

class AuthApiService implements IAuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response['success'] == true && response['data'] != null) {
      return UserModel.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Login gagal');
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await _apiClient.get(ApiConstants.users);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => UserModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final response = await _apiClient.post(
      ApiConstants.users,
      body: userData,
    );

    if (response['success'] == true && response['data'] != null) {
      return UserModel.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Gagal membuat user');
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await _apiClient.put(
      '${ApiConstants.users}/$id',
      body: userData,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal update user');
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    final response = await _apiClient.delete('${ApiConstants.users}/$id');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal hapus user');
    }
  }
}

