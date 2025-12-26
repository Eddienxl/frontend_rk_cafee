import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'barista_order_screen.dart';
import 'barista_stock_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class BaristaDashboardScreen extends StatefulWidget {
  const BaristaDashboardScreen({super.key});

  @override
  State<BaristaDashboardScreen> createState() => _BaristaDashboardScreenState();
}

class _BaristaDashboardScreenState extends State<BaristaDashboardScreen> {
  final AuthService _authService = AuthService();
  String _username = '';
  String _role = 'BARISTA';
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BaristaOrderScreen(),
    const BaristaStockScreen(),
  ];

  final List<String> _titles = [
    "Panel Barista",
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
      _role = user['role'] ?? 'BARISTA';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); 
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF5D4037)),
              accountName: Text(_username, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text("Role: $_role", style: GoogleFonts.inter()),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.coffee_maker_rounded, size: 40, color: Color(0xFF5D4037)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF5D4037)),
              title: Text("Daftar Pesanan", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF5D4037)),
              title: Text("Cek Bahan Baku", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: Text("Keluar", style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
