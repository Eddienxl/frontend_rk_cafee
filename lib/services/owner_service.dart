import '../models/user_model.dart';
import '../models/menu_model.dart';

class OwnerService {
  // ================= DUMMY DATA STORE =================
  // Simulasi database lokal sementara
  final List<UserModel> _dummyUsers = [
    UserModel(id: '1', username: 'owner', role: 'OWNER'),
    UserModel(id: '2', username: 'kasir1', role: 'KASIR'),
    UserModel(id: '3', username: 'barista1', role: 'BARISTA'),
  ];

  final List<MenuModel> _dummyMenus = [
    MenuModel(id: '1', nama: 'Kopi Susu Gula Aren', harga: 18000, kategori: 'MINUMAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '2', nama: 'Americano', harga: 15000, kategori: 'MINUMAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '3', nama: 'Nasi Goreng Spesial', harga: 25000, kategori: 'MAKANAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '4', nama: 'Kentang Goreng', harga: 12000, kategori: 'SNACK', imageUrl: '', isAvailable: true),
  ];

  // ================= USER MANAGEMENT =================
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi network delay
    return _dummyUsers;
  }

  Future<bool> createUser(String username, String password, String role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyUsers.add(UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      role: role
    ));
    return true;
  }

  Future<bool> updateUser(String id, String? password, String? role) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _dummyUsers.indexWhere((u) => u.id == id);
    if (index != -1) {
      final old = _dummyUsers[index];
      _dummyUsers[index] = UserModel(
        id: old.id,
        username: old.username,
        role: role ?? old.role,
        token: old.token
      );
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyUsers.removeWhere((u) => u.id == id);
    return true;
  }

  // ================= LAPORAN KEUANGAN =================
  Future<Map<String, dynamic>> getLaporanPenjualan({String? startDate, String? endDate}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Dummy Report Data
    return {
      'total_omzet': 5000000,
      'total_order': 150,
      'menu_terlaris': [
        {'nama_menu': 'Kopi Susu Gula Aren', 'total_terjual': 80},
        {'nama_menu': 'Nasi Goreng Spesial', 'total_terjual': 45},
        {'nama_menu': 'Kentang Goreng', 'total_terjual': 25},
      ],
      'statistik_harian': [
        {'hari': 'Senin', 'omzet': 500000},
        {'hari': 'Selasa', 'omzet': 750000},
        {'hari': 'Rabu', 'omzet': 600000},
        {'hari': 'Kamis', 'omzet': 800000},
        {'hari': 'Jumat', 'omzet': 1200000},
        {'hari': 'Sabtu', 'omzet': 1500000},
        {'hari': 'Minggu', 'omzet': 1000000},
      ]
    };
  }
  
  // ================= MENU MANAGEMENT =================
  // Digabung disini biar simple, DataService bisa deprecated
  Future<List<MenuModel>> getMenus() async {
     await Future.delayed(const Duration(milliseconds: 500));
     return _dummyMenus;
  }
  
  Future<bool> createMenu(String nama, int harga, String kategori) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyMenus.add(MenuModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nama: nama,
      harga: harga,
      kategori: kategori,
      isAvailable: true
    ));
    return true;
  }

  Future<bool> updateMenu(String id, String nama, int harga, String kategori) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _dummyMenus.indexWhere((m) => m.id == id);
    if (index != -1) {
      final old = _dummyMenus[index];
      _dummyMenus[index] = MenuModel(
        id: old.id,
        nama: nama,
        harga: harga,
        kategori: kategori,
        imageUrl: old.imageUrl,
        isAvailable: old.isAvailable
      );
      return true;
    }
    return false;
  }

  Future<bool> deleteMenu(String idMenu) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _dummyMenus.removeWhere((m) => m.id == idMenu);
    return true;
  }
}
