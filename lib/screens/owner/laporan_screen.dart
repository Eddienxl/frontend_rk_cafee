import 'package:flutter/material.dart';
import 'package:frontend_rk_cafee/services/owner_service.dart';
import 'package:intl/intl.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final OwnerService _ownerService = OwnerService();
  
  // State Filter
  String _filterType = 'Harian'; // Harian, Bulanan, Custom
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
    // Simulasi kirim filter ke service (Service dummy ignore filter actually)
    try {
      final data = await _ownerService.getLaporanPenjualan(
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5D4037),
        elevation: 0,
        leading: const SizedBox(), 
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchLaporan)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FILTER SECTION
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Color(0xFF5D4037)),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _filterType == 'Custom' ? 'Custom' : _filterType,
                      underline: const SizedBox(),
                      items: ['Harian', 'Bulanan', 'Custom'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) {
                        if (val == 'Custom') {
                          _selectDateRange();
                        } else {
                          setState(() => _filterType = val!);
                          _fetchLaporan();
                        }
                      },
                    ),
                    const Spacer(),
                    if (_filterType == 'Custom' && _dateRange != null)
                      Text(
                        "${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            if (_isLoading) 
              const Center(child: CircularProgressIndicator())
            else if (_laporanData == null)
              const Center(child: Text("Data tidak tersedia"))
            else
              Column(
                children: [
                  // SUMMARY BIG CARDS
                  Row(
                    children: [
                      Expanded(child: _buildSummaryBox("Total Omzet", currencyFormatter.format(_laporanData!['total_omzet']), Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSummaryBox("Total Order", "${_laporanData!['total_order']} Transaksi", Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // MENU TERLARIS
                  const Align(alignment: Alignment.centerLeft, child: Text("Menu Terlaris", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  const SizedBox(height: 12),
                  ...(_laporanData!['menu_terlaris'] as List).map((m) => _buildTopMenuItem(m)),

                  const SizedBox(height: 24),
                  
                  // STATISTIK GRAFIK (Dummy Representation)
                  const Align(alignment: Alignment.centerLeft, child: Text("Tren Penjualan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: (_laporanData!['statistik_harian'] as List).map((day) {
                        double omzet = (day['omzet'] as int).toDouble();
                        double maxOmzet = 2000000; // Asumsi max dummy
                        double percent = (omzet / maxOmzet).clamp(0.0, 1.0);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              SizedBox(width: 60, child: Text(day['hari'], style: const TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(height: 12, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
                                    FractionallySizedBox(widthFactor: percent, child: Container(height: 12, decoration: BoxDecoration(color: const Color(0xFF5D4037), borderRadius: BorderRadius.circular(6)))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(currencyFormatter.format(omzet), style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopMenuItem(Map<String, dynamic> item) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFF5D4037), child: Icon(Icons.star, color: Colors.white, size: 16)),
        title: Text(item['nama_menu'], style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text("${item['total_terjual']} Terjual", style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
