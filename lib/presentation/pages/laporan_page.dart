import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../providers/laporan_provider.dart';
import '../widgets/custom_button.dart';

/// Halaman Laporan Penjualan
/// Menerapkan prinsip OOP:
/// - Separation of Concerns: UI terpisah dari business logic
/// - Computed Properties: summary dihitung di provider
class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String _selectedPeriod = 'Hari Ini';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LaporanProvider>().fetchLaporanHariIni();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLaporan,
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Selector
          _buildPeriodSelector(),
          // Summary Cards
          _buildSummaryCards(),
          // Detail Table
          Expanded(child: _buildDetailTable()),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period chips (scrollable)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...['Hari Ini', 'Minggu Ini', 'Bulan Ini'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      selectedColor: AppConstants.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                      onSelected: (_) => _changePeriod(period),
                    ),
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Pilih Tanggal', style: TextStyle(fontSize: 12)),
                  onPressed: _showDateRangePicker,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<LaporanProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Column(
            children: [
              // Row 1: Pendapatan & Transaksi
              Row(
                children: [
                  _buildSummaryCard(
                    'Total Pendapatan',
                    provider.totalPendapatanFormatted,
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    'Total Transaksi',
                    '${provider.totalTransaksi}',
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 2: Item Terjual & Rata-rata
              Row(
                children: [
                  _buildSummaryCard(
                    'Item Terjual',
                    '${provider.totalItemTerjual}',
                    Icons.shopping_bag,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    'Rata-rata',
                    provider.rataRataFormatted,
                    Icons.analytics,
                    Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTable() {
    return Consumer<LaporanProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.items.isEmpty) {
          return const Center(child: Text('Tidak ada data penjualan'));
        }
        return Container(
          margin: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppConstants.paddingMedium),
                child: Text('Detail Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: const Row(
                  children: [
                    Expanded(flex: 2, child: Text('ID Order', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('Menu', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Table Body
              Expanded(
                child: ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(item.idOrder)),
                          Expanded(flex: 2, child: Text(item.tanggalFormatted)),
                          Expanded(flex: 3, child: Text(item.namaMenu)),
                          Expanded(flex: 1, child: Text('${item.jumlah}x')),
                          Expanded(flex: 2, child: Text(item.totalHargaFormatted)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changePeriod(String period) {
    setState(() => _selectedPeriod = period);
    final provider = context.read<LaporanProvider>();
    switch (period) {
      case 'Hari Ini':
        provider.fetchLaporanHariIni();
        break;
      case 'Minggu Ini':
        provider.fetchLaporanMingguIni();
        break;
      case 'Bulan Ini':
        provider.fetchLaporanBulanIni();
        break;
    }
  }

  void _refreshLaporan() {
    _changePeriod(_selectedPeriod);
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppConstants.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedPeriod = 'Custom');
      context.read<LaporanProvider>().setDateRange(picked.start, picked.end);
    }
  }
}

