import 'package:flutter/material.dart';
import 'package:frontend_rk_cafee/services/owner_service.dart';
import 'package:frontend_rk_cafee/models/menu_model.dart';
import 'package:intl/intl.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final OwnerService _ownerService = OwnerService();
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    // Panggil service (yang sudah didummikan)
    try {
      final menus = await _ownerService.getMenus();
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
    String selectedKategori = menu?.kategori ?? 'MAKANAN';
    final kategoris = ['MAKANAN', 'MINUMAN', 'SNACK'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(menu == null ? 'Tambah Menu' : 'Edit Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Menu', prefixIcon: Icon(Icons.fastfood)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga', prefixIcon: Icon(Icons.attach_money)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedKategori,
              items: kategoris.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
              onChanged: (val) => selectedKategori = val!,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              // Simple validation
              if (namaController.text.isEmpty || hargaController.text.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);

              bool success;
              int harga = int.tryParse(hargaController.text) ?? 0;

              if (menu == null) {
                success = await _ownerService.createMenu(namaController.text, harga, selectedKategori);
              } else {
                success = await _ownerService.updateMenu(menu.id, namaController.text, harga, selectedKategori);
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
      ),
    );
  }

  void _deleteMenu(MenuModel menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Hapus ${menu.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await _ownerService.deleteMenu(menu.id);
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kelola Menu'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D4037),
        elevation: 0,
        leading: const SizedBox(), // Hide manual back button, use Dashboard logic if embedded
        // Wait, if embedded, AppBar is confusing. But we're in 'Refined UI'.
        // Let's assume standalone mode for child screens for now.
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 Kolom
                  childAspectRatio: 0.60, // Card lebih tinggi lagi agar harga aman
                  crossAxisSpacing: 12, 
                  mainAxisSpacing: 12,
                ),
                itemCount: _menus.length,
                itemBuilder: (context, index) {
                  final menu = _menus[index];
                  return _buildMenuCard(menu);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditDialog(),
      ),
    );
  }

  Widget _buildMenuCard(MenuModel menu) {
    // Logic Inisial (Max 2 huruf)
    // "Kopi Susu Gula Aren" -> "KS"
    // "Americano" -> "A"
    List<String> words = menu.nama.split(' ');
    String initials = '';
    if (words.isNotEmpty) {
      initials += words[0][0].toUpperCase();
      if (words.length > 1) {
        initials += words[1][0].toUpperCase();
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showActionDialog(menu), // Klik kartu untuk opsi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // IMAGE PLACEHOLDER (INITIALS)
            Expanded(
              flex: 1, // Kurangi porsi gambar biar imbang
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown[50], 
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF5D4037)
                    ),
                  ),
                ),
              ),
            ),
            // INFO
            Expanded(
              flex: 1, // Tambah porsi teks
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      menu.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(menu.harga),
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
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

  // Dialog Pilihan Aksi
  void _showActionDialog(MenuModel menu) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
