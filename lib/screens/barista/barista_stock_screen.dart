import 'package:flutter/material.dart';
import '../../services/bahan_service.dart';
import '../../models/bahan_baku_model.dart';
import 'package:intl/intl.dart';

class BaristaStockScreen extends StatefulWidget {
  const BaristaStockScreen({super.key});

  @override
  State<BaristaStockScreen> createState() => _BaristaStockScreenState();
}

class _BaristaStockScreenState extends State<BaristaStockScreen> {
  final BahanService _bahanService = BahanService();
  List<BahanBakuModel> _bahanBaku = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBahanBaku();
  }

  Future<void> _fetchBahanBaku() async {
    setState(() => _isLoading = true);
    try {
      final data = await _bahanService.getBahanBaku();
      if (mounted) {
        setState(() {
          _bahanBaku = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                 const Icon(Icons.inventory, color: Colors.brown, size: 28),
                 const SizedBox(width: 10),
                 const Text("Cek Stok Bahan Baku", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
                 const Spacer(),
                 IconButton(onPressed: _fetchBahanBaku, icon: const Icon(Icons.refresh)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _bahanBaku.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = _bahanBaku[index];
                final bool isLow = item.stokSaatIni < item.stokMinimum;
                
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLow ? Colors.red[100] : Colors.green[100],
                      child: Icon(Icons.inventory_2, color: isLow ? Colors.red : Colors.green),
                    ),
                    title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Min: ${item.stokMinimum} ${item.satuan}"),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLow ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${item.stokSaatIni} ${item.satuan}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
