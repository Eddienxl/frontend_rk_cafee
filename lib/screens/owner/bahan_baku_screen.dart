import 'package:flutter/material.dart';
import '../../services/bahan_service.dart';
import '../../models/bahan_baku_model.dart';

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

  // --- CREATE ---
  void _showAddDialog() {
    final namaCtrl = TextEditingController();
    final stokCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    String satuan = 'g'; // Default normalized to backend preference
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
        title: const Text("Tambah Bahan Baku"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: "Nama Bahan")),
              TextField(controller: stokCtrl, decoration: const InputDecoration(labelText: "Stok Awal"), keyboardType: TextInputType.number),
              TextField(controller: minCtrl, decoration: const InputDecoration(labelText: "Stok Minimum"), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: satuan,
                items: satuanMap.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => satuan = v!,
                decoration: const InputDecoration(labelText: "Satuan Dasar"),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isEmpty || stokCtrl.text.isEmpty) return;
              Navigator.pop(context);
              
              final success = await _bahanService.createBahan(
                nama: namaCtrl.text, 
                stok: double.tryParse(stokCtrl.text) ?? 0, 
                satuan: satuan, 
                min: double.tryParse(minCtrl.text) ?? 5
              );
              
              if (success) _fetchBahanBaku();
              else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menambah bahan")));
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  // --- UPDATE (RESTOCK) ---
  void _showRestockDialog(BahanBakuModel item) {
    final jumlahCtrl = TextEditingController();
    String satuanBase = item.satuan; 
    String satuanInput = satuanBase; // Default input sama dengan base

    // Logika opsi satuan: Jika base 'g' atau 'ml', izinkan input 'kg' atau 'l'
    List<String> validOptions = [satuanBase];
    if (satuanBase == 'g') validOptions.add('kg');
    if (satuanBase == 'ml') validOptions.add('l');
    
    // Mapping label UI
    final Map<String, String> labelMap = {
      'g': 'Gram (g)', 'kg': 'Kilogram (kg)',
      'ml': 'Mililiter (ml)', 'l': 'Liter (l)',
      'pcs': 'Pcs', 'botol': 'Botol'
    };

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Perlu StatefulBuilder agar dropdown bisa berubah state dalam Dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Update Stok: ${item.nama}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: jumlahCtrl, 
                    decoration: const InputDecoration(labelText: "Jumlah Tambah/Kurang (+/-)"), 
                    keyboardType: const TextInputType.numberWithOptions(signed: true)
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: satuanInput,
                    decoration: const InputDecoration(labelText: "Satuan Input"),
                    items: validOptions.map((k) {
                       return DropdownMenuItem(value: k, child: Text(labelMap[k] ?? k));
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() => satuanInput = val!);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Stok akan otomatis dikonversi ke ${labelMap[satuanBase]} oleh sistem.", 
                    style: const TextStyle(color: Colors.grey, fontSize: 12)
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                ElevatedButton(
                  onPressed: () async {
                    if (jumlahCtrl.text.isEmpty) return;
                    Navigator.pop(context);

                    final success = await _bahanService.updateBahanStok(
                      idBahan: item.idBahan,
                      jumlah: double.tryParse(jumlahCtrl.text) ?? 0,
                      satuanInput: satuanInput, // Kirim satuan yang dipilih user (misal kg)
                      keterangan: "Restock via Owner App ($satuanInput)"
                    );

                    if (success) _fetchBahanBaku();
                    else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal update stok")));
                  },
                  child: const Text("Update"),
                )
              ],
            );
          }
        );
      },
    );
  }

  // --- DELETE ---
  void _deleteBahan(BahanBakuModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Bahan"),
        content: Text("Yakin hapus ${item.nama}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await _bahanService.deleteBahan(item.idBahan);
              if (success) _fetchBahanBaku();
              else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal hapus bahan")));
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
        title: const Text('Kelola Bahan Baku'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D4037),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Stats Header (Visible only if valid data exists, optional)
                if (_bahanBaku.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.red[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text("Stok Menipis", style: TextStyle(color: Colors.red)),
                                  Text(
                                    "${_bahanBaku.where((b) => b.stokSaatIni < b.stokMinimum).length} Item",
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
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
                                  Text(
                                    "${_bahanBaku.length} Item",
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. Content Area (List or Empty State)
                Expanded(
                  child: _bahanBaku.isEmpty
                      ? const Center(child: Text("Belum ada data bahan baku"))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _bahanBaku.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _bahanBaku[index];
                            final stok = item.stokSaatIni;
                            final min = item.stokMinimum;
                            final isLow = stok < min;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isLow ? Colors.red[100] : Colors.blue[100],
                                child: Icon(Icons.inventory_2, color: isLow ? Colors.red : Colors.blue),
                              ),
                              title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Min: $min ${item.satuan}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("$stok ${item.satuan}",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.black)),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () => _showRestockDialog(item),
                                    tooltip: "Restock",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteBahan(item),
                                    tooltip: "Hapus",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // 3. Bottom Action Button (Always Visible)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.1), offset: const Offset(0, -2))]
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Bahan Baku"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D4037),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _showAddDialog,
                  ),
                ),
              ],
            ),
    );
  }
}
