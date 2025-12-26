import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'user_management_screen.dart';
import 'laporan_screen.dart';
import 'menu_management_screen.dart';
import 'bahan_baku_screen.dart';
import 'bom_screen.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';
import '../../services/laporan_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _pageTitle = 'Dashboard Owner';
  Widget? _currentScreen; 
  
  String _username = 'Owner';
  final LaporanService _laporanService = LaporanService();
  Map<String, dynamic> _summaryData = {};

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchSummary();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Owner';
    if (mounted) {
      setState(() {
        _username = username;
        _currentScreen = _buildAdminHomeGrid();
      });
    }
  }

  void _fetchSummary() async {
    final data = await _laporanService.getLaporanPenjualan();
    if (mounted) {
      setState(() {
        _summaryData = data;
        if (_pageTitle == 'Dashboard Owner') {
          _currentScreen = _buildAdminHomeGrid(); 
        }
      });
    }
  }

  Widget _buildAdminHomeGrid() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    double omzet = (_summaryData['total_omzet'] ?? 0).toDouble();
    int order = _summaryData['total_order'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 24),
          
          // STAT CARDS
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Omzet Hari Ini", 
                  currencyFormat.format(omzet), 
                  Icons.monetization_on, 
                  Colors.green
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Total Pesanan", 
                  "$order Order", 
                  Icons.shopping_bag, 
                  Colors.orange
                )
              ),
            ],
          ),
          const SizedBox(height: 24),

          // NAVIGATION GRID
          Text(
            "Manajemen Sistem",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037)),
          ),
          const SizedBox(height: 16),
          
          _buildNavigationGrid(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Halo Owner ",
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037)),
        ),
        const SizedBox(height: 4),
        Text(
          "Semoga harimu menyenangkan dan produktif.",
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildNavigationGrid() {
    return GridView.count(
      crossAxisCount: 2, 
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildNavCard('Manajemen User', Icons.manage_accounts, const UserManagementScreen(), Colors.blue),
        _buildNavCard('Laporan Keuangan', Icons.receipt_long, const LaporanScreen(), Colors.purple),
        _buildNavCard('Kelola Menu', Icons.restaurant_menu, const MenuManagementScreen(), Colors.orange),
        _buildNavCard('Bahan Baku', Icons.inventory_2, const BahanBakuScreen(), Colors.brown), 
        _buildNavCard('Resep (BOM)', Icons.list_alt_rounded, const BOMScreen(), Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D))),
        ],
      ),
    );
  }

  Widget _buildNavCard(String title, IconData icon, Widget screen, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changePage(title, screen), 
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF5D4037)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    final isHome = _pageTitle == 'Dashboard Owner';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        title: Text(_pageTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: isHome ? null : [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _changePage('Dashboard Owner', _buildAdminHomeGrid()),
          )
        ],
      ),
      drawer: isHome ? Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF5D4037)),
              accountName: Text(_username, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20)),
              accountEmail: const Text("Owner Access"), 
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF5D4037)),
              ),
            ),
             ListTile(
              leading: const Icon(Icons.dashboard_rounded, color: Color(0xFF5D4037)), 
              title: Text('Dashboard', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onTap: () {
                  _changePage('Dashboard Owner', _buildAdminHomeGrid(), isFromDrawer: true);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: Text('Keluar', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ) : null,
      body: _currentScreen ?? const Center(child: CircularProgressIndicator()),
    );
  }
}
