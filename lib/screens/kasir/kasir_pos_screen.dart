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
import 'package:google_fonts/google_fonts.dart';

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
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Coffee', 'Non Coffee', 'Tea', 'Food', 'Snacks', 'Add On'];

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
       if (bahan.stokSaatIni < item.jumlahDibutuhkan) return "Stok ${bahan.nama} Habis"; 
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
      backgroundColor: const Color(0xFF5D4037),
      content: Text("${menu.nama} ditambahkan ke keranjang", style: GoogleFonts.inter(color: Colors.white)),
      duration: const Duration(seconds: 1),
    ));
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
             final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
             double totalPrice = _cart.fold(0, (sum, item) => sum + (item.harga * item.quantity));

             return Container(
               height: MediaQuery.of(context).size.height * 0.75,
               decoration: const BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
               ),
               padding: const EdgeInsets.all(20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("Ringkasan Pesanan", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))),
                       IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Expanded(
                     child: _cart.isEmpty 
                      ? Center(child: Text("Keranjang kosong ☕", style: GoogleFonts.inter(color: Colors.grey))) 
                      : ListView.separated(
                        itemCount: _cart.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.brown[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.namaMenu, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(currencyFormat.format(item.harga), style: GoogleFonts.inter(color: Colors.brown, fontSize: 14)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _cart[index].quantity--;
                                          if (_cart[index].quantity <= 0) _cart.removeAt(index);
                                        });
                                        setModalState(() {});
                                      },
                                    ),
                                    Text("${item.quantity}", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                      onPressed: () {
                                        setState(() {
                                          _cart[index].quantity++;
                                        });
                                        setModalState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                   ),
                   const Divider(height: 32),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("Total Pembayaran", style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700])),
                       Text(currencyFormat.format(totalPrice), style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))),
                     ],
                   ),
                   const SizedBox(height: 24),
                   ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF5D4037),
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 18),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       elevation: 0,
                     ),
                     onPressed: _cart.isEmpty ? null : () async {
                       Navigator.pop(context); 
                       await _processCheckout();
                     },
                     child: Text("KONFIRMASI PESANAN", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
       await _fetchData(); 
       if (mounted) {
         setState(() => _cart.clear());
         showDialog(context: context, builder: (_) => AlertDialog(
           title: Text("Sukses", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
           content: Text("Pesanan berhasil dikirim ke Barista!", style: GoogleFonts.inter()),
           actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
         ));
       }
     } else {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan saat membuat pesanan.")));
       }
     }
     setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    
    final filteredMenus = _menus.where((m) {
      final matchesSearch = m.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || m.kategori.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Cari Menu...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF5D4037)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF3EFEF),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat, style: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedCategory = cat),
                          selectedColor: const Color(0xFF5D4037),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : filteredMenus.isEmpty
                  ? Center(child: Text("Menu tidak ditemukan", style: GoogleFonts.inter(color: Colors.grey)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        childAspectRatio: 0.60, 
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
                              elevation: 2,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: available ? Colors.brown[50] : Colors.grey[200],
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Center(child: Icon(Icons.coffee, size: 30, color: available ? Colors.brown[300] : Colors.grey)),
                                          if (!available)
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.8),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            menu.nama, 
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                                            maxLines: 2, 
                                            overflow: TextOverflow.ellipsis
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            currencyFormat.format(menu.harga), 
                                            style: GoogleFonts.inter(color: Colors.brown[700], fontWeight: FontWeight.bold, fontSize: 11)
                                          ),
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
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.shopping_bag_outlined),
        label: Text(
          "${_cart.fold(0, (sum, item) => sum + item.quantity)} Item", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}
