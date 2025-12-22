import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/laporan_model.dart';

/// Unit tests untuk LaporanModel
/// Menguji prinsip OOP:
/// - Aggregation (LaporanSummary aggregates LaporanItems)
/// - Computed properties (totals, averages)
void main() {
  group('LaporanItem Tests', () {
    test('fromJson should correctly parse laporan item', () {
      final json = {
        'id_order': '1',
        'tanggal': '2024-01-15T10:30:00Z',
        'nama_menu': 'Kopi Susu',
        'jumlah_order': 2,
        'total_harga': 30000,
        'status_pesanan': 'SELESAI',
      };

      final item = LaporanItem.fromJson(json);

      expect(item.idOrder, '1');
      expect(item.namaMenu, 'Kopi Susu');
      expect(item.jumlah, 2);
      expect(item.totalHarga, 30000);
      expect(item.status, 'SELESAI');
    });

    test('fromJson should handle nested Menu data', () {
      final json = {
        'id_order': '2',
        'tanggal': '2024-01-15T11:00:00Z',
        'jumlah_order': 1,
        'total_bayar': 25000,
        'Menu': {
          'nama_menu': 'Nasi Goreng',
        },
      };

      final item = LaporanItem.fromJson(json);

      expect(item.namaMenu, 'Nasi Goreng');
    });

    test('totalHargaFormatted should format correctly', () {
      final item = LaporanItem(
        idOrder: '1',
        tanggal: DateTime.now(),
        namaMenu: 'Test',
        jumlah: 1,
        totalHarga: 125000,
        status: 'SELESAI',
      );

      expect(item.totalHargaFormatted, 'Rp 125.000');
    });

    test('tanggalFormatted should format date correctly', () {
      final item = LaporanItem(
        idOrder: '1',
        tanggal: DateTime(2024, 1, 15),
        namaMenu: 'Test',
        jumlah: 1,
        totalHarga: 10000,
        status: 'SELESAI',
      );

      expect(item.tanggalFormatted, '15/01/2024');
    });
  });

  group('LaporanSummary Tests', () {
    late List<LaporanItem> testItems;

    setUp(() {
      testItems = [
        LaporanItem(
          idOrder: '1',
          tanggal: DateTime.now(),
          namaMenu: 'Kopi Susu',
          jumlah: 2,
          totalHarga: 30000,
          status: 'SELESAI',
        ),
        LaporanItem(
          idOrder: '2',
          tanggal: DateTime.now(),
          namaMenu: 'Kopi Susu',
          jumlah: 1,
          totalHarga: 15000,
          status: 'SELESAI',
        ),
        LaporanItem(
          idOrder: '3',
          tanggal: DateTime.now(),
          namaMenu: 'Nasi Goreng',
          jumlah: 3,
          totalHarga: 75000,
          status: 'SELESAI',
        ),
      ];
    });

    test('totalPendapatan should sum all totalHarga', () {
      final summary = LaporanSummary(items: testItems);

      expect(summary.totalPendapatan, 120000);
    });

    test('totalTransaksi should count items', () {
      final summary = LaporanSummary(items: testItems);

      expect(summary.totalTransaksi, 3);
    });

    test('totalItemTerjual should sum all jumlah', () {
      final summary = LaporanSummary(items: testItems);

      expect(summary.totalItemTerjual, 6);
    });

    test('rataRataPerTransaksi should calculate average', () {
      final summary = LaporanSummary(items: testItems);

      expect(summary.rataRataPerTransaksi, 40000);
    });

    test('rataRataPerTransaksi should return 0 for empty items', () {
      final summary = LaporanSummary(items: []);

      expect(summary.rataRataPerTransaksi, 0);
    });

    test('menuTerlaris should return top selling items', () {
      final summary = LaporanSummary(items: testItems);
      final terlaris = summary.menuTerlaris;

      // Kopi Susu: 2+1=3, Nasi Goreng: 3
      expect(terlaris.containsKey('Kopi Susu'), true);
      expect(terlaris.containsKey('Nasi Goreng'), true);
      expect(terlaris['Nasi Goreng'], 3);
      expect(terlaris['Kopi Susu'], 3);
    });

    test('totalPendapatanFormatted should format correctly', () {
      final summary = LaporanSummary(items: testItems);

      expect(summary.totalPendapatanFormatted, 'Rp 120.000');
    });
  });
}

