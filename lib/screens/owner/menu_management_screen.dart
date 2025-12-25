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
                  childAspectRatio: 0.65, // Card lebih tinggi (sempit tapi muat konten)
                  crossAxisSpacing: 12, // Spacing sedikit rapat
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // IMAGE PLACEHOLDER
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  menu.kategori == 'MINUMAN' ? Icons.local_cafe : Icons.restaurant,
                  size: 32, // Smaller icon
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
          // INFO
          Expanded(
            flex: 3, // Give more space for text
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Smaller padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.nama,
                    maxLines: 2, // Allow 2 lines
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // Smaller font
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(menu.harga),
                    style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () => _showAddEditDialog(menu: menu),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.edit, size: 16, color: Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _deleteMenu(menu),
                         child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.delete, size: 16, color: Colors.red),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
