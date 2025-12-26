import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'kasir_pos_screen.dart';
import 'kasir_status_order_screen.dart';

class KasirDashboardScreen extends StatefulWidget {
  const KasirDashboardScreen({super.key});

  @override
  State<KasirDashboardScreen> createState() => _KasirDashboardScreenState();
}

class _KasirDashboardScreenState extends State<KasirDashboardScreen> {
  final AuthService _authService = AuthService();
  String _username = '';
  String _role = 'Kasir'; // Default
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const KasirPosScreen(),
    const KasirStatusOrderScreen(),
  ];
  
  final List<String> _titles = [
    "Buat Pesanan",
    "Status Pesanan",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await _authService.getUser();
    setState(() {
      _username = user['username'] ?? 'Kasir';
      _role = user['role'] ?? 'Kasir';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close Drawer
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.brown),
              accountName: Text(_username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text(_role),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.brown),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale, color: Colors.brown),
              title: const Text("Buat Pesanan"),
              selected: _selectedIndex == 0,
              selectedColor: Colors.amber[900],
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.brown),
              title: const Text("Status Pesanan"),
              selected: _selectedIndex == 1,
              selectedColor: Colors.amber[900],
              onTap: () => _onItemTapped(1),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Keluar", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
