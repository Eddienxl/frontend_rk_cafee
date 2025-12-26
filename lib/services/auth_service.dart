import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  Future<UserModel?> login(String username, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Handle response API format
        // API Docs: { message: "...", token: "...", user: {...} }
        // Guide mungkin beda, kita sesuaikan dengan API Docs asli
        
        UserModel user = UserModel.fromJson(data);

        // Simpan Token ke HP
        final prefs = await SharedPreferences.getInstance();
        if (user.token != null) {
          await prefs.setString('auth_token', user.token!); // Key should be 'auth_token' to match UserService/etc
        }
        await prefs.setString('role', user.role);
        await prefs.setString('username', user.username);
        await prefs.setString('user_id', user.idUser);

        return user;
      } else {
        print("Login Gagal: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
  Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username') ?? '',
      'role': prefs.getString('role') ?? '',
      'idUser': prefs.getString('user_id') ?? '',
    };
  }
}
