import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pos_screen.dart';
import 'admin/user_management_screen.dart';
import 'admin/laporan_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _pageTitle = 'POS Kasir';
  Widget _currentScreen = const PosScreen();
  
  String _username = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _role = prefs.getString('role') ?? 'KASIR';
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
            
            // MENU UMUM (SEMUA ROLE)
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Kasir (POS)'),
              onTap: () => _changePage('POS Kasir', const PosScreen()),
            ),

            // MENU KHUSUS OWNER
            if (_role == 'OWNER') ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text('ADMINISTRASI', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Manajemen Karyawan'),
                onTap: () => _changePage('Manajemen User', const UserManagementScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Laporan Keuangan'),
                onTap: () => _changePage('Laporan Keuangan', const LaporanScreen()),
              ),
            ],

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
