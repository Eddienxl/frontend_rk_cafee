import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'owner/user_management_screen.dart';
import 'owner/laporan_screen.dart';
import 'owner/menu_management_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _pageTitle = 'Dashboard Owner';
  Widget _currentScreen = const Center(child: CircularProgressIndicator()); 
  
  String _username = '';
  // String _role = ''; // Role tidak lagi dipakai untuk logic navigasi, fokus OWNER

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Owner';
    // Access token/role for api calls if needed, but UI is strictly Owner now.

    if (mounted) {
      setState(() {
        _username = username;
        // Default selalu layar admin home grid
        _pageTitle = 'Dashboard Owner';
        _currentScreen = _buildAdminHomeGrid(); 
      });
    }
  }

  // WIDGET GRID MENU UTAMA UNTUK OWNER
  Widget _buildAdminHomeGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildNavCard('Kelola User', Icons.people, const UserManagementScreen()),
          _buildNavCard('Laporan Keuangan', Icons.bar_chart, const LaporanScreen()),
          _buildNavCard('Kelola Menu', Icons.restaurant_menu, const MenuManagementScreen()),
          _buildNavCard('Bahan Baku', Icons.inventory, const Center(child: Text("Fitur Bahan Baku (Soon)"))),
          _buildNavCard('Resep (BOM)', Icons.science, const Center(child: Text("Fitur BOM Resep (Soon)"))),
          _buildNavCard('Input Stok', Icons.input, const Center(child: Text("Fitur Input Stok (Soon)"))),
        ],
      ),
    );
  }

  Widget _buildNavCard(String title, IconData icon, Widget screen) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _changePage(title, screen), 
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(0xFF5D4037)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
            ),
          ],
        ),
      ),
    );
  }

  // Method Navigasi Aman
  void _changePage(String title, Widget screen, {bool isFromDrawer = false}) {
    setState(() {
      _pageTitle = title;
      _currentScreen = screen;
    });
    if (isFromDrawer) {
      Navigator.pop(context); 
    }
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
              accountEmail: null, 
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF5D4037)),
              ),
            ),
            
            // MENU NAVIGASI (HANYA OWNER)
            ListTile(
              leading: const Icon(Icons.grid_view), 
              title: const Text('Menu Utama'),
              onTap: () {
                  setState(() {
                    _pageTitle = 'Dashboard Owner';
                    _currentScreen = _buildAdminHomeGrid();
                  });
                  Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Laporan Keuangan'),
              onTap: () => _changePage('Laporan Keuangan', const LaporanScreen(), isFromDrawer: true),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manajemen Karyawan'),
              onTap: () => _changePage('Manajemen User', const UserManagementScreen(), isFromDrawer: true),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Kelola Menu'),
              onTap: () => _changePage('Kelola Menu', const MenuManagementScreen(), isFromDrawer: true),
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
