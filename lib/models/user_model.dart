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
    // Logic sederhana & defensif: Cari map yang punya key 'username' atau 'role'
    // Prioritas: json['data']['user'] -> json['data'] -> json['user'] -> json
    
    Map<String, dynamic> userData = json;
    
    if (json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      if (data['user'] is Map) {
        userData = data['user'];
      } else {
        userData = data;
      }
    } else if (json['user'] is Map) {
      userData = json['user'];
    }

    // Ekstrak token
    String? token = json['token'];
    if (token == null && json['data'] is Map) {
      token = json['data']['token'];
    }

    return UserModel(
      id: userData['id_user']?.toString() ?? userData['id']?.toString() ?? '',
      username: userData['username']?.toString() ?? '',
      role: (userData['role']?.toString() ?? 'KASIR').toUpperCase(),
      token: token,
    );
  }
}
