import 'package:flutter/material.dart';
import 'package:frontend_rk_cafee/services/owner_service.dart';

class BOMScreen extends StatefulWidget {
  const BOMScreen({super.key});

  @override
  State<BOMScreen> createState() => _BOMScreenState();
}

class _BOMScreenState extends State<BOMScreen> {
  final OwnerService _ownerService = OwnerService();
  List<Map<String, dynamic>> _bomList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBOM();
  }

  Future<void> _fetchBOM() async {
    try {
      final data = await _ownerService.getBOM();
      if (mounted) {
        setState(() {
          _bomList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft background
      appBar: AppBar(
        title: const Text('Resep & BOM'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D4037),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bomList.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada data resep",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bomList.length,
                  itemBuilder: (context, index) {
                    final item = _bomList[index];
                    final String namaMenu = item['nama_menu'] ?? 'Menu Tanpa Nama';
                    final List resep = item['resep'] ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        shape: const Border(), // Hilangkan border bawaan saat expand
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF5D4037).withOpacity(0.1),
                          child: const Icon(Icons.menu_book, color: Color(0xFF5D4037)),
                        ),
                        title: Text(
                          namaMenu,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        subtitle: Text("${resep.length} Bahan Baku"),
                        children: [
                          Divider(height: 1, color: Colors.grey[200]),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              children: resep.map<Widget>((bahan) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        bahan['nama_bahan'],
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        "${bahan['jumlah']} ${bahan['satuan']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        label: const Text("Buat Resep Baru", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Placeholder action
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur tambah resep akan segera hadir!')),
          );
        },
      ),
    );
  }
}
