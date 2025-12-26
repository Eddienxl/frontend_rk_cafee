import 'package:flutter/material.dart';
import '../../services/menu_service.dart';
import '../../services/order_service.dart';
import '../../services/bom_service.dart';
import '../../services/bahan_service.dart';
import '../../models/menu_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/bom_model.dart';
import '../../models/bahan_baku_model.dart';
import 'package:intl/intl.dart';

class KasirPosScreen extends StatefulWidget {
  const KasirPosScreen({super.key});

  @override
  State<KasirPosScreen> createState() => _KasirPosScreenState();
}

class _KasirPosScreenState extends State<KasirPosScreen> {
  final MenuService _menuService = MenuService();
  final OrderService _orderService = OrderService();
  final BOMService _bomService = BOMService();
  final BahanService _bahanService = BahanService();

  List<MenuModel> _menus = [];
  List<BOMModel> _boms = [];
  List<BahanBakuModel> _bahans = [];
  List<CartItemModel> _cart = [];
  
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final menus = await _menuService.getMenus();
      final boms = await _bomService.getBOM();
      final bahans = await _bahanService.getBahanBaku();

      if (mounted) {
        setState(() {
          _menus = menus;
          _boms = boms;
          _bahans = bahans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
       if (bahan.stokSaatIni < item.jumlahDibutuhkan) return "Stok ${bahan.nama} Habis"; // Shorten message
     }
     return "Tidak Tersedia";
  }

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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${menu.nama} ditambahkan ke keranjang"),
      duration: const Duration(seconds: 1),
    ));
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
             final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
             double totalPrice = _cart.fold(0, (sum, item) => sum + (item.harga * item.quantity));

             return Container(
               height: MediaQuery.of(context).size.height * 0.7,
               padding: const EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Keranjang Pesanan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                       IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                     ],
                   ),
                   const Divider(),
                   Expanded(
                     child: _cart.isEmpty 
                      ? const Center(child: Text("Keranjang masih kosong.")) 
                      : ListView.separated(
                        itemCount: _cart.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return ListTile(
                            title: Text(item.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(currencyFormat.format(item.harga * item.quantity)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _cart[index].quantity--;
                                      if (_cart[index].quantity <= 0) _cart.removeAt(index);
                                    });
                                    setModalState(() {}); // Update modal UI
                                  },
                                ),
                                Text("${item.quantity}", style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      _cart[index].quantity++;
                                    });
                                    setModalState(() {}); // Update modal UI
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                   ),
                   const Divider(),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       Text(currencyFormat.format(totalPrice), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
                     ],
                   ),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.brown,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     ),
                     onPressed: _cart.isEmpty ? null : () async {
                       Navigator.pop(context); // Close modal first
                       await _processCheckout();
                     },
                     child: const Text("PROSES PESANAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                   )
                 ],
               ),
             );
          },
        );
      },
    );
  }

  Future<void> _processCheckout() async {
     setState(() => _isLoading = true);
     final success = await _orderService.createOrder(_cart);

     if (success) {
       await _fetchData(); // Refresh stock
       if (mounted) {
         setState(() => _cart.clear());
         // Show success dialog
         showDialog(context: context, builder: (_) => AlertDialog(
           title: const Text("Sukses"),
           content: const Text("Pesanan berhasil dibuat!"),
           actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
         ));
       }
     } else {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuat pesanan.")));
       }
     }
     setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final filteredMenus = _menus.where((m) => m.nama.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Cari Menu...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          
          // Menu List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      childAspectRatio: 0.65, // More vertical space for lines
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredMenus.length,
                    itemBuilder: (context, index) {
                      final menu = filteredMenus[index];
                      final available = _isMenuAvailable(menu.idMenu);
                      final reason = available ? "" : _getUnavailableReason(menu.idMenu);

                      return GestureDetector(
                        onTap: available ? () => _addToCart(menu) : null,
                        child: Opacity(
                          opacity: available ? 1.0 : 0.6,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3, // Give image 60% height
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: available ? Colors.brown[100] : Colors.grey[300],
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Icon(Icons.coffee, size: 50, color: available ? Colors.brown : Colors.grey),
                                        if (!available)
                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              color: Colors.red.withOpacity(0.8),
                                              child: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2, // Give text 40% height
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          menu.nama, 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                                          maxLines: 2, // Allow 2 lines
                                          overflow: TextOverflow.ellipsis
                                        ),
                                        const SizedBox(height: 4),
                                        Text(currencyFormat.format(menu.harga), style: TextStyle(color: Colors.brown[800], fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCartSheet,
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.shopping_cart),
        label: Text("${_cart.fold(0, (sum, item) => sum + item.quantity)} Item"),
      ),
    );
  }
}
