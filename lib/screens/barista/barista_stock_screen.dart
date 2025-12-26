import 'package:flutter/material.dart';
import '../../services/bahan_service.dart';
import '../../models/bahan_baku_model.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return RefreshIndicator(
      onRefresh: _fetchBahanBaku,
      backgroundColor: const Color(0xFF5D4037),
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
               Icon(Icons.inventory_2_rounded, color: const Color(0xFF5D4037), size: 32),
               const SizedBox(width: 12),
               Text("Pantau Stok", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF5D4037))),
               const Spacer(),
               IconButton(onPressed: _fetchBahanBaku, icon: const Icon(Icons.refresh, color: Color(0xFF5D4037))),
            ],
          ),
          const SizedBox(height: 20),
          ..._bahanBaku.map((item) {
            final bool isLow = item.stokSaatIni < item.stokMinimum;
            return Card(
              elevation: 2,
              shadowColor: Colors.black12,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: isLow ? Colors.red[50] : Colors.blue[50],
                  child: Icon(Icons.egg_alt_outlined, color: isLow ? Colors.red : Colors.blue, size: 20),
                ),
                title: Text(item.nama, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text("Minimum Stok: ${item.stokMinimum} ${item.satuan}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${item.stokSaatIni}", 
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.black)
                    ),
                    Text(item.satuan, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
