import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/cart_item_model.dart';

/// Widget untuk menampilkan item di shopping cart
/// Menerapkan prinsip OOP:
/// - Composition: menggunakan CartItemModel
/// - Callback Pattern: menggunakan function callback untuk interaksi
class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon kategori
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.secondaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.coffee,
              color: AppConstants.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          // Info item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.namaMenu,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.menu.hargaFormatted,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                if (item.catatan != null && item.catatan!.isNotEmpty)
                  Text(
                    'Catatan: ${item.catatan}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              _buildQuantityButton(
                icon: Icons.remove,
                onTap: onDecrement,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.jumlah}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.fontSizeMedium,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add,
                onTap: onIncrement,
              ),
            ],
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          // Subtotal & Remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.subtotalFormatted,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                  fontSize: AppConstants.fontSizeMedium,
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.delete_outline,
                  color: AppConstants.errorColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }
}

