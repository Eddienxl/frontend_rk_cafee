class OrderModel {
  final String idOrder;
  final String statusPesanan; // BARU, SEDANG DIBUAT, SELESAI
  final String? namaKasir; // Optional if needed
  final DateTime? tanggal;
  final List<OrderItemModel> items;

  OrderModel({
    required this.idOrder,
    required this.statusPesanan,
    this.namaKasir,
    this.tanggal,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<OrderItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems.map((e) => OrderItemModel.fromJson(e)).toList();
    }

    return OrderModel(
      idOrder: json['id_order'] ?? '',
      statusPesanan: json['status_pesanan'] ?? 'BARU',
      tanggal: json['tanggal'] != null ? DateTime.tryParse(json['tanggal']) : null,
      items: parsedItems,
    );
  }
}

class OrderItemModel {
  final String namaMenu;
  final int jumlah;
  final double subtotal;

  OrderItemModel({
    required this.namaMenu,
    required this.jumlah,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Backend uses 'menu_detail' include for name
    String nama = 'Unknown';
    if (json['menu_detail'] != null) {
      nama = json['menu_detail']['nama_menu'] ?? '-';
    }

    return OrderItemModel(
      namaMenu: nama,
      jumlah: json['jumlah'] ?? 0,
      subtotal: (json['subtotal'] is int) ? (json['subtotal'] as int).toDouble() : (json['subtotal'] as double? ?? 0.0),
    );
  }
}
