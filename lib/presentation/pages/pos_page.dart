import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/file_upload_service.dart';
import '../../data/models/menu_model.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/menu_card.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/custom_button.dart';
import 'inventory_page.dart';
import 'kitchen_page.dart';
import 'bom_page.dart';
import 'laporan_page.dart';
import 'login_page.dart';

/// Halaman POS utama dengan layout mobile-friendly
/// Design pattern: Bottom Navigation + Full screen views
class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final _searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().fetchMenus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildMenuSection(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildCartFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// AppBar mobile
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(Icons.coffee, size: 28),
          SizedBox(width: 8),
          Text(AppConstants.appName),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<MenuProvider>().fetchMenus(),
        ),
        // Add menu (owner only)
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.currentUser?.isOwner ?? false) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddMenuDialog(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Drawer untuk navigasi menu lainnya
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppConstants.primaryColor),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    auth.currentUser?.username[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                accountName: Text(auth.currentUser?.username ?? 'User'),
                accountEmail: Text(
                  'Role: ${auth.currentUser?.role.name.toUpperCase() ?? '-'}',
                ),
              );
            },
          ),
          _buildDrawerItem(Icons.point_of_sale, 'POS', true, () => Navigator.pop(context)),
          _buildDrawerItem(Icons.inventory_2, 'Stok Bahan', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage()));
          }),
          _buildDrawerItem(Icons.kitchen, 'Dapur', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const KitchenPage()));
          }),
          _buildDrawerItem(Icons.receipt_long, 'Resep (BOM)', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BomPage()));
          }),
          _buildDrawerItem(Icons.analytics, 'Laporan', false, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanPage()));
          }),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Keluar', false, () async {
            await context.read<AuthProvider>().logout();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: isActive ? AppConstants.primaryColor : Colors.grey[700]),
      title: Text(title, style: TextStyle(
        color: isActive ? AppConstants.primaryColor : Colors.black87,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      )),
      selected: isActive,
      onTap: onTap,
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(0, Icons.restaurant_menu, 'Menu'),
            const SizedBox(width: 48), // Space for FAB
            _buildBottomNavItem(1, Icons.kitchen, 'Dapur'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const KitchenPage()));
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? AppConstants.primaryColor : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppConstants.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Floating Action Button untuk Cart
  Widget _buildCartFAB() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return FloatingActionButton(
          backgroundColor: AppConstants.primaryColor,
          onPressed: () => _showCartBottomSheet(),
          child: Badge(
            isLabelVisible: cart.itemCount > 0,
            label: Text('${cart.itemCount}'),
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
        );
      },
    );
  }

  /// Section Menu List
  Widget _buildMenuSection() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Header dengan search dan filter
          _buildMenuHeader(),
          // Kategori tabs
          _buildKategoriTabs(),
          // Grid Menu
          Expanded(child: _buildMenuGrid()),
        ],
      ),
    );
  }

  Widget _buildMenuHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      color: Colors.white,
      child: SearchTextField(
        controller: _searchController,
        hintText: 'Cari menu...',
        onChanged: (value) {
          context.read<MenuProvider>().searchMenu(value);
        },
        onClear: () {
          context.read<MenuProvider>().searchMenu('');
        },
      ),
    );
  }

  Widget _buildKategoriTabs() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        return Container(
          height: 50,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
            itemCount: AppConstants.kategoriMenu.length,
            itemBuilder: (context, index) {
              final kategori = AppConstants.kategoriMenu[index];
              final isSelected = menuProvider.selectedKategori == kategori;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(kategori),
                  selected: isSelected,
                  onSelected: (_) => menuProvider.filterByKategori(kategori),
                  selectedColor: AppConstants.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  checkmarkColor: Colors.white,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuGrid() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        if (menuProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (menuProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(menuProvider.errorMessage!),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Coba Lagi',
                  onPressed: () => menuProvider.fetchMenus(),
                ),
              ],
            ),
          );
        }
        if (menuProvider.filteredMenus.isEmpty) {
          return const Center(child: Text('Tidak ada menu ditemukan'));
        }

        // Group menu berdasarkan kategori
        final groupedMenus = _groupMenusByCategory(menuProvider.filteredMenus);
        final sortedKategori = _getSortedCategories(groupedMenus.keys.toList());

        // Gunakan CustomScrollView untuk section dengan header
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              sliver: SliverMainAxisGroup(
                slivers: [
                  // Buat sliver untuk setiap kategori
                  for (final kategori in sortedKategori) ...[
                    // Header Kategori
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: AppConstants.paddingMedium,
                          bottom: AppConstants.paddingSmall,
                        ),
                        child: Text(
                          kategori,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Grid menu untuk kategori ini
                    SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.72, // Adjusted for 3 columns with 8 spacing
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final menu = groupedMenus[kategori]![index];
                          return MenuCard(
                            menu: menu,
                            onTap: () {
                              context.read<CartProvider>().addItem(menu);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${menu.namaMenu} ditambahkan'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            onEdit: (menu) => _showEditMenuDialog(menu),
                            onDelete: () => _showDeleteMenuDialog(menu),
                          );
                        },
                        childCount: groupedMenus[kategori]!.length,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Group menu berdasarkan kategori
  Map<String, List<MenuModel>> _groupMenusByCategory(List<MenuModel> menus) {
    final grouped = <String, List<MenuModel>>{};
    for (final menu in menus) {
      final kategori = menu.kategori ?? 'Lainnya';
      grouped.putIfAbsent(kategori, () => []).add(menu);
    }
    // Sort menu dalam setiap kategori berdasarkan nama
    grouped.forEach((_, menuList) {
      menuList.sort((a, b) => a.namaMenu.compareTo(b.namaMenu));
    });
    return grouped;
  }

  /// Urutkan kategori dengan order logis: Coffee, Non Coffee, Food, Add On, Lainnya
  List<String> _getSortedCategories(List<String> categories) {
    final categoryOrder = ['Coffee', 'Non Coffee', 'Food', 'Add On'];
    final sorted = <String>[];

    // Tambahkan kategori sesuai urutan yang ditentukan
    for (final cat in categoryOrder) {
      if (categories.contains(cat)) {
        sorted.add(cat);
      }
    }

    // Tambahkan kategori lainnya yang tidak ada di urutan (alphabetically)
    final remaining = categories.where((cat) => !sorted.contains(cat)).toList();
    remaining.sort();
    sorted.addAll(remaining);

    return sorted;
  }

  /// Bottom Sheet untuk Cart (Mobile-friendly)
  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Cart Header
                _buildCartSheetHeader(),
                // Cart Items
                Expanded(child: _buildCartSheetItems(scrollController)),
                // Cart Footer
                _buildCartSheetFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartSheetHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: AppConstants.primaryColor),
          const SizedBox(width: 8),
          const Text(
            'Keranjang',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Text(
                '${cart.itemCount} item',
                style: TextStyle(color: Colors.grey[600]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartSheetItems(ScrollController scrollController) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Keranjang kosong', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          itemCount: cart.items.length,
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return CartItemWidget(
              item: item,
              onIncrement: () => cart.incrementItem(item.menu.idMenu),
              onDecrement: () => cart.decrementItem(item.menu.idMenu),
              onRemove: () => cart.removeItem(item.menu.idMenu),
            );
          },
        );
      },
    );
  }

  Widget _buildCartSheetFooter() {
    return Consumer2<CartProvider, OrderProvider>(
      builder: (context, cart, orderProvider, _) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 16)),
                    Text(
                      cart.totalPriceFormatted,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeXLarge,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Batal',
                        variant: ButtonVariant.outlined,
                        onPressed: cart.isEmpty ? null : () {
                          cart.clearCart();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'Checkout',
                        isLoading: orderProvider.isLoading,
                        onPressed: cart.isEmpty ? null : () => _handleCheckout(),
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCheckout() async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();

    if (cart.isEmpty) return;

    final success = await orderProvider.createOrderFromCart(
      cartItems: cart.items,
      idUser: authProvider.currentUser!.idUser,
    );

    if (success && mounted) {
      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order berhasil dibuat!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } else if (mounted && orderProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage!),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _showAddMenuDialog() {
    final _idController = TextEditingController();
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    String _selectedKategori = AppConstants.kategoriMenu.isNotEmpty ? AppConstants.kategoriMenu[0] : 'Coffee';
    String? _uploadedImageUrl;
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Menu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(controller: _idController, hintText: 'ID Menu (unik)'),
                    const SizedBox(height: 8),
                    CustomTextField(controller: _nameController, hintText: 'Nama Menu'),
                    const SizedBox(height: 8),
                    CustomTextField(controller: _priceController, hintText: 'Harga', keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedKategori,
                      items: AppConstants.kategoriMenu.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _selectedKategori = v); },
                      decoration: const InputDecoration(labelText: 'Kategori'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Foto Menu *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    _uploadedImageUrl == null
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.image),
                            label: _isUploading ? const Text('Uploading...') : const Text('Upload Foto'),
                            onPressed: _isUploading ? null : () async {
                              setState(() => _isUploading = true);
                              final imageUrl = await FileUploadService.uploadImageFile();
                              setState(() {
                                _uploadedImageUrl = imageUrl;
                                _isUploading = false;
                              });
                              if (imageUrl != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Foto berhasil diupload')),
                                );
                              }
                            },
                          )
                        : Column(
                            children: [
                              Container(
                                width: 200,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(_uploadedImageUrl!, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Ganti Foto'),
                                onPressed: () async {
                                  setState(() => _isUploading = true);
                                  final imageUrl = await FileUploadService.uploadImageFile();
                                  setState(() {
                                    if (imageUrl != null) _uploadedImageUrl = imageUrl;
                                    _isUploading = false;
                                  });
                                },
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: _isUploading || _uploadedImageUrl == null ? null : () async {
                    final id = _idController.text.trim();
                    final name = _nameController.text.trim();
                    final harga = double.tryParse(_priceController.text.trim()) ?? 0.0;
                    final kategori = _selectedKategori;

                    if (id.isEmpty || name.isEmpty || _uploadedImageUrl == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID, Nama, dan Foto wajib diisi')),
                      );
                      return;
                    }

                    final body = {
                      'id_menu': id,
                      'nama_menu': name,
                      'harga': harga,
                      'kategori': kategori,
                      'status_tersedia': true,
                      'image_url': _uploadedImageUrl,
                    };

                    try {
                      final success = await context.read<MenuProvider>().createMenu(body);
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu berhasil dibuat')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal membuat menu')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditMenuDialog(MenuModel menu) {
    final _nameController = TextEditingController(text: menu.namaMenu);
    final _priceController = TextEditingController(text: menu.harga.toString());
    String _selectedKategori = menu.kategori ?? AppConstants.kategoriMenu.first;
    String? _newImageUrl = menu.imageUrl;
    bool _isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Menu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ID: ${menu.idMenu}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 12),
                    CustomTextField(controller: _nameController, hintText: 'Nama Menu'),
                    const SizedBox(height: 8),
                    CustomTextField(controller: _priceController, hintText: 'Harga', keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedKategori,
                      items: AppConstants.kategoriMenu.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                      onChanged: (v) { if (v != null) setState(() => _selectedKategori = v); },
                      decoration: const InputDecoration(labelText: 'Kategori'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Foto Menu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    if (_newImageUrl != null)
                      Container(
                        width: 200,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(_newImageUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: _isUploading 
                        ? const Text('Uploading...') 
                        : Text(_newImageUrl != null ? 'Ganti Foto' : 'Upload Foto'),
                      onPressed: _isUploading ? null : () async {
                        setState(() => _isUploading = true);
                        final imageUrl = await FileUploadService.uploadImageFile();
                        setState(() {
                          if (imageUrl != null) _newImageUrl = imageUrl;
                          _isUploading = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: _isUploading ? null : () async {
                    final name = _nameController.text.trim();
                    final harga = double.tryParse(_priceController.text.trim()) ?? 0.0;
                    final kategori = _selectedKategori;

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama menu wajib diisi')),
                      );
                      return;
                    }

                    final body = {
                      'nama_menu': name,
                      'harga': harga,
                      'kategori': kategori,
                      if (_newImageUrl != null) 'image_url': _newImageUrl,
                    };

                    try {
                      final success = await context.read<MenuProvider>().updateMenu(menu.idMenu, body);
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Menu berhasil diupdate')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal update menu')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteMenuDialog(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Menu'),
          content: Text('Apakah Anda yakin ingin menghapus menu "${menu.namaMenu}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final success = await context.read<MenuProvider>().deleteMenu(menu.idMenu);
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menu berhasil dihapus')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal hapus menu')),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

