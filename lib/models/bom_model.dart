class BOMModel {
  final String idMenu;
  final String namaMenu;
  final List<BOMItemModel> resep;

  BOMModel({
    required this.idMenu,
    required this.namaMenu,
    required this.resep,
  });

  factory BOMModel.fromJson(Map<String, dynamic> json) {
    var rawResep = json['resep'];
    List<BOMItemModel> resepList = [];

    if (rawResep is List) {
      resepList = rawResep.map((e) => BOMItemModel.fromJson(e)).toList();
    }

    return BOMModel(
      idMenu: json['id_menu']?.toString() ?? '',
      namaMenu: json['nama_menu'] ?? 'Unknown',
      resep: resepList,
    );
  }
}

class BOMItemModel {
  final String? idBom; // Nullable karena backend mungkin tidak kirim di endpoint tertentu
  final String idBahan;
  final String namaBahan;
  final double jumlahDibutuhkan;
  final String satuan;

  BOMItemModel({
    this.idBom,
    required this.idBahan,
    required this.namaBahan,
    required this.jumlahDibutuhkan,
    required this.satuan,
  });

  factory BOMItemModel.fromJson(Map<String, dynamic> json) {
    return BOMItemModel(
      idBom: json['id_bom']?.toString(),
      idBahan: json['id_bahan']?.toString() ?? '',
      namaBahan: json['nama_bahan'] ?? 'Unknown',
      jumlahDibutuhkan: (json['jumlah_dibutuhkan'] is num) 
          ? (json['jumlah_dibutuhkan'] as num).toDouble() 
          : double.tryParse(json['jumlah_dibutuhkan'].toString()) ?? 0.0,
      satuan: json['satuan'] ?? '',
    );
  }
}
