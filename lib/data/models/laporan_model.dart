import 'package:equatable/equatable.dart';

/// Model untuk menu terlaris dalam laporan
class MenuTerlaris extends Equatable {
  final String idMenu;
  final String namaMenu;
  final int totalTerjual;

  const MenuTerlaris({
    required this.idMenu,
    required this.namaMenu,
    required this.totalTerjual,
  });

  factory MenuTerlaris.fromJson(Map<String, dynamic> json) {
    return MenuTerlaris(
      idMenu: json['id_menu']?.toString() ?? '',
      namaMenu: json['nama_menu'] ?? '-',
      totalTerjual: (json['total_terjual'] ?? 0) is int 
          ? json['total_terjual'] 
          : int.parse(json['total_terjual'].toString()),
    );
  }

  @override
  List<Object?> get props => [idMenu, namaMenu, totalTerjual];
}

/// Model untuk ringkasan laporan penjualan dari backend
/// Sesuai dengan response dari GET /laporan/penjualan
class LaporanPenjualanResponse extends Equatable {
  final DateTime dari;
  final DateTime sampai;
  final int totalOrder;
  final double totalOmzet;
  final int totalItem;
  final List<MenuTerlaris> menuTerlaris;

  const LaporanPenjualanResponse({
    required this.dari,
    required this.sampai,
    required this.totalOrder,
    required this.totalOmzet,
    required this.totalItem,
    required this.menuTerlaris,
  });

  factory LaporanPenjualanResponse.fromJson(Map<String, dynamic> json) {
    // Parse periode
    final periode = json['periode'] as Map<String, dynamic>?;
    final dari = periode?['dari'] != null 
        ? DateTime.parse(periode!['dari']) 
        : DateTime.now();
    final sampai = periode?['sampai'] != null 
        ? DateTime.parse(periode!['sampai']) 
        : DateTime.now();

    // Parse menu terlaris
    final menuTerlarisList = (json['menu_terlaris'] as List<dynamic>?)
        ?.map((item) => MenuTerlaris.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    return LaporanPenjualanResponse(
      dari: dari,
      sampai: sampai,
      totalOrder: (json['total_order'] ?? 0) is int 
          ? json['total_order'] 
          : int.parse(json['total_order'].toString()),
      totalOmzet: (json['total_omzet'] ?? 0).toDouble(),
      totalItem: (json['total_item'] ?? 0) is int 
          ? json['total_item'] 
          : int.parse(json['total_item'].toString()),
      menuTerlaris: menuTerlarisList,
    );
  }

  /// Format total omzet
  String get totalOmzetFormatted {
    return 'Rp ${totalOmzet.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Format rata-rata per order
  double get rataRataPerOrder => totalOrder > 0 ? totalOmzet / totalOrder : 0;

  String get rataRataPerOrderFormatted {
    return 'Rp ${rataRataPerOrder.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Format periode
  String get periodeFormatted {
    return '${dari.day.toString().padLeft(2, '0')}/'
           '${dari.month.toString().padLeft(2, '0')}/'
           '${dari.year} - '
           '${sampai.day.toString().padLeft(2, '0')}/'
           '${sampai.month.toString().padLeft(2, '0')}/'
           '${sampai.year}';
  }

  @override
  List<Object?> get props => [dari, sampai, totalOrder, totalOmzet, totalItem, menuTerlaris];
}

/// Model untuk item laporan penjualan (backward compatibility)
/// Menerapkan prinsip OOP: Encapsulation dan Computed Properties
class LaporanItem extends Equatable {
  final String idOrder;
  final DateTime tanggal;
  final String namaMenu;
  final int jumlah;
  final double totalHarga;
  final String status;
  final String? namaPetugas;

  const LaporanItem({
    required this.idOrder,
    required this.tanggal,
    required this.namaMenu,
    required this.jumlah,
    required this.totalHarga,
    required this.status,
    this.namaPetugas,
  });

  factory LaporanItem.fromJson(Map<String, dynamic> json) {
    String? namaMenu;
    if (json['Menu'] != null) {
      namaMenu = json['Menu']['nama_menu'];
    }

    return LaporanItem(
      idOrder: json['id_order']?.toString() ?? '',
      tanggal: json['tanggal'] != null 
          ? DateTime.parse(json['tanggal']) 
          : DateTime.now(),
      namaMenu: namaMenu ?? json['nama_menu'] ?? '-',
      jumlah: json['jumlah_order'] ?? 1,
      totalHarga: (json['total_harga'] ?? json['total_bayar'] ?? 0).toDouble(),
      status: json['status_pesanan'] ?? json['status'] ?? 'SELESAI',
      namaPetugas: json['User']?['username'],
    );
  }

  String get totalHargaFormatted {
    return 'Rp ${totalHarga.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String get tanggalFormatted {
    return '${tanggal.day.toString().padLeft(2, '0')}/'
           '${tanggal.month.toString().padLeft(2, '0')}/'
           '${tanggal.year}';
  }

  @override
  List<Object?> get props => [idOrder, tanggal, namaMenu, jumlah, totalHarga];
}

/// Model untuk ringkasan laporan (backward compatibility)
/// Menerapkan OOP: Aggregation untuk menghitung total
class LaporanSummary extends Equatable {
  final List<LaporanItem> items;
  final DateTime? startDate;
  final DateTime? endDate;

  const LaporanSummary({
    required this.items,
    this.startDate,
    this.endDate,
  });

  /// Total pendapatan
  double get totalPendapatan => 
      items.fold(0, (sum, item) => sum + item.totalHarga);

  /// Total transaksi
  int get totalTransaksi => items.length;

  /// Total item terjual
  int get totalItemTerjual => 
      items.fold(0, (sum, item) => sum + item.jumlah);

  /// Rata-rata per transaksi
  double get rataRataPerTransaksi => 
      totalTransaksi > 0 ? totalPendapatan / totalTransaksi : 0;

  /// Format total pendapatan
  String get totalPendapatanFormatted {
    return 'Rp ${totalPendapatan.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Format rata-rata
  String get rataRataFormatted {
    return 'Rp ${rataRataPerTransaksi.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Menu terlaris
  Map<String, int> get menuTerlaris {
    final Map<String, int> countMap = {};
    for (final item in items) {
      countMap[item.namaMenu] = (countMap[item.namaMenu] ?? 0) + item.jumlah;
    }
    // Sort by count descending
    final sorted = countMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5)); // Top 5
  }

  @override
  List<Object?> get props => [items, startDate, endDate];
}
