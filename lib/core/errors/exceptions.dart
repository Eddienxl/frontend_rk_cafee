/// Custom Exception classes untuk handling error
/// Menerapkan prinsip OOP: Inheritance - mewarisi Exception
/// dan Polymorphism - setiap exception punya implementasi berbeda

/// Base class untuk semua custom exception
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Exception untuk error server/API
class ServerException extends AppException {
  ServerException([String message = 'Terjadi kesalahan pada server', int? statusCode])
      : super(message, statusCode);
}

/// Exception untuk error jaringan/koneksi
class NetworkException extends AppException {
  NetworkException([String message = 'Tidak ada koneksi internet'])
      : super(message);
}

/// Exception untuk error autentikasi
class AuthException extends AppException {
  AuthException([String message = 'Autentikasi gagal', int? statusCode])
      : super(message, statusCode);
}

/// Exception untuk data tidak ditemukan
class NotFoundException extends AppException {
  NotFoundException([String message = 'Data tidak ditemukan'])
      : super(message, 404);
}

/// Exception untuk validasi data
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException([
    String message = 'Validasi gagal',
    this.errors,
  ]) : super(message, 400);
}

/// Exception untuk cache/storage lokal
class CacheException extends AppException {
  CacheException([String message = 'Gagal mengakses cache'])
      : super(message);
}

/// Exception untuk unauthorized access
class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Akses tidak diizinkan'])
      : super(message, 401);
}

/// Exception untuk forbidden access
class ForbiddenException extends AppException {
  ForbiddenException([String message = 'Anda tidak memiliki izin untuk aksi ini'])
      : super(message, 403);
}

