import 'package:flutter/material.dart';
import 'package:frontend_rk_cafee/services/owner_service.dart';

class BahanBakuScreen extends StatefulWidget {
  const BahanBakuScreen({super.key});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen> {
  final OwnerService _ownerService = OwnerService();
  List<Map<String, dynamic>> _bahanBaku = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBahanBaku();
  }

  Future<void> _fetchBahanBaku() async {
    try {
      final data = await _ownerService.getBahanBaku();
      if (mounted) {
        setState(() {
          // Mapping data backend ke UI model sederhana
          _bahanBaku = data.map((item) => {
            'nama': item['nama_bahan'],
            'stok': (item['sisa_stok'] ?? 0), 
            'satuan': item['satuan'],
            'min': 5, // Default min stok (belum ada di BE)
          }).toList();
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
      appBar: AppBar(
        title: const Text('Kelola Bahan Baku'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D4037),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _bahanBaku.isEmpty 
              ? const Center(child: Text("Belum ada data bahan baku"))
              : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text("Stok Menipis", style: TextStyle(color: Colors.red)),
                          Text("${_bahanBaku.where((b) => b['stok'] < b['min']).length} Item", 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text("Total Item", style: TextStyle(color: Colors.green)),
                          Text("${_bahanBaku.length} Item", 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // List Bahan Baku
            Expanded(
              child: ListView.separated(
                itemCount: _bahanBaku.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = _bahanBaku[index];
                  final stok = (item['stok'] is num) ? item['stok'] : double.tryParse(item['stok'].toString()) ?? 0;
                  final min = (item['min'] is num) ? item['min'] : double.tryParse(item['min'].toString()) ?? 0;
                  final isLow = stok < min;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLow ? Colors.red[100] : Colors.blue[100],
                      child: Icon(Icons.inventory_2, color: isLow ? Colors.red : Colors.blue),
                    ),
                    title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Min: $min ${item['satuan']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("$stok ${item['satuan']}", 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: isLow ? Colors.red : Colors.black
                          )
                        ),
                        // const SizedBox(width: 8),
                        // IconButton(icon: const Icon(Icons.edit_square), onPressed: () {}),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
