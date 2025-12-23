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
    // Robust parsing untuk menangani berbagai format response backend
    Map<String, dynamic>? userData;
    String? tokenStr = json['token'];

    // 1. Cek jika struktur: { data: { user: {...}, token: "..." } }
    if (json.containsKey('data') && json['data'] is Map) {
      final data = json['data'];
      if (data.containsKey('user')) {
        userData = data['user'];
      } else {
        userData = data; // user info langsung di dalam data
      }
      if (tokenStr == null && data.containsKey('token')) {
        tokenStr = data['token'];
      }
    } 
    // 2. Cek jika struktur: { user: {...}, token: "..." }
    else if (json.containsKey('user')) {
      userData = json['user'];
    } 
    // 3. Fallback: JSON itu sendiri adalah user data
    else {
      userData = json;
    }

    return UserModel(
      id: userData?['id_user']?.toString() ?? userData?['id']?.toString() ?? '',
      username: userData?['username'] ?? '',
      // Pakai UpperCase biar aman perbandingannya nanti
      role: (userData?['role'] ?? 'KASIR').toString().toUpperCase(), 
      token: tokenStr,
    );
  }
}
