import 'package:equatable/equatable.dart';

/// Enum untuk role user
/// Menerapkan OOP: Type Safety dengan Enum
enum UserRole { owner, kasir, barista }

/// Extension untuk konversi UserRole ke/dari String
extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.owner:
        return 'OWNER';
      case UserRole.kasir:
        return 'KASIR';
      case UserRole.barista:
        return 'BARISTA';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return UserRole.owner;
      case 'KASIR':
        return UserRole.kasir;
      case 'BARISTA':
        return UserRole.barista;
      default:
        return UserRole.kasir;
    }
  }
}

/// Model User - merepresentasikan data pengguna
/// Menerapkan prinsip OOP:
/// - Encapsulation: private fields dengan getter
/// - Immutability: menggunakan final fields
/// - Equatable: untuk perbandingan objek
class UserModel extends Equatable {
  final String idUser;
  final String username;
  final UserRole role;
  final String? token;
  final DateTime? createdAt;

  const UserModel({
    required this.idUser,
    required this.username,
    required this.role,
    this.token,
    this.createdAt,
  });

  /// Factory constructor untuk membuat UserModel dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] ?? '',
      username: json['username'] ?? '',
      role: UserRoleExtension.fromString(json['role'] ?? 'KASIR'),
      token: json['token'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  /// Konversi ke JSON untuk API request
  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'role': role.value,
      if (token != null) 'token': token,
    };
  }

  /// Copy with untuk immutability
  UserModel copyWith({
    String? idUser,
    String? username,
    UserRole? role,
    String? token,
    DateTime? createdAt,
  }) {
    return UserModel(
      idUser: idUser ?? this.idUser,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Cek apakah user adalah owner
  bool get isOwner => role == UserRole.owner;

  /// Cek apakah user adalah kasir
  bool get isKasir => role == UserRole.kasir;

  /// Cek apakah user adalah barista
  bool get isBarista => role == UserRole.barista;

  /// Cek apakah bisa mengelola menu
  bool get canManageMenu => isOwner || isKasir;

  /// Cek apakah bisa menghapus menu
  bool get canDeleteMenu => isOwner;

  /// Cek apakah bisa membuat order
  bool get canCreateOrder => isOwner || isKasir;

  @override
  List<Object?> get props => [idUser, username, role, token, createdAt];

  @override
  String toString() => 'UserModel(idUser: $idUser, username: $username, role: ${role.value})';
}

