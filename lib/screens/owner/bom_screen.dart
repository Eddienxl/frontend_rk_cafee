import 'package:flutter/material.dart';
import '../../services/bom_service.dart';
import '../../services/menu_service.dart';
import '../../services/bahan_service.dart';
import '../../models/menu_model.dart';
import '../../models/bahan_baku_model.dart';
import '../../models/bom_model.dart';
import 'package:google_fonts/google_fonts.dart';

class BOMScreen extends StatefulWidget {
  const BOMScreen({super.key});

  @override
  State<BOMScreen> createState() => _BOMScreenState();
}

class _BOMScreenState extends State<BOMScreen> {
  final BOMService _bomService = BOMService();
  final MenuService _menuService = MenuService();
  final BahanService _bahanService = BahanService();
  
  List<BOMModel> _bomList = [];
  List<MenuModel> _menus = [];
  List<BahanBakuModel> _bahanBaku = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final bomData = await _bomService.getBOM();
      final menuData = await _menuService.getMenus();
      final bahanData = await _bahanService.getBahanBaku();

      if (mounted) {
        setState(() {
          _bomList = bomData;
          _menus = menuData;
          _bahanBaku = bahanData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    if (_menus.isEmpty || _bahanBaku.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Menu atau Bahan Baku belum tersedia")));
      return;
    }

    String? selectedMenuId = _menus.first.idMenu;
    String? selectedBahanId = _bahanBaku.first.idBahan;
    final jumlahCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSt) {
            return AlertDialog(
              title: Text("Atur Resep", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMenuId,
                      decoration: const InputDecoration(labelText: "Pilih Menu", border: OutlineInputBorder()),
                      items: _menus.map((m) => DropdownMenuItem(value: m.idMenu, child: Text(m.nama))).toList(),
                      onChanged: (v) => setSt(() => selectedMenuId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedBahanId,
                      decoration: const InputDecoration(labelText: "Pilih Bahan Baku", border: OutlineInputBorder()),
                      items: _bahanBaku.map((b) => DropdownMenuItem(value: b.idBahan, child: Text("${b.nama} (${b.satuan})"))).toList(),
                      onChanged: (v) => setSt(() => selectedBahanId = v),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: jumlahCtrl,
                      decoration: const InputDecoration(labelText: "Jumlah Kebutuhan", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (selectedMenuId == null || selectedBahanId == null || jumlahCtrl.text.isEmpty) return;
                    Navigator.pop(context);
                    final success = await _bomService.createBOM(selectedMenuId!, selectedBahanId!, double.tryParse(jumlahCtrl.text) ?? 0);
                    if (success) _fetchData();
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          }
        );
      },
    );
  }

  void _deleteItem(String idBom, String namaBahan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Item"),
        content: Text("Hapus $namaBahan dari komposisi menu ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _bomService.deleteBOM(idBom);
              if (success) _fetchData();
            },
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bomList.length,
              itemBuilder: (context, index) {
                final item = _bomList[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ExpansionTile(
                    shape: const Border(),
                    leading: const Icon(Icons.menu_book, color: Color(0xFF5D4037)),
                    title: Text(item.namaMenu, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text("${item.resep.length} Komposisi Bahan", style: const TextStyle(fontSize: 12)),
                    children: item.resep.map<Widget>((r) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                        title: Text(r.namaBahan, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${r.jumlahDibutuhkan} ${r.satuan}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                            if (r.idBom != null)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                                onPressed: () => _deleteItem(r.idBom!, r.namaBahan),
                              )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF5D4037),
        label: const Text("Tambah Resep", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add_task, color: Colors.white),
      ),
    );
  }
}
