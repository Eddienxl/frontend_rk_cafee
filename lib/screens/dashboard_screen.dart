import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pos_screen.dart';
import 'admin/user_management_screen.dart';
import 'admin/laporan_screen.dart';
import 'admin/menu_management_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _pageTitle = 'Dashboard';
  Widget _currentScreen = const Center(child: CircularProgressIndicator()); // Default loading
  
  String _username = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'KASIR';
    final username = prefs.getString('username') ?? 'User';

    setState(() {
      _username = username;
      _role = role;
      
      // LOGIC DEFAULT SCREEN BERDASARKAN ROLE
      if (_role == 'OWNER') {
        _pageTitle = 'Dashboard Owner';
        _currentScreen = const LaporanScreen(); // Home Owner = Laporan
      } else {
        _pageTitle = 'Kasir POS';
        _currentScreen = const PosScreen(); // Home Kasir = POS
      }
    });
  }

  void _changePage(String title, Widget screen) {
    setState(() {
      _pageTitle = title;
      _currentScreen = screen;
    });
    Navigator.pop(context); // Tutup drawer
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF5D4037)),
              accountName: Text(_username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text("Role: $_role"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF5D4037)),
              ),
            ),
            
            // MENU NAVIGASI DINAMIS

            // 1. OWNER MENU
            if (_role == 'OWNER') ...[
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard (Laporan)'),
                onTap: () => _changePage('Dashboard Owner', const LaporanScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Manajemen Karyawan'),
                onTap: () => _changePage('Manajemen User', const UserManagementScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Kelola Menu'),
                onTap: () => _changePage('Kelola Menu', const MenuManagementScreen()),
              ),
              // Owner TIDAK melihat POS
            ],

            // 2. KASIR MENU
            if (_role == 'KASIR') ...[
              ListTile(
                leading: const Icon(Icons.point_of_sale),
                title: const Text('Kasir (POS)'),
                onTap: () => _changePage('Kasir POS', const PosScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Daftar Menu'),
                onTap: () => _changePage('Daftar Menu', const MenuManagementScreen()),
              ),
            ],

            // 3. BARISTA MENU (Optional)
             if (_role == 'BARISTA') ...[
              ListTile(
                leading: const Icon(Icons.coffee),
                title: const Text('Kitchen Display'),
                onTap: () => {}, // Placeholder
              ),
            ],

            // MENU COMMS (SEMUA BISA AKSES INVENTORI?)
            const Divider(),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventori Bahan'),
              onTap: () => {}, // Placeholder
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}
