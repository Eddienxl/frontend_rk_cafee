class MenuModel {
  final String idMenu; // Matches BE id_menu
  final String nama;
  final int harga;
  final String kategori;
  final String imageUrl; // Tambahan untuk UI
  final bool isAvailable;

  MenuModel({
    required this.idMenu,
    required this.nama,
    required this.harga,
    required this.kategori,
    this.imageUrl = '',
    this.isAvailable = true,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    // Parse Harga ke Int secara aman
    int hargaInt = 0;
    if (json['harga'] is int) {
      hargaInt = json['harga'];
    } else if (json['harga'] is String) {
      hargaInt = int.tryParse(json['harga']) ?? 0;
    } else if (json['harga'] is double) {
      hargaInt = (json['harga'] as double).toInt();
    }

    return MenuModel(
      idMenu: json['id_menu']?.toString() ?? '',
      nama: json['nama_menu'] ?? 'No Name',
      harga: hargaInt,
      kategori: json['kategori'] ?? 'UMUM',
      imageUrl: json['image_url'] ?? '',
      isAvailable: json['status_tersedia'] == true || json['status_tersedia'] == 'true' || json['status_tersedia'] == 1,
    );
  }
}
