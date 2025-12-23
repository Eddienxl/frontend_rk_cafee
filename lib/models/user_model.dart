class UserModel {
  final String id;
  final String username;
  final String role;
  final String? token;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handling struktur response yang berbeda (kadang nested di user, kadang flat)
    // Guide bilang json['user']['id_user'], tapi kita buat flexible
    final userData = json['user'] ?? json;
    
    return UserModel(
      id: userData['id_user']?.toString() ?? '',
      username: userData['username'] ?? '',
      role: userData['role'] ?? 'KASIR', 
      token: json['token'], // Token biasanya di root response
    );
  }
}
