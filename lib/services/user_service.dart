import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class UserService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<UserModel>> getUsers() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List data = json['data'];
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<bool> createUser(String username, String password, String role) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        'id_user': DateTime.now().millisecondsSinceEpoch,
        'username': username,
        'password': password,
        'role': role
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateUser(String id, String? password, String? role) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
    final body = <String, dynamic>{};
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (role != null) body['role'] = role;

    final response = await http.put(
      url, 
      headers: await _headers(),
      body: jsonEncode(body)
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteUser(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/users/$id');
    final response = await http.delete(url, headers: await _headers());
    return response.statusCode == 200;
  }
}
