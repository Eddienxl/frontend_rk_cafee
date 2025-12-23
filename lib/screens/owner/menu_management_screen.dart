import 'package:flutter/material.dart';
import 'package:frontend_rk_cafee/services/owner_service.dart';
import 'package:frontend_rk_cafee/services/data_service.dart';
import 'package:frontend_rk_cafee/models/menu_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

[ignoring loop detection]

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final DataService _dataService = DataService();
  final OwnerService _ownerService = OwnerService();
  
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  
  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    
    try {
      final menus = await _dataService.getMenus();
      setState(() {
        _menus = menus;
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddEditDialog({MenuModel? menu}) {
    final namaController = TextEditingController(text: menu?.nama ?? '');
    final hargaController = TextEditingController(text: menu?.harga.toString() ?? '');
    String selectedKategori = menu?.kategori ?? 'MAKANAN'; // Default
    // Pastikan kategori valid
    if (!['MAKANAN', 'MINUMAN', 'SNACK'].contains(selectedKategori)) {
       selectedKategori = 'MAKANAN'; 
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(menu == null ? 'Tambah Menu' : 'Edit Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Menu'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga (Rp)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedKategori,
              items: ['MAKANAN', 'MINUMAN', 'SNACK']
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (val) => selectedKategori = val!,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              bool success;
              if (menu == null) {
                // Add
                success = await _ownerService.createMenu(
                  namaController.text,
                  int.tryParse(hargaController.text) ?? 0,
                  selectedKategori
                );
              } else {
                // Edit
                success = await _ownerService.updateMenu(
                  menu.id,
                  namaController.text,
                  int.tryParse(hargaController.text) ?? 0,
                  selectedKategori
                );
              }

              if (success) _fetchData();
              else {
                 setState(() => _isLoading = false);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal simpan menu')));
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
        content: Text('Yakin hapus ${menu.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final success = await _ownerService.deleteMenu(menu.id);
              if (success) _fetchData();
              else {
                 setState(() => _isLoading = false);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal hapus')));
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
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Menu'),
        automaticallyImplyLeading: false, // Karena embed di dashboard (kadang)
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _menus.length,
              itemBuilder: (context, index) {
                final menu = _menus[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.fastfood)),
                  title: Text(menu.nama),
                  subtitle: Text("${menu.kategori} • ${currencyFormat.format(menu.harga)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddEditDialog(menu: menu),
                      ),
                      // DELETE BUTTON (ALWAYS VISIBLE FOR OWNER APP)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMenu(menu),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEditDialog(),
      ),
    );
  }
}
