import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/menu_model.dart';
import '../../core/services/menu_image_mapper.dart';
import '../providers/auth_provider.dart';

/// Widget Card untuk menampilkan item menu
/// Menerapkan prinsip OOP:
/// - Composition: menggunakan MenuModel
/// - Single Responsibility: hanya menampilkan menu card
class MenuCard extends StatelessWidget {
  final MenuModel menu;
  final VoidCallback? onTap;
  final bool isSelected;
  final Function(MenuModel)? onEdit;
  final VoidCallback? onDelete;

  const MenuCard({
    super.key,
    required this.menu,
    this.onTap,
    this.isSelected = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isOwner = auth.currentUser?.isOwner ?? false;
        return GestureDetector(
          onTap: menu.statusTersedia ? onTap : null,
          onLongPress: isOwner ? () => _showOwnerMenu(context) : null,
          child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: AppConstants.primaryColor,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar menu (dari internet) dengan overlay agar tema seragam
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusMedium),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Network image dari Unsplash Source (dynamic query)
                    Image.network(
                      MenuImageMapper.resolvedImageUrlFor(menu),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppConstants.secondaryColor.withOpacity(0.3),
                        child: Icon(
                          _getCategoryIcon(),
                          size: 48,
                          color: AppConstants.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                    // Overlay warna untuk menyamakan tone dan memastikan teks terbaca
                    Container(
                      color: MenuImageMapper.overlayColorFor(menu).withOpacity(0.28),
                    ),
                  ],
                ),
              ),
            ),
            // Info Menu
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      menu.namaMenu,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            menu.hargaFormatted,
                            style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: AppConstants.fontSizeMedium,
                            ),
                          ),
                        ),
                        if (!menu.statusTersedia)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.errorColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Habis',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  void _showOwnerMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              menu.namaMenu,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Menu'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call(menu);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Menu', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!menu.statusTersedia) return Colors.grey[200]!;
    if (isSelected) return AppConstants.accentColor.withOpacity(0.2);
    return Colors.white;
  }

  IconData _getCategoryIcon() {
    switch ((menu.kategori ?? '').toLowerCase()) {
      case 'coffee':
      case 'kopi':
        return Icons.coffee;
      case 'non coffee':
      case 'non-kopi':
        return Icons.local_cafe;
      case 'food':
      case 'makanan':
        return Icons.restaurant;
      case 'add on':
      case 'addon':
        return Icons.add_circle_outline;
      default:
        return Icons.restaurant_menu;
    }
  }
}

