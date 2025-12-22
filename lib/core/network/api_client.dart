import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// HTTP Client untuk komunikasi dengan backend API
/// Menerapkan prinsip OOP: 
/// - Encapsulation: menyembunyikan detail implementasi HTTP
/// - Single Responsibility: hanya bertanggung jawab untuk HTTP requests
class ApiClient {
  final http.Client _client;
  String? _token;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Set token untuk autentikasi
  void setToken(String token) {
    _token = token;
  }

  /// Clear token saat logout
  void clearToken() {
    _token = null;
  }

  /// Headers default untuk setiap request
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    }
  }

  /// Handle HTTP response dan convert ke Map
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw ValidationException(body['message'] ?? 'Request tidak valid');
      case 401:
        throw AuthException(body['message'] ?? 'Autentikasi gagal');
      case 403:
        throw ForbiddenException(body['message'] ?? 'Akses ditolak');
      case 404:
        throw NotFoundException(body['message'] ?? 'Data tidak ditemukan');
      case 500:
      default:
        throw ServerException(body['message'] ?? 'Terjadi kesalahan server', response.statusCode);
    }
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}

