class CartItemModel {
  final String idMenu;
  final String namaMenu;
  final int harga;
  int quantity;

  CartItemModel({
    required this.idMenu,
    required this.namaMenu,
    required this.harga,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_menu': idMenu,
      'jumlah': quantity,
    };
  }
}
