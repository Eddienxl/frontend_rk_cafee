import 'package:flutter/material.dart';
import '../../services/menu_service.dart';
import '../../models/menu_model.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final MenuService _menuService = MenuService();
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<String> _categories = ['All', 'Coffee', 'Non Coffee', 'Tea', 'Food', 'Snacks', 'Add On'];

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    try {
      final menus = await _menuService.getMenus();
      if (mounted) {
        setState(() {
          _menus = menus;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditDialog({MenuModel? menu}) {
    final namaController = TextEditingController(text: menu?.nama ?? '');
    final hargaController = TextEditingController(text: menu?.harga.toString() ?? '');
    // Mapping current category to one of our target categories if possible, or use 'Food' as default
    String currentCat = menu?.kategori ?? 'Food';
    if (!_categories.contains(currentCat)) currentCat = 'Food';
    
    String tempCategory = currentCat;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(menu == null ? 'Tambah Menu' : 'Edit Menu', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Menu', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: tempCategory,
                    items: _categories.where((c) => c != 'All').map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (val) => tempCategory = val!,
                    decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037), foregroundColor: Colors.white),
                onPressed: () async {
                  if (namaController.text.isEmpty || hargaController.text.isEmpty) return;

                  Navigator.pop(context);
                  setState(() => _isLoading = true);

                  bool success;
                  int harga = int.tryParse(hargaController.text) ?? 0;

                  if (menu == null) {
                    success = await _menuService.createMenu(namaController.text, harga, tempCategory);
                  } else {
                    success = await _menuService.updateMenu(menu.idMenu, namaController.text, harga, tempCategory);
                  }

                  if (success) {
                    _fetchMenus();
                  } else {
                    setState(() => _isLoading = false);
                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal simpan')));
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _deleteMenu(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Yakin ingin menghapus ${menu.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await _menuService.deleteMenu(menu.idMenu);
              if (success) {
                _fetchMenus();
              } else {
                setState(() => _isLoading = false);
                if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal hapus')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MenuModel> filteredMenus = _menus.where((m) {
      final matchSearch = m.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _selectedCategory == 'All' || m.kategori.toLowerCase() == _selectedCategory.toLowerCase();
      return matchSearch && matchCat;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      // We keep Scaffold for internal FAB, but Dashboard handles the Top AppBar.
      // Wait, Dashboard has its own AppBar. If we return Scaffold here, we get nested layers.
      // But the User wants FAB. I'll use Scaffold with transparent background.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                Expanded(
                  child: filteredMenus.isEmpty
                      ? const Center(child: Text("Menu tidak ditemukan"))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Change to 3 columns
                            childAspectRatio: 0.60, // Adjusted for 3 columns
                            crossAxisSpacing: 12, 
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredMenus.length,
                          itemBuilder: (context, index) {
                            return _buildMenuCard(filteredMenus[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditDialog(),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Cari menu...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
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
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    selectedColor: const Color(0xFF5D4037),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Slightly smaller radius
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showActionDialog(menu),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown[50], 
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(Icons.coffee, size: 30, color: Colors.brown[300]), // Smaller icon
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      menu.nama,
                      maxLines: 2, // Allow 2 lines for 3-column layout
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12), // Reduced font
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormatter.format(menu.harga),
                      style: GoogleFonts.inter(color: Colors.brown[700], fontWeight: FontWeight.bold, fontSize: 11), // Reduced font
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(MenuModel menu) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Edit Menu'),
              onTap: () {
                Navigator.pop(context);
                _showAddEditDialog(menu: menu);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Menu'),
              onTap: () {
                Navigator.pop(context);
                _deleteMenu(menu);
              },
            ),
          ],
        ),
      ),
    );
  }
}
