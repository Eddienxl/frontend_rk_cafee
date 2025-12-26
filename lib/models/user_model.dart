class UserModel {
  final String idUser;
  final String username;
  final String role;
  final String? token;

  UserModel({
    required this.idUser,
    required this.username,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure if necessary
    Map<String, dynamic> data = json;
    
    // Check if 'data' wrapper exists and has 'id_user' or 'user' object
    if (json.containsKey('data')) {
      if (json['data'] is Map && json['data'].containsKey('user')) {
        data = json['data']['user'];
      } else if (json['data'] is Map) {
        data = json['data'];
      }
    } else if (json.containsKey('user')) {
      data = json['user'];
    }

    return UserModel(
      idUser: data['id_user']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      role: (data['role']?.toString() ?? 'KASIR').toUpperCase(),
      token: json['token'] ?? (json['data'] is Map ? json['data']['token'] : null),
    );
  }
}
