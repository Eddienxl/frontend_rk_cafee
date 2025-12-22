import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';

/// Enum untuk status order
enum OrderStatus { baru, sedangDibuat, selesai }

/// Extension untuk konversi OrderStatus
extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.baru:
        return 'BARU';
      case OrderStatus.sedangDibuat:
        return 'SEDANG DIBUAT';
      case OrderStatus.selesai:
        return 'SELESAI';
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.baru:
        return 'Baru';
      case OrderStatus.sedangDibuat:
        return 'Sedang Dibuat';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'BARU':
        return OrderStatus.baru;
      case 'SEDANG DIBUAT':
        return OrderStatus.sedangDibuat;
      case 'SELESAI':
        return OrderStatus.selesai;
      default:
        return OrderStatus.baru;
    }
  }
}

/// Model Order - merepresentasikan pesanan
/// Menerapkan prinsip OOP:
/// - Composition: mengandung list CartItemModel
/// - Encapsulation: logika bisnis dalam methods
class OrderModel extends Equatable {
  final String idOrder;
  final DateTime tanggal;
  final double totalBayar;
  final OrderStatus statusPesanan;
  final String idUser;
  final String? namaMenu;
  final int jumlahOrder;
  final String? waktuOrder;
  final List<CartItemModel> items;

  const OrderModel({
    required this.idOrder,
    required this.tanggal,
    required this.totalBayar,
    required this.statusPesanan,
    required this.idUser,
    this.namaMenu,
    this.jumlahOrder = 1,
    this.waktuOrder,
    this.items = const [],
  });

  /// Factory constructor dari JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse waktu order
    String? waktu;
    if (json['tanggal'] != null) {
      try {
        final dt = DateTime.parse(json['tanggal']);
        waktu = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        waktu = null;
      }
    }

    // Get nama_menu dari include Menu jika ada
    String? namaMenu;
    if (json['Menu'] != null) {
      namaMenu = json['Menu']['nama_menu'];
    }

    return OrderModel(
      idOrder: json['id_order']?.toString() ?? '',
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'])
          : DateTime.now(),
      totalBayar: (json['total_bayar'] ?? json['total_harga'] ?? 0).toDouble(),
      statusPesanan: OrderStatusExtension.fromString(json['status_pesanan'] ?? json['status'] ?? 'BARU'),
      idUser: json['id_user']?.toString() ?? '',
      namaMenu: namaMenu,
      jumlahOrder: json['jumlah_order'] ?? 1,
      waktuOrder: waktu,
      items: [], // Items akan di-parse terpisah jika diperlukan
    );
  }

  /// Konversi ke JSON untuk create order
  Map<String, dynamic> toJson() {
    return {
      'id_order': idOrder,
      'tanggal': tanggal.toIso8601String(),
      'total_bayar': totalBayar,
      'status_pesanan': statusPesanan.value,
      'id_user': idUser,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Copy with method
  OrderModel copyWith({
    String? idOrder,
    DateTime? tanggal,
    double? totalBayar,
    OrderStatus? statusPesanan,
    String? idUser,
    String? namaMenu,
    int? jumlahOrder,
    String? waktuOrder,
    List<CartItemModel>? items,
  }) {
    return OrderModel(
      idOrder: idOrder ?? this.idOrder,
      tanggal: tanggal ?? this.tanggal,
      totalBayar: totalBayar ?? this.totalBayar,
      statusPesanan: statusPesanan ?? this.statusPesanan,
      idUser: idUser ?? this.idUser,
      namaMenu: namaMenu ?? this.namaMenu,
      jumlahOrder: jumlahOrder ?? this.jumlahOrder,
      waktuOrder: waktuOrder ?? this.waktuOrder,
      items: items ?? this.items,
    );
  }

  /// Format total bayar ke Rupiah
  String get totalBayarFormatted {
    return 'Rp ${totalBayar.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Cek apakah order masih baru
  bool get isBaru => statusPesanan == OrderStatus.baru;

  /// Cek apakah order sedang diproses
  bool get isSedangDibuat => statusPesanan == OrderStatus.sedangDibuat;

  /// Cek apakah order sudah selesai
  bool get isSelesai => statusPesanan == OrderStatus.selesai;

  @override
  List<Object?> get props => [idOrder, tanggal, totalBayar, statusPesanan, idUser, namaMenu, jumlahOrder, items];
}

