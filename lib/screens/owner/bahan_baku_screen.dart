import 'package:flutter/material.dart';

class BahanBakuScreen extends StatefulWidget {
  const BahanBakuScreen({super.key});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen> {
  // Dummy Data Bahan Baku
  final List<Map<String, dynamic>> _bahanBaku = [
    {'nama': 'Biji Kopi Arabica', 'stok': 5.0, 'satuan': 'kg', 'min': 2.0},
    {'nama': 'Biji Kopi Robusta', 'stok': 1.5, 'satuan': 'kg', 'min': 2.0},
    {'nama': 'Susu UHT', 'stok': 12, 'satuan': 'liter', 'min': 5.0},
    {'nama': 'Gula Aren', 'stok': 3.0, 'satuan': 'kg', 'min': 1.0},
    {'nama': 'Sirup Vanilla', 'stok': 2, 'satuan': 'botol', 'min': 1.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sudah dihandle parent jika ini widget bagian dashboard
      // Tapi jika dipush navigator, butuh AppBar sendiri
      // Kita asumsikan ini widget mandiri yg bisa dipush
      body: Padding(
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
                  final isLow = item['stok'] < item['min'];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLow ? Colors.red[100] : Colors.blue[100],
                      child: Icon(Icons.inventory_2, color: isLow ? Colors.red : Colors.blue),
                    ),
                    title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Min: ${item['min']} ${item['satuan']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${item['stok']} ${item['satuan']}", 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: isLow ? Colors.red : Colors.black
                          )
                        ),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.edit_square), onPressed: () {}),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Tambah Bahan Baku"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
