import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/auth_api_service.dart';
import '../../data/models/user_model.dart';

/// Provider untuk state management autentikasi
/// Menerapkan prinsip OOP:
/// - Encapsulation: state internal di-protect dengan _underscore
/// - Observer Pattern: extends ChangeNotifier untuk reactive updates
class AuthProvider extends ChangeNotifier {
  final AuthApiService _authService;
  final ApiClient _apiClient;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService, this._apiClient);

  // ==================== GETTERS ====================
  UserModel? get currentUser => const UserModel(idUser: 'dummy', username: 'Owner Mode', role: UserRole.owner, token: 'dummy'); // MOCKED data
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => true; // MOCKED: Always logged in

  // ==================== METHODS ====================

  /// Login user
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.login(username, password);
      _currentUser = user;
      
      // Set token ke API client
      if (user.token != null) {
        _apiClient.setToken(user.token!);
        // Simpan token ke local storage
        await _saveToken(user.token!);
        await _saveUserData(user);
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
    _apiClient.clearToken();
    await _clearLocalData();
    notifyListeners();
  }

  /// Check dan restore session dari local storage
  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');
      final username = prefs.getString('username');
      final role = prefs.getString('user_role');

      if (token != null && userId != null && username != null && role != null) {
        _currentUser = UserModel(
          idUser: userId,
          username: username,
          role: UserRoleExtension.fromString(role),
          token: token,
        );
        _apiClient.setToken(token);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear error message
  void clearError() => _clearError();

  // ==================== PRIVATE METHODS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.idUser);
    await prefs.setString('username', user.username);
    await prefs.setString('user_role', user.role.value);
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('user_role');
  }
}

