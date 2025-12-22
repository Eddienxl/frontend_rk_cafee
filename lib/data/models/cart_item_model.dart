import 'package:equatable/equatable.dart';
import 'menu_model.dart';

/// Model Cart Item - merepresentasikan item dalam keranjang belanja
/// Menerapkan prinsip OOP:
/// - Composition: menggunakan MenuModel sebagai komponen
/// - Encapsulation: kalkulasi subtotal tersembunyi dalam getter
class CartItemModel extends Equatable {
  final MenuModel menu;
  final int jumlah;
  final String? catatan;

  const CartItemModel({
    required this.menu,
    required this.jumlah,
    this.catatan,
  });

  /// Hitung subtotal untuk item ini
  double get subtotal => menu.harga * jumlah;

  /// Format subtotal ke Rupiah
  String get subtotalFormatted {
    return 'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Copy with untuk update jumlah atau catatan
  CartItemModel copyWith({
    MenuModel? menu,
    int? jumlah,
    String? catatan,
  }) {
    return CartItemModel(
      menu: menu ?? this.menu,
      jumlah: jumlah ?? this.jumlah,
      catatan: catatan ?? this.catatan,
    );
  }

  /// Tambah jumlah
  CartItemModel increment() => copyWith(jumlah: jumlah + 1);

  /// Kurangi jumlah
  CartItemModel decrement() => jumlah > 1 ? copyWith(jumlah: jumlah - 1) : this;

  /// Konversi ke JSON untuk API
  Map<String, dynamic> toJson() {
    return {
      'id_menu': menu.idMenu,
      'jumlah': jumlah,
      'catatan': catatan,
      'subtotal': subtotal,
    };
  }

  @override
  List<Object?> get props => [menu, jumlah, catatan];

  @override
  String toString() => 'CartItemModel(menu: ${menu.namaMenu}, jumlah: $jumlah)';
}

