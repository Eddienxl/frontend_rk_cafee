import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/menu_model.dart';

/// Unit tests untuk MenuModel
/// Menguji prinsip OOP:
/// - Factory constructor (fromJson)
/// - Computed properties (hargaFormatted)
/// - Immutability (copyWith)
void main() {
  group('MenuModel Tests', () {
    test('fromJson should correctly parse menu data', () {
      final json = {
        'id_menu': '1',
        'nama_menu': 'Kopi Susu',
        'kategori': 'Minuman',
        'harga': 15000,
        'status_tersedia': true,
      };

      final menu = MenuModel.fromJson(json);

      expect(menu.idMenu, '1');
      expect(menu.namaMenu, 'Kopi Susu');
      expect(menu.kategori, 'Minuman');
      expect(menu.harga, 15000);
      expect(menu.statusTersedia, true);
    });

    test('fromJson should handle missing optional fields', () {
      final json = {
        'id_menu': '2',
        'nama_menu': 'Teh Manis',
        'harga': 5000,
      };

      final menu = MenuModel.fromJson(json);

      expect(menu.idMenu, '2');
      expect(menu.namaMenu, 'Teh Manis');
      expect(menu.kategori, isNull);
      expect(menu.statusTersedia, true); // default value
    });

    test('toJson should correctly serialize menu data', () {
      const menu = MenuModel(
        idMenu: '1',
        namaMenu: 'Nasi Goreng',
        kategori: 'Makanan',
        harga: 25000,
      );

      final json = menu.toJson();

      expect(json['id_menu'], '1');
      expect(json['nama_menu'], 'Nasi Goreng');
      expect(json['kategori'], 'Makanan');
      expect(json['harga'], 25000);
    });

    test('hargaFormatted should format price correctly', () {
      const menu = MenuModel(
        idMenu: '1',
        namaMenu: 'Test',
        harga: 25000,
      );

      expect(menu.hargaFormatted, 'Rp 25.000');
    });

    test('hargaFormatted should handle large numbers', () {
      const menu = MenuModel(
        idMenu: '1',
        namaMenu: 'Test',
        harga: 1500000,
      );

      expect(menu.hargaFormatted, 'Rp 1.500.000');
    });

    test('copyWith should create new instance with updated values', () {
      const original = MenuModel(
        idMenu: '1',
        namaMenu: 'Original',
        kategori: 'Minuman',
        harga: 10000,
      );

      final updated = original.copyWith(
        namaMenu: 'Updated',
        harga: 15000,
      );

      expect(updated.namaMenu, 'Updated');
      expect(updated.harga, 15000);
      expect(updated.idMenu, '1'); // unchanged
      expect(updated.kategori, 'Minuman'); // unchanged
    });

    test('statusTersedia should check availability correctly', () {
      const available = MenuModel(
        idMenu: '1',
        namaMenu: 'Test',
        harga: 10000,
        statusTersedia: true,
      );

      const unavailable = MenuModel(
        idMenu: '2',
        namaMenu: 'Test2',
        harga: 10000,
        statusTersedia: false,
      );

      expect(available.statusTersedia, true);
      expect(unavailable.statusTersedia, false);
    });
  });
}

