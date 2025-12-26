import 'package:flutter/material.dart';
import '../../services/menu_service.dart';
import '../../services/order_service.dart';
import '../../models/menu_model.dart';
import '../../models/cart_item_model.dart';
import 'package:intl/intl.dart';

class KasirDashboardScreen extends StatefulWidget {
  const KasirDashboardScreen({super.key});

  @override
  State<KasirDashboardScreen> createState() => _KasirDashboardScreenState();
}

class _KasirDashboardScreenState extends State<KasirDashboardScreen> {
  final MenuService _menuService = MenuService();
  final OrderService _orderService = OrderService();
  
  List<MenuModel> _menus = [];
  List<CartItemModel> _cart = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    final menus = await _menuService.getMenus();
    if (mounted) {
      setState(() {
        _menus = menus.where((m) => m.isAvailable).toList(); // Only show available menus
        _isLoading = false;
      });
    }
  }

  void _addToCart(MenuModel menu) {
    setState(() {
      final index = _cart.indexWhere((item) => item.idMenu == menu.id);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItemModel(
          idMenu: menu.id,
          namaMenu: menu.nama,
          harga: menu.harga,
        ));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
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

    // Show Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Pesanan"),
        content: Text("Total Pembayaran: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_totalPrice)}.\nProses pesanan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Proses")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await _orderService.createOrder(_cart);
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan Berhasil Dibuat!")));
        setState(() {
          _cart.clear(); // Clear cart after success
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuat pesanan.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir - Point of Sale"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          )
        ],
      ),
      body: Row(
        children: [
          // LEFT SIDE: MENU GRID
          Expanded(
            flex: 2,
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _menus.length,
                    itemBuilder: (context, index) {
                      final menu = _menus[index];
                      return GestureDetector(
                        onTap: () => _addToCart(menu),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.brown[50],
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Icon(Icons.coffee, size: 50, color: Colors.brown[200]), // Placeholder
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(currencyFormat.format(menu.harga), style: TextStyle(color: Colors.brown[700])),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // RIGHT SIDE: CART
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.brown[50],
                  width: double.infinity,
                  child: const Text("Keranjang Pesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _cart.isEmpty 
                      ? const Center(child: Text("Keranjang Kosong")) 
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          separatorBuilder: (_, __) => const Divider(),
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(currencyFormat.format(item.harga * item.quantity), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                IconButton(onPressed: () => _adjustQuantity(index, -1), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                                Text("${item.quantity}"),
                                IconButton(onPressed: () => _adjustQuantity(index, 1), icon: const Icon(Icons.add_circle_outline, size: 20)),
                              ],
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.brown[900],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(color: Colors.white, fontSize: 18)),
                          Text(currencyFormat.format(_totalPrice), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _cart.isEmpty ? null : _processCheckout,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                          child: const Text("PROSES PESANAN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
