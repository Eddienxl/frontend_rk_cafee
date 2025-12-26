import 'package:flutter/material.dart';
import '../../services/bahan_service.dart';
import '../../models/bahan_baku_model.dart';
import 'package:google_fonts/google_fonts.dart';

class BahanBakuScreen extends StatefulWidget {
  const BahanBakuScreen({super.key});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen> {
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

  void _showAddDialog() {
    final namaCtrl = TextEditingController();
    final stokCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    String satuan = 'g';
    final Map<String, String> satuanMap = {
      'g': 'Gram (g)',
      'kg': 'Kilogram (kg)',
      'ml': 'Mililiter (ml)',
      'l': 'Liter (l)',
      'pcs': 'Pcs',
      'botol': 'Botol'
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Bahan", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: "Nama Bahan", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: stokCtrl, decoration: const InputDecoration(labelText: "Stok Awal", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: minCtrl, decoration: const InputDecoration(labelText: "Stok Minimum", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: satuan,
                items: satuanMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => satuan = v!,
                decoration: const InputDecoration(labelText: "Satuan", border: OutlineInputBorder()),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037), foregroundColor: Colors.white),
            onPressed: () async {
              if (namaCtrl.text.isEmpty) return;
              Navigator.pop(context);
              final success = await _bahanService.createBahan(
                nama: namaCtrl.text, 
                stok: double.tryParse(stokCtrl.text) ?? 0, 
                satuan: satuan, 
                min: double.tryParse(minCtrl.text) ?? 5
              );
              if (success) _fetchBahanBaku();
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  void _showRestockDialog(BahanBakuModel item) {
    final jumlahCtrl = TextEditingController();
    String satuanInput = item.satuan;
    List<String> validOptions = [item.satuan];
    if (item.satuan == 'g') validOptions.add('kg');
    if (item.satuan == 'ml') validOptions.add('l');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSt) => AlertDialog(
          title: Text("Restock: ${item.nama}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: jumlahCtrl, 
                decoration: const InputDecoration(labelText: "Jumlah (+/-)", border: OutlineInputBorder()), 
                keyboardType: TextInputType.number
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: satuanInput,
                decoration: const InputDecoration(labelText: "Satuan Input", border: OutlineInputBorder()),
                items: validOptions.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (val) => setSt(() => satuanInput = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(context);
                final success = await _bahanService.updateBahanStok(
                  idBahan: item.idBahan,
                  jumlah: double.tryParse(jumlahCtrl.text) ?? 0,
                  satuanInput: satuanInput,
                  keterangan: "Restock via Owner App"
                );
                if (success) _fetchBahanBaku();
              },
              child: const Text("Update Stok"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStockSummary(),
                Expanded(
                  child: _bahanBaku.isEmpty
                      ? const Center(child: Text("Belum ada data bahan baku"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _bahanBaku.length,
                          itemBuilder: (context, index) {
                            final item = _bahanBaku[index];
                            final isLow = item.stokSaatIni < item.stokMinimum;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isLow ? Colors.red[50] : Colors.blue[50],
                                  child: Icon(Icons.inventory_2, color: isLow ? Colors.red : Colors.blue, size: 20),
                                ),
                                title: Text(item.nama, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                subtitle: Text("Min: ${item.stokMinimum} ${item.satuan}", style: const TextStyle(fontSize: 12)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${item.stokSaatIni}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.black)),
                                        Text(item.satuan, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Colors.green),
                                      onPressed: () => _showRestockDialog(item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        label: const Text("Bahan Baru", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add_box, color: Colors.white),
        onPressed: _showAddDialog,
      ),
    );
  }

  Widget _buildStockSummary() {
    int lowCount = _bahanBaku.where((b) => b.stokSaatIni < b.stokMinimum).length;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildSummaryChip("Total Bahan", "${_bahanBaku.length}", Colors.brown),
          const SizedBox(width: 12),
          _buildSummaryChip("Stok Menipis", "$lowCount", Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
