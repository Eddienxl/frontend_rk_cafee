import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/bahan_baku_model.dart';
import '../providers/inventory_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Halaman Inventory Management untuk mengelola bahan baku
/// Menerapkan prinsip OOP:
/// - Separation of Concerns: UI terpisah dari business logic
/// - State Management: menggunakan Provider
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchBahanBaku();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Stok Bahan Baku'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InventoryProvider>().fetchBahanBaku(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan statistik
          _buildStatsHeader(),
          // Search dan Filter
          _buildSearchFilter(),
          // List Bahan Baku
          Expanded(child: _buildBahanList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBahanDialog(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          color: Colors.white,
          child: Row(
            children: [
              _buildStatCard('Total', '${provider.totalJenisBahan}', Icons.inventory_2, Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard('Rendah', '${provider.bahanStokRendah.length}', Icons.warning, Colors.orange),
              const SizedBox(width: 8),
              _buildStatCard('Habis', '${provider.bahanStokHabis.length}', Icons.error, Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: SearchTextField(
              controller: _searchController,
              hintText: 'Cari bahan...',
              onChanged: (value) => context.read<InventoryProvider>().searchBahan(value),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<InventoryProvider>(
            builder: (context, provider, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.filterStatus,
                    isDense: true,
                    items: ['Semua', 'Aman', 'Rendah', 'Habis']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) provider.filterByStatus(value);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBahanList() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.filteredList.isEmpty) {
          return const Center(child: Text('Tidak ada bahan baku ditemukan'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          itemCount: provider.filteredList.length,
          itemBuilder: (context, index) {
            final bahan = provider.filteredList[index];
            return _buildBahanCard(bahan);
          },
        );
      },
    );
  }

  Widget _buildBahanCard(BahanBakuModel bahan) {
    Color statusColor = bahan.isStokHabis
        ? Colors.red
        : bahan.isStokRendah
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.inventory, color: statusColor),
        ),
        title: Text(bahan.namaBahan, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Stok: ${bahan.stokFormatted}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bahan.isStokHabis ? 'Habis' : bahan.isStokRendah ? 'Rendah' : 'Aman',
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: AppConstants.primaryColor),
              onPressed: () => _showUpdateStokDialog(bahan),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBahanDialog() {
    final namaController = TextEditingController();
    final stokController = TextEditingController();
    final satuanController = TextEditingController();
    final minStokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Bahan Baku'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: namaController, labelText: 'Nama Bahan'),
              const SizedBox(height: 12),
              CustomTextField(controller: stokController, labelText: 'Stok Awal', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              CustomTextField(controller: satuanController, labelText: 'Satuan (kg, liter, pcs)'),
              const SizedBox(height: 12),
              CustomTextField(controller: minStokController, labelText: 'Stok Minimum', keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          CustomButton(
            text: 'Simpan',
            onPressed: () async {
              final provider = context.read<InventoryProvider>();
              await provider.createBahan({
                'nama_bahan': namaController.text,
                'stok': double.tryParse(stokController.text) ?? 0,
                'satuan': satuanController.text,
                'stok_minimum': double.tryParse(minStokController.text) ?? 0,
              });
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showUpdateStokDialog(BahanBakuModel bahan) {
    final jumlahController = TextEditingController();
    final keteranganController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stok: ${bahan.namaBahan}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stok saat ini: ${bahan.stokFormatted}'),
            const SizedBox(height: 12),
            CustomTextField(controller: jumlahController, labelText: 'Jumlah (+/-)', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            CustomTextField(controller: keteranganController, labelText: 'Keterangan'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          CustomButton(
            text: 'Update',
            onPressed: () async {
              final provider = context.read<InventoryProvider>();
              await provider.updateStok(
                bahan.idBahan,
                double.tryParse(jumlahController.text) ?? 0,
                keteranganController.text,
              );
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

