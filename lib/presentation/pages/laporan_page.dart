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
              // Row 1: Omzet & Total Order
              Row(
                children: [
                  _buildSummaryCard(
                    'Total Omzet',
                    provider.totalOmzetFormatted,
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    'Total Order',
                    '${provider.totalOrder}',
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
                    '${provider.totalItem}',
                    Icons.shopping_bag,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    'Rata-rata/Order',
                    provider.rataRataPerOrderFormatted,
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
        if (provider.menuTerlaris.isEmpty) {
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
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Menu Terlaris',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: const Row(
                  children: [
                    Expanded(flex: 1, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 4, child: Text('Nama Menu', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Terjual', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              // Table Body
              Expanded(
                child: ListView.builder(
                  itemCount: provider.menuTerlaris.length,
                  itemBuilder: (context, index) {
                    final menu = provider.menuTerlaris[index];
                    final rank = index + 1;
                    Color rankColor = Colors.grey;
                    if (rank == 1) rankColor = Colors.amber;
                    else if (rank == 2) rankColor = Colors.grey[400]!;
                    else if (rank == 3) rankColor = Colors.brown[300]!;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: rankColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '#$rank',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: rankColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              menu.namaMenu,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${menu.totalTerjual}x',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
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

