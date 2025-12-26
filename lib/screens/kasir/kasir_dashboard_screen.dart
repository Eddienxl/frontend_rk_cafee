import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import '../../services/menu_service.dart';
import '../../services/order_service.dart';
import '../../services/bom_service.dart';
import '../../services/bahan_service.dart';
import '../../models/menu_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../models/bom_model.dart';
import '../../models/bahan_baku_model.dart';
import 'package:intl/intl.dart';

class KasirDashboardScreen extends StatefulWidget {
  const KasirDashboardScreen({super.key});

  @override
  State<KasirDashboardScreen> createState() => _KasirDashboardScreenState();
}

class _KasirDashboardScreenState extends State<KasirDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final MenuService _menuService = MenuService();
  final OrderService _orderService = OrderService();
  final BOMService _bomService = BOMService();
  final BahanService _bahanService = BahanService();
  
  // Data POST
  List<MenuModel> _menus = [];
  List<BOMModel> _boms = [];
  List<BahanBakuModel> _bahans = [];
  
  List<CartItemModel> _cart = [];
  bool _isLoading = true;
  
  // Data Status
  List<OrderModel> _activeOrders = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllData();
    // Auto refresh status pesanan setiap 30 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_tabController.index == 1) _fetchActiveOrders();
    });
    
    _tabController.addListener(() {
      if (_tabController.index == 1) _fetchActiveOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    try {
      final menus = await _menuService.getMenus();
      final boms = await _bomService.getBOM();
      final bahans = await _bahanService.getBahanBaku();
      
      if (mounted) {
        setState(() {
          _menus = menus; // Tampilkan semua, nanti difilter visual
          _boms = boms;
          _bahans = bahans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchActiveOrders() async {
    // Reuse endpoint kitchen sementara karena kasir juga butuh lihat status 'BARU', 'SEDANG DIBUAT', 'SELESAI'
    final orders = await _orderService.getKitchenOrders();
    if (mounted) {
      setState(() {
        _activeOrders = orders;
        // Sort: BARU -> SEDANG DIBUAT -> SELESAI
        _activeOrders.sort((a, b) {
           final statusScore = {'BARU': 1, 'SEDANG DIBUAT': 2, 'SELESAI': 3};
           int scoreA = statusScore[a.statusPesanan] ?? 4;
           int scoreB = statusScore[b.statusPesanan] ?? 4;
           return scoreA.compareTo(scoreB);
        });
      });
    }
  }

  // LOGIKA CEK STOK DI FRONTEND
  bool _isMenuAvailable(String menuId) {
    // 1. Cek flag manual dari backend
    final menu = _menus.firstWhere((m) => m.idMenu == menuId, orElse: () => MenuModel(idMenu: '', nama: '', harga: 0, kategori: '', isAvailable: false));
    if (!menu.isAvailable) return false;

    // 2. Cek Stok Bahan Baku via BOM
    // Cari BOM untuk menu ini
    final bomHeader = _boms.firstWhere(
      (b) => b.idMenu == menuId, 
      orElse: () => BOMModel(idMenu: '', namaMenu: '', resep: [])
    );

    // Jika tidak ada resep, anggap available (atau stok unlimited)
    if (bomHeader.resep.isEmpty) return true;

    // Cek setiap bahan
    for (var item in bomHeader.resep) {
      final bahan = _bahans.firstWhere(
        (b) => b.idBahan == item.idBahan, 
        orElse: () => BahanBakuModel(idBahan: '', nama: '', stokSaatIni: 0, stokMinimum: 0, satuan: '')
      );
      
      if (bahan.stokSaatIni < item.jumlahDibutuhkan) {
        return false; // Stok bahan ini habis
      }
    }

    return true; // Semua bahan cukup
  }
  
  String _getUnavailableReason(String menuId) {
     final bomHeader = _boms.firstWhere((b) => b.idMenu == menuId, orElse: () => BOMModel(idMenu: '', namaMenu: '', resep: []));
     if (bomHeader.resep.isEmpty) return "Tidak Tersedia";

     for (var item in bomHeader.resep) {
       final bahan = _bahans.firstWhere((b) => b.idBahan == item.idBahan, orElse: () => BahanBakuModel(idBahan: '', nama: '', stokSaatIni: 0, stokMinimum: 0, satuan: ''));
       if (bahan.stokSaatIni < item.jumlahDibutuhkan) {
         return "Stok ${bahan.nama} Habis";
       }
     }
     return "Tidak Tersedia";
  }

  // --- LOGIC POS ---
  void _addToCart(MenuModel menu) {
    if (!_isMenuAvailable(menu.idMenu)) return;

    setState(() {
      final index = _cart.indexWhere((item) => item.idMenu == menu.idMenu);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItemModel(
          idMenu: menu.idMenu,
          namaMenu: menu.nama,
          harga: menu.harga,
        ));
      }
    });
  }

  void _adjustQuantity(int index, int delta) {
    setState(() {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
    });
  }

  double get _totalPrice => _cart.fold(0, (sum, item) => sum + (item.harga * item.quantity));

  Future<void> _processCheckout() async {
    if (_cart.isEmpty) return;
    
    // Konfirmasi
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
    
    // Perbarui stok lokal agar UI langsung update tanpa fetch ulang
    if (success) {
      await _fetchAllData(); // Fetch ulang untuk sync stok bahan terbaru dari BE
      if (mounted) {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan Berhasil!")));
        _tabController.animateTo(1); // Pindah ke tab status
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memproses pesanan. Cek stok backend.")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.brown,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.brown,
          tabs: const [
            Tab(icon: Icon(Icons.point_of_sale), text: "Buat Pesanan"),
            Tab(icon: Icon(Icons.receipt_long), text: "Status Pesanan"),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAllData),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPOSTab(),
          _buildStatusTab(),
        ],
      ),
    );
  }

  // --- TAB 1: POS ---
  Widget _buildPOSTab() {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    
    return Row(
      children: [
        // MENU GRID
        Expanded(
          flex: 2,
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _menus.length,
                  itemBuilder: (context, index) {
                    final menu = _menus[index];
                    final available = _isMenuAvailable(menu.idMenu);
                    final reason = available ? "" : _getUnavailableReason(menu.idMenu);

                    return GestureDetector(
                      onTap: available ? () => _addToCart(menu) : null,
                      child: Opacity(
                        opacity: available ? 1.0 : 0.5,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: available ? Colors.brown[50] : Colors.grey[200],
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      ),
                                      child: Icon(Icons.coffee, size: 50, color: available ? Colors.brown[200] : Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                                        Text(currencyFormat.format(menu.harga), style: TextStyle(color: Colors.brown[700])),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              if (!available)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        color: Colors.red,
                                        child: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // CART AREA
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(16), child: const Text("Pesanan Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Expanded(
                child: _cart.isEmpty 
                    ? const Center(child: Text("Belum ada item")) 
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(currencyFormat.format(item.harga * item.quantity)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => _adjustQuantity(index, -1)),
                                Text("${item.quantity}"),
                                IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => _adjustQuantity(index, 1)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.brown[50],
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Total"), 
                      Text(currencyFormat.format(_totalPrice), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
                      onPressed: _cart.isEmpty ? null : _processCheckout, 
                      child: const Text("PROSES PESANAN")
                    ))
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // --- TAB 2: STATUS PESANAN ---
  Widget _buildStatusTab() {
    if (_activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Tidak ada pesanan aktif", style: TextStyle(color: Colors.grey)),
            TextButton(onPressed: _fetchActiveOrders, child: const Text("Refresh"))
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeOrders.length,
      itemBuilder: (context, index) {
        final order = _activeOrders[index];
        Color statusColor = Colors.grey;
        if (order.statusPesanan == 'BARU') statusColor = Colors.blue;
        if (order.statusPesanan == 'SEDANG DIBUAT') statusColor = Colors.orange;
        if (order.statusPesanan == 'SELESAI') statusColor = Colors.green;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(Icons.receipt, color: statusColor),
            ),
            title: Text("Order #${order.idOrder}"),
            subtitle: Text("${order.items.length} Item • ${DateFormat('HH:mm').format(order.tanggal ?? DateTime.now())}"),
            trailing: Chip(
              label: Text(order.statusPesanan, style: const TextStyle(color: Colors.white, fontSize: 12)),
              backgroundColor: statusColor,
            ),
          ),
        );
      },
    );
  }
}
