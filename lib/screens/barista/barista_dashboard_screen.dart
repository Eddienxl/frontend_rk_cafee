import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'barista_order_screen.dart';
import 'barista_stock_screen.dart';

class BaristaDashboardScreen extends StatefulWidget {
  const BaristaDashboardScreen({super.key});

  @override
  State<BaristaDashboardScreen> createState() => _BaristaDashboardScreenState();
}

class _BaristaDashboardScreenState extends State<BaristaDashboardScreen> {
  final AuthService _authService = AuthService();
  String _username = '';
  String _role = 'Barista';
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BaristaOrderScreen(),
    const BaristaStockScreen(),
  ];

  final List<String> _titles = [
    "Daftar Pesanan",
    "Stok Bahan Baku",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await _authService.getUser();
    setState(() {
      _username = user['username'] ?? 'Barista';
      _role = user['role'] ?? 'Barista';
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
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.brown, // Consistent with Owner/Kasir
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
                child: Icon(Icons.coffee_maker, size: 40, color: Colors.brown),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.brown),
              title: const Text("Daftar Pesanan"),
              selected: _selectedIndex == 0,
              selectedColor: Colors.amber[900],
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.brown),
              title: const Text("Cek Bahan Baku"),
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
