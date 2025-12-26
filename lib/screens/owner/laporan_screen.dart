import 'package:flutter/material.dart';
import '../../services/laporan_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final LaporanService _laporanService = LaporanService();
  
  String _filterType = 'Harian';
  DateTimeRange? _dateRange;
  
  Map<String, dynamic>? _laporanData;
  bool _isLoading = true;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    try {
      final data = await _laporanService.getLaporanPenjualan(
        startDate: _dateRange?.start.toString(),
        endDate: _dateRange?.end.toString()
      );
      if (mounted) {
        setState(() {
          _laporanData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF5D4037)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _filterType = 'Custom';
      });
      _fetchLaporan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterHeader(),
                const SizedBox(height: 24),
                
                if (_laporanData != null) ...[
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard("Total Omzet", currencyFormatter.format(_laporanData!['total_omzet']), Icons.payments, Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSummaryCard("Total Order", "${_laporanData!['total_order']}", Icons.receipt, Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  Text("Menu Terlaris", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...(_laporanData!['menu_terlaris'] as List).map((m) => _buildTopMenuItem(m)),
                  const SizedBox(height: 40),
                ] else
                  const Center(child: Text("Data tidak tersedia")),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Analisis Laporan", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(_filterType == 'Custom' && _dateRange != null 
              ? "${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}"
              : "Ringkasan $_filterType", 
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
        TextButton.icon(
          onPressed: _selectDateRange,
          icon: const Icon(Icons.date_range, size: 18),
          label: const Text("Filter"),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF5D4037).withOpacity(0.1),
            foregroundColor: const Color(0xFF5D4037),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopMenuItem(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.amber[100], shape: BoxShape.circle),
          child: const Icon(Icons.star, color: Colors.amber, size: 20),
        ),
        title: Text(item['nama_menu'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text("Produk Unggulan", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.brown[50], borderRadius: BorderRadius.circular(20)),
          child: Text("${item['total_terjual']} Terjual", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D4037))),
        ),
      ),
    );
  }
}
