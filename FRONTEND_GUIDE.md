# Panduan Implementasi Frontend (Flutter) - RK Caffee App

Panduan ini berisi langkah-langkah teknis untuk membangun aplikasi Android menggunakan **Flutter (Dart)** yang terintegrasi dengan Backend RK Caffee.

---

## 1. Persiapan Project & Dependencies

Buka file `pubspec.yaml` dan tambahkan package berikut:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Networking
  http: ^1.2.0 # Untuk request ke API

  # Penyimpanan Lokal (Token & User Session)
  shared_preferences: ^2.2.2

  # Formatting (Rupiah & Tanggal)
  intl: ^0.19.0

  # State Management (Opsional tapi disarankan, contoh pakai Provider)
  provider: ^6.1.1
```

Jangan lupa jalankan `flutter pub get` di terminal.

---

## 2. Struktur Folder Kode (`lib/`)

Agar kode rapi dan mudah dimaintenance, gunakan struktur berikut:

```text
lib/
├── config/
│   └── api_config.dart       # Konfigurasi URL Server
├── models/
│   ├── user_model.dart       # Model User & Login Response
│   ├── menu_model.dart       # Model Data Menu
│   └── cart_item.dart        # Model Keranjang Belanja
├── services/
│   ├── auth_service.dart     # Service Login
│   └── data_service.dart     # Service Menu & Order
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart # Halaman Utama (sesuai Role)
│   └── pos_screen.dart       # Halaman Kasir
└── main.dart
```

---

## 3. Konfigurasi API (`config/api_config.dart`)

Buat file ini untuk menyimpan URL server, jadi kalau ganti server (misal dari Localhost ke Railway), cukup ganti di satu file ini saja.

```dart
class ApiConfig {
  // Ganti dengan IP Laptop kamu jika pakai Emulator
  // Emulator Android biasa: 10.0.2.2
  // Genymotion: 10.0.3.2
  // Real Device: 192.168.x.x (IP Laptop di WiFi yang sama)
  // Railway (Production): https://backendrkcafee-production-ec5d.up.railway.app/api

  static const String baseUrl = "https://backendrkcafee-production-ec5d.up.railway.app/api";
}
```

---

## 4. Membuat Data Model (Dart Class)

### A. Model User (`models/user_model.dart`)

```dart
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
    return UserModel(
      id: json['user']['id_user'],
      username: json['user']['username'],
      role: json['user']['role'], // "OWNER", "KASIR", "BARISTA"
      token: json['token'],
    );
  }
}
```

### B. Model Menu (`models/menu_model.dart`)

```dart
class MenuModel {
  final String id;
  final String nama;
  final int harga;
  final String kategori;

  MenuModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    // Parse Harga ke Int secara aman
    int hargaInt = 0;
    if (json['harga'] is int) {
      hargaInt = json['harga'];
    } else if (json['harga'] is String) {
      hargaInt = int.tryParse(json['harga']) ?? 0;
    }

    return MenuModel(
      id: json['id_menu'],
      nama: json['nama_menu'],
      harga: hargaInt,
      kategori: json['kategori'] ?? 'UMUM',
    );
  }
}
```

---

## 5. Membuat Service (Integrasi API)

### A. Auth Service (`services/auth_service.dart`)

Menangani Login dan Penyimpanan Token.

```dart
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        UserModel user = UserModel.fromJson(data);

        // Simpan Token ke HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', user.token!);
        await prefs.setString('role', user.role);

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
}
```

### B. Data Service (`services/data_service.dart`)

Menangani pengambilan Menu dan Pembuatan Order.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/menu_model.dart';

class DataService {
  // Helper untuk ambil token tersimpan
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Mengambil token JWT
  }

  // 1. GET ALL MENU
  Future<List<MenuModel>> getMenus() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/menus');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'];
      return data.map((e) => MenuModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil menu");
    }
  }

  // 2. CREATE ORDER (Checkout)
  Future<bool> createOrder(String userId, List<Map<String, dynamic>> items) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token' // Wajib kirim token
      },
      body: jsonEncode({
        'id_user': userId,
        'items': items
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Gagal Order: ${response.body}");
      return false;
    }
  }
}
```

---

## 6. Contoh Implementasi di UI (Layar Kasir)

Berikut adalah contoh logika sederhana di tombol "Bayar" (`pos_screen.dart`).

```dart
void _onCheckoutPressed() async {
  // 1. Siapkan data item dari keranjang
  // Contoh data dummy (nanti ambil dari state keranjang kamu)
  List<Map<String, dynamic>> itemsToOrder = [
    {"id_menu": "MNU-001", "jumlah": 2},
    {"id_menu": "MNU-005", "jumlah": 1},
  ];

  // 2. Panggil Service
  String userId = "USR-001"; // Ambil ID user yang sedang login dari SharedPref

  bool success = await DataService().createOrder(userId, itemsToOrder);

  // 3. Cek Hasil
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Transaksi Berhasil!")),
    );
    // Kosongkan keranjang & kembali ke dashboard
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Transaksi Gagal. Stok habis?")),
    );
  }
}
```

---

## 💡 Tips Penting

1.  **Role Based UI**: Setelah login berhasil, cek `role` user.
    - Jika `OWNER` -> Tampilkan Menu Laporan & Kelola User.
    - Jika `KASIR` -> Tampilkan Menu POS (Kasir).
    - Jika `BARISTA` -> Tampilkan Menu Resep & Kitchen Display.
2.  **Error Handling**: Selalu gunakan `try-catch` saat memanggil API, karena koneksi internet bisa saja putus.
3.  **Loading State**: Tampilkan indikator loading (spinner) saat menunggu respon API agar user tidak bingung.
