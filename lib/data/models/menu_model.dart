import 'package:equatable/equatable.dart';

/// Model Menu - merepresentasikan item menu cafe
/// Menerapkan prinsip OOP:
/// - Encapsulation: menyembunyikan implementasi internal
/// - Immutability: menggunakan final fields untuk data integrity
class MenuModel extends Equatable {
  final String idMenu;
  final String namaMenu;
  final double harga;
  final String? kategori;
  final String? imageUrl;
  final bool statusTersedia;
  final DateTime? createdAt;

  const MenuModel({
    required this.idMenu,
    required this.namaMenu,
    required this.harga,
    this.kategori,
    this.imageUrl,
    this.statusTersedia = true,
    this.createdAt,
  });

  /// Factory constructor dari JSON response API
  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      idMenu: json['id_menu'] ?? '',
      namaMenu: json['nama_menu'] ?? '',
      harga: (json['harga'] ?? 0).toDouble(),
      kategori: json['kategori'],
      imageUrl: json['image_url'],
      statusTersedia: json['status_tersedia'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  /// Konversi ke JSON untuk API request
  Map<String, dynamic> toJson() {
    return {
      'id_menu': idMenu,
      'nama_menu': namaMenu,
      'harga': harga,
      'kategori': kategori,
      if (imageUrl != null) 'image_url': imageUrl,
      'status_tersedia': statusTersedia,
    };
  }

  /// Copy with method untuk immutability
  MenuModel copyWith({
    String? idMenu,
    String? namaMenu,
    double? harga,
    String? kategori,
    String? imageUrl,
    bool? statusTersedia,
    DateTime? createdAt,
  }) {
    return MenuModel(
      idMenu: idMenu ?? this.idMenu,
      namaMenu: namaMenu ?? this.namaMenu,
      harga: harga ?? this.harga,
      kategori: kategori ?? this.kategori,
      imageUrl: imageUrl ?? this.imageUrl,
      statusTersedia: statusTersedia ?? this.statusTersedia,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Format harga ke Rupiah
  String get hargaFormatted {
    return 'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  List<Object?> get props => [idMenu, namaMenu, harga, kategori, imageUrl, statusTersedia];

  @override
  String toString() => 'MenuModel(idMenu: $idMenu, namaMenu: $namaMenu, harga: $harga)';
}

