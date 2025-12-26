class BahanBakuModel {
  final String id;
  final String nama;
  final double stokSaatIni;
  final double stokMinimum;
  final String satuan;

  BahanBakuModel({
    required this.id,
    required this.nama,
    required this.stokSaatIni,
    required this.stokMinimum,
    required this.satuan,
  });

  factory BahanBakuModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk konversi aman ke double
    double toDouble(dynamic val) {
      if (val is int) return val.toDouble();
      if (val is double) return val;
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return BahanBakuModel(
      id: json['id_bahan']?.toString() ?? '',
      nama: json['nama_bahan'] ?? 'Tanpa Nama',
      stokSaatIni: toDouble(json['stok_saat_ini']),
      stokMinimum: toDouble(json['stok_minimum']),
      satuan: json['satuan'] ?? 'pcs',
    );
  }
}
