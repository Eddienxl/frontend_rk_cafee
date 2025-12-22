import 'package:equatable/equatable.dart';

/// Model Bill of Materials - merepresentasikan resep/komposisi bahan per menu
/// Menerapkan prinsip OOP:
/// - Encapsulation: data terlindungi
/// - Composition: menghubungkan Menu dengan BahanBaku
class BomModel extends Equatable {
  final String idBom;
  final String idMenu;
  final String idBahan;
  final double jumlahDibutuhkan;
  final String? namaMenu;
  final String? namaBahan;
  final String? satuan;

  const BomModel({
    required this.idBom,
    required this.idMenu,
    required this.idBahan,
    required this.jumlahDibutuhkan,
    this.namaMenu,
    this.namaBahan,
    this.satuan,
  });

  /// Factory constructor dari JSON
  factory BomModel.fromJson(Map<String, dynamic> json) {
    // Handle nested menu dan bahan data
    String? namaMenu;
    String? namaBahan;
    String? satuan;

    if (json['Menu'] != null) {
      namaMenu = json['Menu']['nama_menu'];
    }
    if (json['BahanBaku'] != null) {
      namaBahan = json['BahanBaku']['nama_bahan'];
      satuan = json['BahanBaku']['satuan'];
    }

    return BomModel(
      idBom: json['id_bom']?.toString() ?? '',
      idMenu: json['id_menu']?.toString() ?? '',
      idBahan: json['id_bahan']?.toString() ?? '',
      jumlahDibutuhkan: (json['jumlah_dibutuhkan'] ?? 0).toDouble(),
      namaMenu: namaMenu ?? json['nama_menu'],
      namaBahan: namaBahan ?? json['nama_bahan'],
      satuan: satuan ?? json['satuan'],
    );
  }

  /// Konversi ke JSON untuk API request
  Map<String, dynamic> toJson() {
    return {
      'id_bom': idBom,
      'id_menu': idMenu,
      'id_bahan': idBahan,
      'jumlah_dibutuhkan': jumlahDibutuhkan,
    };
  }

  /// Copy with method untuk immutability
  BomModel copyWith({
    String? idBom,
    String? idMenu,
    String? idBahan,
    double? jumlahDibutuhkan,
    String? namaMenu,
    String? namaBahan,
    String? satuan,
  }) {
    return BomModel(
      idBom: idBom ?? this.idBom,
      idMenu: idMenu ?? this.idMenu,
      idBahan: idBahan ?? this.idBahan,
      jumlahDibutuhkan: jumlahDibutuhkan ?? this.jumlahDibutuhkan,
      namaMenu: namaMenu ?? this.namaMenu,
      namaBahan: namaBahan ?? this.namaBahan,
      satuan: satuan ?? this.satuan,
    );
  }

  /// Format jumlah dibutuhkan dengan satuan
  String get jumlahFormatted => '${jumlahDibutuhkan.toStringAsFixed(2)} ${satuan ?? ''}';

  @override
  List<Object?> get props => [idBom, idMenu, idBahan, jumlahDibutuhkan];

  @override
  String toString() => 'BomModel(idBom: $idBom, namaBahan: $namaBahan, jumlah: $jumlahFormatted)';
}

