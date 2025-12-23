import 'package:flutter/material.dart';
import '../../services/owner_service.dart';
import 'package:intl/intl.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final OwnerService _ownerService = OwnerService();
  Map<String, dynamic>? _laporanData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    try {
      final data = await _ownerService.getLaporanPenjualan();
      setState(() {
        _laporanData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Mock data jika backend belum siap respons strukturnya
      // setState(() {
      //   _laporanData = {
      //     'omzet_total': 15000000,
      //     'transaksi_count': 120,
      //     'menu_terlaris': [
      //       {'nama_menu': 'Kopi Susu', 'qty': 50},
      //       {'nama_menu': 'Nasi Goreng', 'qty': 30},
      //     ]
      //   };
      //   _isLoading = false;
      // });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Load Laporan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laporanData == null
              ? const Center(child: Text("Data Kosong"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Card
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text("Total Omzet", style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(_laporanData!['total_omzet'] ?? 0),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total Transaksi"),
                                  Text("${_laporanData!['total_order'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Menu Terlaris", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (_laporanData!['menu_terlaris'] != null)
                        ...(_laporanData!['menu_terlaris'] as List).map((item) {
                          return ListTile(
                            leading: const Icon(Icons.star, color: Colors.orange),
                            title: Text(item['nama_menu'] ?? 'Unknown'),
                            trailing: Text("${item['total_terjual']} terjual"),
                          );
                        })
                      else
                        const Padding(padding: EdgeInsets.all(8), child: Text("Belum ada data menu terlaris")),
                    ],
                  ),
                ),
    );
  }
}
