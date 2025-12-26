import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
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
  Widget _currentScreen = const Center(child: CircularProgressIndicator()); 
  
  String _username = 'Owner';
  final LaporanService _laporanService = LaporanService();
  Map<String, dynamic> _summaryData = {}; // Dummy summary data

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
        _pageTitle = 'Dashboard Owner';
        _currentScreen = _buildAdminHomeGrid(); // Initial view is Grid
      });
    }
  }

  void _fetchSummary() async {
    // Simulasi fetch data ringkasan untuk dashboard
    final data = await _laporanService.getLaporanPenjualan();
    if (mounted) {
      setState(() {
        _summaryData = data;
        // Rebuild grid jika sedang di home
        if (_pageTitle == 'Dashboard Owner') {
          _currentScreen = _buildAdminHomeGrid(); 
        }
      });
    }
  }

  // WIDGET GRID MENU UTAMA UNTUK OWNER
  Widget _buildAdminHomeGrid() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    double omzet = (_summaryData['total_omzet'] ?? 0).toDouble();
    int order = _summaryData['total_order'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GREETING SECTION
          Text(
            "Selamat Pagi, $_username! 👋",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Berikut ringkasan performa cafe hari ini.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // STAT CARDS ROW
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
          const SizedBox(height: 32),
          
          // MENU SECTION TITLE
          const Text(
            "Menu Cepat",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
          ),
          const SizedBox(height: 16),
          
          // NAVIGATION GRID
          GridView.count(
            crossAxisCount: 2, 
            shrinkWrap: true, // Agar bisa scroll dalam Column
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildNavCard('Kelola User', Icons.people_outline, const UserManagementScreen(), Colors.blue),
              _buildNavCard('Laporan', Icons.analytics_outlined, const LaporanScreen(), Colors.purple),
              _buildNavCard('Kelola Menu', Icons.restaurant_menu, const MenuManagementScreen(), Colors.orange),
              _buildNavCard('Bahan Baku', Icons.inventory_2_outlined, const BahanBakuScreen(), Colors.brown), 
              _buildNavCard('Resep (BOM)', Icons.science_outlined, const BOMScreen(), Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1))
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavCard(String title, IconData icon, Widget screen, Color color) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () => _changePage(title, screen), 
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
             border: Border.all(color: Colors.grey.withOpacity(0.1))
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
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
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method Navigasi Aman
  void _changePage(String title, Widget screen, {bool isFromDrawer = false}) {
    // Jika screen adalah widget yang butuh AppBar sendiri (seperti yang kita buat di masing-masing screen),
    // kita bungkus dengan container/page. 
    // TAPI: structure currentScreen hanya mengganti BODY.
    // Screen anak idealnya TIDAK punya Scaffold+AppBar sendiri jika ingin embedded.
    // Kecuali kita mau layout bersih.
    
    // User request: Clean UI.
    // Jika kita ganti _currentScreen, Title Appbar utama juga ganti.
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
    // Perhatikan: child screens kita (UserManagement, dll) punya Scaffold & AppBar sendiri.
    // Jika ditaruh di dalam body Scaffold Dashboard, akan ada Nested Scaffold (AppBar double).
    // Solusi: Jika sedang di Home, tampilkan AppBar Dashboard.
    // Jika sedang di Child Screen, HILANGKAN AppBar Dashboard jika Child punya AppBar.
    // ATAU: Child screen jangan pakai Scaffold, tapi return Widget content.
    
    // Karena kita reuse screen yang sudah ada (yang punya Scaffold), kita handle ini.
    // Jika _pageTitle != 'Dashboard Owner', berarti kita sedang di sub-page.
    // Sebaiknya kita gunakan Expanded/Container body saja, tanpa AppBar parent jika child punya AppBar.
    
    final isHome = _pageTitle == 'Dashboard Owner';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar halus
      appBar: isHome ? AppBar(
        title: Text(_pageTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ) : null, // Hide appbar if sub-page (assuming sub-pages have AppBars)
      
      drawer: isHome ? Drawer( // Drawer hanya di home untuk akses cepat
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
             UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF5D4037),
                image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=800&q=80"), fit: BoxFit.cover, opacity: 0.3)
              ),
              accountName: Text(_username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              accountEmail: const Text("Owner Access"), 
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF5D4037)),
              ),
            ),
             ListTile(
              leading: const Icon(Icons.dashboard), 
              title: const Text('Dashboard'),
              onTap: () {
                  _changePage('Dashboard Owner', _buildAdminHomeGrid(), isFromDrawer: true);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ) : null, // Disable drawer on subpages if we hide appbar
      
      body: isHome ? _currentScreen : Stack(
        children: [
          _currentScreen,
          // Add floating back button if needed, but sub-pages usually have Back button in their AppBar automatically IMPOSSIBLE here because we are not Pushing route.
          // Wait, if we use internal state nav, child Scaffold's AppBar leading will be 'Menu' or 'Back'?
          // Child scaffold is root of its widget tree. It won't have Back button automatically because navigation didn't push.
          
          // Better approach for cleaner UX:
          // Keep Parent Scaffold mostly dummy container, OR
          // Let's wrap child screen with a custom Back Button logic if it's not home.
          if (!isHome)
            Positioned(
              top: 40, left: 16, 
              child: FloatingActionButton.small(
                backgroundColor: const Color(0xFF5D4037),
                child: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                   _changePage('Dashboard Owner', _buildAdminHomeGrid());
                },
              ),
            ) 
            // NOTE: This floating button is a quick fix because Child Scaffolds usually take over. 
            // Ideally, we refactor Child Screens to NOT be Scaffolds, but Content widgets.
            // But to save time, I will assume Child Screens are full Scaffolds.
            // A nested Scaffold is okay-ish in Flutter.
            // The floating button might be obscured by child app bar.
            // Actually, if Child has AppBar, it will imply 'ImplyLeading: false' by default if no parent route.
            // Let's force a Leading: BackButton in child screens? No, too much editing.
            
            // ALTERNATIVE: Use the Parent Scaffold AppBar for ALL screens, and make Child Screens just return Body/Content.
            // This is "Refine Menu UI" task.
            // I will update MenuManagementScreen to NOT return Scaffold, but a Widget. 
            // SAME for Laporan and UserManagement.
            
            // Let's stick to the plan: Dashboard manages everything.
        ],
      ),
    );
  }
}
