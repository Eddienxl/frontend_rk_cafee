import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/menu_model.dart';
import '../../data/models/bahan_baku_model.dart';
import '../providers/bom_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/custom_button.dart';

/// Halaman Bill of Materials - mengelola resep/komposisi bahan per menu
/// Menerapkan prinsip OOP:
/// - Separation of Concerns: UI terpisah dari business logic
/// - Composition: menggunakan data dari Menu dan BahanBaku
class BomPage extends StatefulWidget {
  const BomPage({super.key});

  @override
  State<BomPage> createState() => _BomPageState();
}

class _BomPageState extends State<BomPage> {
  MenuModel? _selectedMenu;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().fetchMenus();
      context.read<InventoryProvider>().fetchBahanBaku();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Resep (BOM)'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _selectedMenu == null ? _buildMenuList() : _buildBomDetail(),
      floatingActionButton: _selectedMenu != null
          ? FloatingActionButton(
              backgroundColor: AppConstants.primaryColor,
              onPressed: () => _showAddBomDialog(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildMenuList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          color: Colors.white,
          width: double.infinity,
          child: const Text(
            'Pilih Menu untuk Melihat Resep',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Consumer<MenuProvider>(
            builder: (context, menuProvider, _) {
              if (menuProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (menuProvider.menus.isEmpty) {
                return const Center(child: Text('Tidak ada menu'));
              }
              return ListView.builder(
                itemCount: menuProvider.menus.length,
                itemBuilder: (context, index) {
                  final menu = menuProvider.menus[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.restaurant_menu, color: AppConstants.primaryColor),
                      ),
                      title: Text(menu.namaMenu, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(menu.hargaFormatted),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        setState(() => _selectedMenu = menu);
                        context.read<BomProvider>().fetchBomByMenu(menu.idMenu);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBomDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan tombol back
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedMenu = null),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMenu!.namaMenu,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Harga: ${_selectedMenu!.hargaFormatted}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Label
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Text(
            'Bahan-bahan:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ),
        // BOM List
        Expanded(child: _buildBomList()),
      ],
    );
  }

  Widget _buildBomList() {
    return Consumer<BomProvider>(
      builder: (context, bomProvider, _) {
        if (bomProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (bomProvider.bomByMenu.isEmpty) {
          return const Center(
            child: Text('Belum ada bahan untuk menu ini'),
          );
        }
        return ListView.builder(
          itemCount: bomProvider.bomByMenu.length,
          itemBuilder: (context, index) {
            final bom = bomProvider.bomByMenu[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppConstants.secondaryColor,
                  child: Icon(Icons.inventory_2, color: Colors.white),
                ),
                title: Text(bom.namaBahan ?? 'Bahan #${bom.idBahan}'),
                subtitle: Text('Jumlah: ${bom.jumlahFormatted}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBom(bom.idBom),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddBomDialog() {
    BahanBakuModel? selectedBahan;
    final jumlahController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Bahan ke Resep'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<BahanBakuModel>(
                      value: selectedBahan,
                      decoration: const InputDecoration(labelText: 'Pilih Bahan'),
                      items: inventoryProvider.bahanList.map((bahan) {
                        return DropdownMenuItem(
                          value: bahan,
                          child: Text('${bahan.namaBahan} (${bahan.satuan})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedBahan = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: jumlahController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Dibutuhkan',
                        suffixText: selectedBahan?.satuan ?? '',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          CustomButton(
            text: 'Simpan',
            onPressed: () async {
              if (selectedBahan != null && jumlahController.text.isNotEmpty) {
                final success = await context.read<BomProvider>().createBom(
                  idMenu: _selectedMenu!.idMenu,
                  idBahan: selectedBahan!.idBahan,
                  jumlahDibutuhkan: double.tryParse(jumlahController.text) ?? 0,
                );
                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBom(String idBom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Bahan'),
        content: const Text('Yakin ingin menghapus bahan ini dari resep?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          CustomButton(
            text: 'Hapus',
            variant: ButtonVariant.danger,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<BomProvider>().deleteBom(idBom);
    }
  }
}

