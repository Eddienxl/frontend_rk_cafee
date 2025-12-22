import 'package:equatable/equatable.dart';

/// Model Bahan Baku - merepresentasikan data bahan baku/inventory
/// Menerapkan prinsip OOP:
/// - Encapsulation: logika bisnis tersembunyi dalam method
/// - Computed Properties: stok rendah dihitung otomatis
class BahanBakuModel extends Equatable {
  final String idBahan;
  final String namaBahan;
  final double stokSaatIni;
  final double stokMinimum;
  final String satuan;

  const BahanBakuModel({
    required this.idBahan,
    required this.namaBahan,
    required this.stokSaatIni,
    required this.stokMinimum,
    required this.satuan,
  });

  /// Factory constructor dari JSON
  factory BahanBakuModel.fromJson(Map<String, dynamic> json) {
    return BahanBakuModel(
      idBahan: json['id_bahan'] ?? '',
      namaBahan: json['nama_bahan'] ?? '',
      stokSaatIni: (json['stok_saat_ini'] ?? 0).toDouble(),
      stokMinimum: (json['stok_minimum'] ?? 0).toDouble(),
      satuan: json['satuan'] ?? '',
    );
  }

  /// Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_bahan': idBahan,
      'nama_bahan': namaBahan,
      'stok_saat_ini': stokSaatIni,
      'stok_minimum': stokMinimum,
      'satuan': satuan,
    };
  }

  /// Copy with method
  BahanBakuModel copyWith({
    String? idBahan,
    String? namaBahan,
    double? stokSaatIni,
    double? stokMinimum,
    String? satuan,
  }) {
    return BahanBakuModel(
      idBahan: idBahan ?? this.idBahan,
      namaBahan: namaBahan ?? this.namaBahan,
      stokSaatIni: stokSaatIni ?? this.stokSaatIni,
      stokMinimum: stokMinimum ?? this.stokMinimum,
      satuan: satuan ?? this.satuan,
    );
  }

  /// Cek apakah stok di bawah minimum (warning)
  bool get isStokRendah => stokSaatIni <= stokMinimum;

  /// Cek apakah stok habis
  bool get isStokHabis => stokSaatIni <= 0;

  /// Cek apakah stok aman
  bool get isStokAman => stokSaatIni > stokMinimum;

  /// Format stok dengan satuan
  String get stokFormatted => '${stokSaatIni.toStringAsFixed(1)} $satuan';

  /// Persentase stok terhadap minimum
  double get stokPercentage {
    if (stokMinimum <= 0) return 100;
    return (stokSaatIni / stokMinimum) * 100;
  }

  @override
  List<Object?> get props => [idBahan, namaBahan, stokSaatIni, stokMinimum, satuan];

  @override
  String toString() => 'BahanBakuModel(idBahan: $idBahan, namaBahan: $namaBahan, stok: $stokFormatted)';
}

