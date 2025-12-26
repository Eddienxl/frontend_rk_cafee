import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../services/menu_service.dart';
import '../../services/order_service.dart';
import '../../services/bom_service.dart';
import '../../services/bahan_service.dart';
import '../../models/menu_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../models/bom_model.dart';
import '../../models/bahan_baku_model.dart';

class KasirDashboardScreen extends StatefulWidget {
  const KasirDashboardScreen({super.key});

  @override
  State<KasirDashboardScreen> createState() => _KasirDashboardScreenState();
}

class _KasirDashboardScreenState extends State<KasirDashboardScreen> {
  // Navigation State
  int _selectedIndex = 0; // 0 = Dashboard, 1 = Mesin Kasir

  // Services
  final MenuService _menuService = MenuService();
  final OrderService _orderService = OrderService();
  final BOMService _bomService = BOMService();
  final BahanService _bahanService = BahanService();

  // Data
  List<MenuModel> _menus = [];
  List<MenuModel> _filteredMenus = []; // For Search
  List<BOMModel> _boms = [];
  List<BahanBakuModel> _bahans = [];
  
  List<CartItemModel> _cart = [];
  List<OrderModel> _activeOrders = [];
  
  bool _isLoading = true;
  Timer? _refreshTimer;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    // Auto refresh active orders every 30s
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_selectedIndex == 0) _fetchActiveOrders();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchMenus(),
      _fetchActiveOrders(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMenus() async {
    try {
      final menus = await _menuService.getMenus();
      final boms = await _bomService.getBOM();
      final bahans = await _bahanService.getBahanBaku();
      setState(() {
        _menus = menus;
        _filteredMenus = menus;
        _boms = boms;
        _bahans = bahans;
      });
    } catch (e) {
      print("Error fetch menus: $e");
    }
  }

  Future<void> _fetchActiveOrders() async {
    try {
      final orders = await _orderService.getKitchenOrders();
      if (mounted) {
        setState(() {
          _activeOrders = orders;
          // Sort by newest first
          _activeOrders.sort((a, b) => b.tanggal?.compareTo(a.tanggal ?? DateTime.now()) ?? 0);
        });
      }
    } catch (e) {
      print("Error fetch orders: $e");
    }
  }

  void _filterMenus(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMenus = _menus;
      } else {
        _filteredMenus = _menus.where((m) => m.nama.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  // --- LOGIC CEK STOK ---
  bool _isMenuAvailable(String menuId) {
    final menu = _menus.firstWhere((m) => m.idMenu == menuId, orElse: () => MenuModel(idMenu: '', nama: '', harga: 0, kategori: '', isAvailable: false));
    if (!menu.isAvailable) return false;

    final bomHeader = _boms.firstWhere((b) => b.idMenu == menuId, orElse: () => BOMModel(idMenu: '', namaMenu: '', resep: []));
    if (bomHeader.resep.isEmpty) return true;

    for (var item in bomHeader.resep) {
      final bahan = _bahans.firstWhere((b) => b.idBahan == item.idBahan, orElse: () => BahanBakuModel(idBahan: '', nama: '', stokSaatIni: 0, stokMinimum: 0, satuan: ''));
      if (bahan.stokSaatIni < item.jumlahDibutuhkan) return false;
    }
    return true;
  }

  String _getUnavailableReason(String menuId) {
     final bomHeader = _boms.firstWhere((b) => b.idMenu == menuId, orElse: () => BOMModel(idMenu: '', namaMenu: '', resep: []));
     if (bomHeader.resep.isEmpty) return "Tidak Tersedia";

     for (var item in bomHeader.resep) {
       final bahan = _bahans.firstWhere((b) => b.idBahan == item.idBahan, orElse: () => BahanBakuModel(idBahan: '', nama: '', stokSaatIni: 0, stokMinimum: 0, satuan: ''));
       if (bahan.stokSaatIni < item.jumlahDibutuhkan) return "Stok ${bahan.nama} Habis";
     }
     return "Tidak Tersedia";
  }

  // --- POS ACTIONS ---
  void _addToCart(MenuModel menu) {
    if (!_isMenuAvailable(menu.idMenu)) return;
    setState(() {
      final index = _cart.indexWhere((item) => item.idMenu == menu.idMenu);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItemModel(idMenu: menu.idMenu, namaMenu: menu.nama, harga: menu.harga));
      }
    });
  }

  void _adjustQuantity(int index, int delta) {
    setState(() {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) _cart.removeAt(index);
    });
  }

  double get _totalPrice => _cart.fold(0, (sum, item) => sum + (item.harga * item.quantity));

  Future<void> _processCheckout() async {
    if (_cart.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Pesanan"),
        content: Text("Total: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_totalPrice)}\nProses sekarang?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Proses")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await _orderService.createOrder(_cart);
    
    if (success) {
      await _fetchMenus(); // Refresh stock
      await _fetchActiveOrders(); // Refresh status list
      if (mounted) {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan Berhasil!")));
        setState(() => _selectedIndex = 0); // Pindah ke dashboard untuk lihat status
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memproses pesanan.")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // SIDEBAR
          _buildSidebar(),
          // CONTENT AREA
          Expanded(
            child: _selectedIndex == 0 ? _buildDashboardContent() : _buildPOSContent(),
          ),
        ],
      ),
    );
  }

  // WIDGETS
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF2D2D2D), // Dark Sidebar
      child: Column(
        children: [
          const SizedBox(height: 40),
          // App Logo / Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.coffee, color: Colors.amber, size: 32),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("KasirApp", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("RK CAFEE", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildMenuItem(0, "Dashboard", Icons.dashboard),
          _buildMenuItem(1, "Mesin Kasir", Icons.point_of_sale),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Keluar", style: TextStyle(color: Colors.redAccent)),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 0) _fetchActiveOrders();
        if (index == 1) _fetchMenus(); // Ensure stock is fresh
      },
      child: Container(
        color: isSelected ? Colors.amber : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
             Icon(icon, color: isSelected ? Colors.black87 : Colors.grey),
             const SizedBox(width: 16),
             Text(title, style: TextStyle(color: isSelected ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- CONTENT 1: DASHBOARD (Active Orders) ---
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader("Dashboard", "Pantau status pesanan pelanggan"),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : _activeOrders.isEmpty 
              ? const Center(child: Text("Belum ada pesanan aktif hari ini.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = _activeOrders[index];
                    Color statusColor = Colors.grey;
                    if (order.statusPesanan == 'BARU') statusColor = Colors.blue;
                    else if (order.statusPesanan == 'SEDANG DIBUAT') statusColor = Colors.orange;
                    else if (order.statusPesanan == 'SELESAI') statusColor = Colors.green;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.1),
                          child: Icon(Icons.receipt_long, color: statusColor),
                        ),
                        title: Text("Order #${order.idOrder}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${order.items.length} Menu • ${DateFormat('HH:mm').format(order.tanggal ?? DateTime.now())}"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(order.statusPesanan, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- CONTENT 2: MESIN KASIR (POS) ---
  Widget _buildPOSContent() {
    return Row(
      children: [
        // MIDDLE: MENU GRID WITH SEARCH
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader("Mesin Kasir", "Pilih menu untuk pesanan baru"),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterMenus,
                  decoration: InputDecoration(
                    hintText: "Cari produk...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              // Categories Chips (Dummy for visuals)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    _buildCategoryChip("Semua", true),
                    const SizedBox(width: 8),
                    _buildCategoryChip("Makanan", false),
                    const SizedBox(width: 8),
                    _buildCategoryChip("Minuman", false),
                  ],
                ),
              ),

              // GRID
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      childAspectRatio: 0.85, 
                      crossAxisSpacing: 16, 
                      mainAxisSpacing: 16
                    ),
                    itemCount: _filteredMenus.length,
                    itemBuilder: (context, index) => _buildMenuCard(_filteredMenus[index]),
                  ),
              ),
            ],
          ),
        ),

        // RIGHT: CART
        Container(
          width: 350,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.centerLeft,
                child: const Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.amber),
                    SizedBox(width: 12),
                    Text("Pesanan Saat Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _cart.isEmpty 
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("Keranjang kosong", style: TextStyle(color: Colors.grey)),
                      ],
                    )) 
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_,__) => const Divider(),
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          title: Text(item.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.harga * item.quantity)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red), onPressed: () => _adjustQuantity(index, -1)),
                               Text(" ${item.quantity} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                               IconButton(icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.green), onPressed: () => _adjustQuantity(index, 1)),
                            ],
                          ),
                        );
                      },
                    ),
              ),
              // Cart Summary
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.grey[50], border: Border(top: BorderSide(color: Colors.grey[200]!))),
                child: Column(
                  children: [
                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                       const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_totalPrice), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                     ]),
                     const SizedBox(height: 16),
                     SizedBox(
                       width: double.infinity,
                       height: 48,
                       child: ElevatedButton.icon(
                         style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                         icon: const Icon(Icons.payment),
                         label: const Text("PROSES PESANAN", style: TextStyle(fontWeight: FontWeight.bold)),
                         onPressed: _cart.isEmpty ? null : _processCheckout,
                       ),
                     )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isActive) {
    return Chip(
      label: Text(label),
      backgroundColor: isActive ? Colors.amber : Colors.white,
      side: BorderSide(color: isActive ? Colors.amber : Colors.grey[300]!),
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    bool available = _isMenuAvailable(menu.idMenu);
    String reason = available ? "" : _getUnavailableReason(menu.idMenu);
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: available ? () => _addToCart(menu) : null,
      child: Opacity(
        opacity: available ? 1.0 : 0.6,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      width: double.infinity,
                      child: const Icon(Icons.coffee, size: 48, color: Colors.brown),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                        const SizedBox(height: 4),
                        Text(currencyFormat.format(menu.harga), style: TextStyle(color: Colors.brown[600], fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              if (!available)
                Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.red,
                      child: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
     return Container(
       padding: const EdgeInsets.all(24),
       color: Colors.white,
       width: double.infinity,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
           const SizedBox(height: 4),
           Text(subtitle, style: const TextStyle(color: Colors.grey)),
         ],
       ),
     );
  }
}
