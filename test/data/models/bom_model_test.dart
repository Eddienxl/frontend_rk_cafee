import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/bom_model.dart';

/// Unit tests untuk BomModel
/// Menguji prinsip OOP:
/// - Composition (menghubungkan Menu dan BahanBaku)
/// - Factory constructor
/// - Computed properties
void main() {
  group('BomModel Tests', () {
    test('fromJson should correctly parse BOM data', () {
      final json = {
        'id_bom': '1',
        'id_menu': 'menu-1',
        'id_bahan': 'bahan-1',
        'jumlah_dibutuhkan': 50.5,
      };

      final bom = BomModel.fromJson(json);

      expect(bom.idBom, '1');
      expect(bom.idMenu, 'menu-1');
      expect(bom.idBahan, 'bahan-1');
      expect(bom.jumlahDibutuhkan, 50.5);
    });

    test('fromJson should handle nested Menu and BahanBaku data', () {
      final json = {
        'id_bom': '1',
        'id_menu': 'menu-1',
        'id_bahan': 'bahan-1',
        'jumlah_dibutuhkan': 25,
        'Menu': {
          'nama_menu': 'Kopi Susu',
        },
        'BahanBaku': {
          'nama_bahan': 'Kopi Arabica',
          'satuan': 'gram',
        },
      };

      final bom = BomModel.fromJson(json);

      expect(bom.namaMenu, 'Kopi Susu');
      expect(bom.namaBahan, 'Kopi Arabica');
      expect(bom.satuan, 'gram');
    });

    test('fromJson should handle integer jumlah_dibutuhkan', () {
      final json = {
        'id_bom': '2',
        'id_menu': 'menu-2',
        'id_bahan': 'bahan-2',
        'jumlah_dibutuhkan': 100, // integer instead of double
      };

      final bom = BomModel.fromJson(json);

      expect(bom.jumlahDibutuhkan, 100.0);
    });

    test('toJson should correctly serialize data', () {
      const bom = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 75.5,
      );

      final json = bom.toJson();

      expect(json['id_bom'], '1');
      expect(json['id_menu'], 'menu-1');
      expect(json['id_bahan'], 'bahan-1');
      expect(json['jumlah_dibutuhkan'], 75.5);
    });

    test('jumlahFormatted should display with unit', () {
      const bom = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 50.5,
        satuan: 'gram',
      );

      expect(bom.jumlahFormatted, '50.50 gram');
    });

    test('jumlahFormatted should handle null satuan', () {
      const bom = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 25,
      );

      expect(bom.jumlahFormatted, '25.00 ');
    });

    test('copyWith should create new instance with updated values', () {
      const original = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 50,
      );

      final updated = original.copyWith(jumlahDibutuhkan: 100);

      expect(updated.jumlahDibutuhkan, 100);
      expect(updated.idBom, '1'); // unchanged
    });
  });

  group('BomModel Equality Tests', () {
    test('two BOMs with same data should be equal', () {
      const bom1 = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 50,
      );
      const bom2 = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 50,
      );

      expect(bom1, equals(bom2));
    });

    test('two BOMs with different jumlah should not be equal', () {
      const bom1 = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 50,
      );
      const bom2 = BomModel(
        idBom: '1',
        idMenu: 'menu-1',
        idBahan: 'bahan-1',
        jumlahDibutuhkan: 100,
      );

      expect(bom1, isNot(equals(bom2)));
    });
  });
}

