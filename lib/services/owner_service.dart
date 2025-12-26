import '../models/user_model.dart';
import '../models/menu_model.dart';

class OwnerService {
  // ================= DUMMY DATA STORE =================
  
  // 1. DATA USER
  final List<UserModel> _dummyUsers = [
    UserModel(id: '1', username: 'owner_asep', role: 'OWNER'),
    UserModel(id: '2', username: 'admin_winda', role: 'ADMIN'),
    UserModel(id: '3', username: 'kasir_budi', role: 'KASIR'),
    UserModel(id: '4', username: 'kasir_siti', role: 'KASIR'),
    UserModel(id: '5', username: 'barista_joni', role: 'BARISTA'),
    UserModel(id: '6', username: 'dapur_maman', role: 'DAPUR'),
  ];

  // 2. DATA MENU
  final List<MenuModel> _dummyMenus = [
    // Minuman
    MenuModel(id: '1', nama: 'Espresso', harga: 15000, kategori: 'MINUMAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '2', nama: 'Americano', harga: 18000, kategori: 'MINUMAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '3', nama: 'Kopi Susu Gula Aren', harga: 22000, kategori: 'MINUMAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '4', nama: 'Cappuccino', harga: 24000, kategori: 'MINUMAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '5', nama: 'Red Velvet Latte', harga: 26000, kategori: 'MINUMAN', imageUrl: '', isAvailable: false),
    MenuModel(id: '6', nama: 'Es Teh Manis', harga: 8000, kategori: 'MINUMAN', imageUrl: '', isAvailable: true),
    
    // Makanan
    MenuModel(id: '11', nama: 'Nasi Goreng Spesial', harga: 28000, kategori: 'MAKANAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '12', nama: 'Mie Goreng Seafood', harga: 30000, kategori: 'MAKANAN', imageUrl: '', isAvailable: true),
    MenuModel(id: '13', nama: 'Rice Bowl Teriyaki', harga: 32000, kategori: 'MAKANAN', imageUrl: '', isAvailable: true),
    
    // Snack
    MenuModel(id: '21', nama: 'Kentang Goreng', harga: 15000, kategori: 'SNACK', imageUrl: '', isAvailable: true),
    MenuModel(id: '22', nama: 'Pisang Bakar Keju', harga: 18000, kategori: 'SNACK', imageUrl: '', isAvailable: true),
    MenuModel(id: '23', nama: 'Cireng Rujak', harga: 12000, kategori: 'SNACK', imageUrl: '', isAvailable: true),
  ];

  // 3. DATA BOM / RESEP
  // Struktur: ID Menu -> List Bahan
  final List<Map<String, dynamic>> _dummyBOM = [
    {
      'id_menu': '1', // Espresso
      'nama_menu': 'Espresso',
      'resep': [
        {'nama_bahan': 'Biji Kopi Arabica', 'jumlah': 18, 'satuan': 'gram'},
        {'nama_bahan': 'Air Mineral', 'jumlah': 30, 'satuan': 'ml'},
      ]
    },
    {
      'id_menu': '3', // Kopi Susu Gula Aren
      'nama_menu': 'Kopi Susu Gula Aren',
      'resep': [
        {'nama_bahan': 'Espresso Shot', 'jumlah': 1, 'satuan': 'shot'},
        {'nama_bahan': 'Susu UHT', 'jumlah': 150, 'satuan': 'ml'},
        {'nama_bahan': 'Gula Aren Cair', 'jumlah': 30, 'satuan': 'ml'},
        {'nama_bahan': 'Es Batu', 'jumlah': 100, 'satuan': 'gram'},
      ]
    },
    {
      'id_menu': '11', // Nasi Goreng
      'nama_menu': 'Nasi Goreng Spesial',
      'resep': [
        {'nama_bahan': 'Nasi Putih', 'jumlah': 200, 'satuan': 'gram'},
        {'nama_bahan': 'Telur Ayam', 'jumlah': 1, 'satuan': 'butir'},
        {'nama_bahan': 'Bumbu Nasi Goreng', 'jumlah': 1, 'satuan': 'sdm'},
        {'nama_bahan': 'Minyak Goreng', 'jumlah': 10, 'satuan': 'ml'},
        {'nama_bahan': 'Ayam Suwir', 'jumlah': 30, 'satuan': 'gram'},
      ]
    },
    {
      'id_menu': '21', // Kentang Goreng
      'nama_menu': 'Kentang Goreng',
      'resep': [
        {'nama_bahan': 'Kentang Frozen', 'jumlah': 150, 'satuan': 'gram'},
        {'nama_bahan': 'Garam / Bumbu Tabur', 'jumlah': 2, 'satuan': 'gram'},
        {'nama_bahan': 'Minyak Goreng', 'jumlah': 200, 'satuan': 'ml'}, // utk deep fry (estimasi serap)
      ]
    },
  ];

  // ================= METHODS =================

  // --- USER ---
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
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

  // --- MENU ---
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

  // --- REPORT ---
  Future<Map<String, dynamic>> getLaporanPenjualan({String? startDate, String? endDate}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Data Statistik Dummy yang lebih detail
    return {
      'total_omzet': 12500000,
      'total_order': 450,
      'total_profit_bersih': 8200000, 
      'menu_terlaris': [
        {'nama_menu': 'Kopi Susu Gula Aren', 'total_terjual': 120},
        {'nama_menu': 'Nasi Goreng Spesial', 'total_terjual': 85},
        {'nama_menu': 'Kentang Goreng', 'total_terjual': 60},
        {'nama_menu': 'Espresso', 'total_terjual': 55},
        {'nama_menu': 'Mie Goreng Seafood', 'total_terjual': 40},
      ],
      'statistik_harian': [
        {'hari': 'Senin', 'omzet': 1500000},
        {'hari': 'Selasa', 'omzet': 1200000},
        {'hari': 'Rabu', 'omzet': 1800000},
        {'hari': 'Kamis', 'omzet': 1600000},
        {'hari': 'Jumat', 'omzet': 2500000},
        {'hari': 'Sabtu', 'omzet': 3200000}, // Weekend rame
        {'hari': 'Minggu', 'omzet': 2800000},
      ]
    };
  }

  // --- BOM / RESEP ---
  // Returns List of Object {id_menu, nama_menu, resep: List}
  Future<List<Map<String, dynamic>>> getBOM() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _dummyBOM;
  }
}
