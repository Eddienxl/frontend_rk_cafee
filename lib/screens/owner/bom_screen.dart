import 'package:flutter/material.dart';
import 'package:frontend_rk_cafee/services/owner_service.dart';
import 'package:frontend_rk_cafee/models/menu_model.dart';

class BOMScreen extends StatefulWidget {
  const BOMScreen({super.key});

  @override
  State<BOMScreen> createState() => _BOMScreenState();
}

class _BOMScreenState extends State<BOMScreen> {
  final OwnerService _ownerService = OwnerService();
  List<Map<String, dynamic>> _bomList = [];
  List<MenuModel> _menus = [];
  List<Map<String, dynamic>> _bahanBaku = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final bomData = await _ownerService.getBOM();
      final menuData = await _ownerService.getMenus();
      final bahanData = await _ownerService.getBahanBaku();

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

  // --- ADD INGREDIENT DIALOG ---
  void _showAddDialog() {
    if (_menus.isEmpty || _bahanBaku.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Menu atau Bahan Baku kosong")));
      return;
    }

    String? selectedMenuId = _menus.first.id;
    String? selectedBahanId = _bahanBaku.first['id_bahan'];
    final jumlahCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Tambah Resep"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMenuId,
                      decoration: const InputDecoration(labelText: "Pilih Menu"),
                      items: _menus.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nama))).toList(),
                      onChanged: (v) => setStateDialog(() => selectedMenuId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedBahanId,
                      decoration: const InputDecoration(labelText: "Pilih Bahan Baku"),
                      items: _bahanBaku.map((b) => DropdownMenuItem<String>(
                        value: b['id_bahan'], 
                        child: Text("${b['nama_bahan']} (${b['satuan']})")
                      )).toList(),
                      onChanged: (v) => setStateDialog(() => selectedBahanId = v),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: jumlahCtrl,
                      decoration: const InputDecoration(labelText: "Jumlah Dibutuhkan"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMenuId == null || selectedBahanId == null || jumlahCtrl.text.isEmpty) return;
                    Navigator.pop(context);

                    final success = await _ownerService.createBOM(
                      selectedMenuId!,
                      selectedBahanId!,
                      double.tryParse(jumlahCtrl.text) ?? 0
                    );

                    if (success) _fetchData();
                    else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menambah resep")));
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
  
  // --- DELETE ITEM ---
  void _deleteItem(String idBom, String namaBahan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Item Resep"),
        content: Text("Hapus $namaBahan dari resep ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _ownerService.deleteBOM(idBom);
               if (success) _fetchData();
              else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal hapus item")));
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
      appBar: AppBar(
        title: const Text('Kelola Resep (BOM)'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D4037),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bomList.isEmpty
              ? const Center(child: Text("Belum ada data resep"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bomList.length,
                  itemBuilder: (context, index) {
                    final menuMap = _bomList[index];
                    final resepList = (menuMap['resep'] as List? ?? []);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ExpansionTile(
                        title: Text(menuMap['nama_menu'] ?? 'Menu Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${resepList.length} Bahan Baku"),
                        children: resepList.map<Widget>((r) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.circle, size: 8, color: Colors.brown),
                            title: Text(r['nama_bahan'] ?? '-'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${r['jumlah_dibutuhkan']} ${r['satuan']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                // Only show delete if id_bom exists (it should now)
                                if (r['id_bom'] != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.grey, size: 18),
                                    onPressed: () => _deleteItem(r['id_bom'], r['nama_bahan'] ?? 'Item'),
                                  )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF5D4037),
        child: const Icon(Icons.add),
      ),
    );
  }
}
