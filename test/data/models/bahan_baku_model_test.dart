import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/bahan_baku_model.dart';

/// Unit tests untuk BahanBakuModel
/// Menguji prinsip OOP:
/// - Factory constructor
/// - Computed properties (stok status)
/// - Validation methods
void main() {
  group('BahanBakuModel Tests', () {
    test('fromJson should correctly parse bahan baku data', () {
      final json = {
        'id_bahan': '1',
        'nama_bahan': 'Kopi Arabica',
        'stok_saat_ini': 100.5,
        'satuan': 'gram',
        'stok_minimum': 50,
      };

      final bahan = BahanBakuModel.fromJson(json);

      expect(bahan.idBahan, '1');
      expect(bahan.namaBahan, 'Kopi Arabica');
      expect(bahan.stokSaatIni, 100.5);
      expect(bahan.satuan, 'gram');
      expect(bahan.stokMinimum, 50);
    });

    test('fromJson should handle integer stok', () {
      final json = {
        'id_bahan': '2',
        'nama_bahan': 'Susu',
        'stok_saat_ini': 50, // integer instead of double
        'satuan': 'ml',
        'stok_minimum': 10,
      };

      final bahan = BahanBakuModel.fromJson(json);

      expect(bahan.stokSaatIni, 50.0);
    });

    test('toJson should correctly serialize data', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Gula',
        stokSaatIni: 500,
        satuan: 'gram',
        stokMinimum: 100,
      );

      final json = bahan.toJson();

      expect(json['id_bahan'], '1');
      expect(json['nama_bahan'], 'Gula');
      expect(json['stok_saat_ini'], 500);
    });

    test('isStokRendah should return true when stok <= minimum', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Test',
        stokSaatIni: 50,
        satuan: 'gram',
        stokMinimum: 50,
      );

      expect(bahan.isStokRendah, true);
    });

    test('isStokRendah should return false when stok > minimum', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Test',
        stokSaatIni: 100,
        satuan: 'gram',
        stokMinimum: 50,
      );

      expect(bahan.isStokRendah, false);
    });

    test('isStokHabis should return true when stok <= 0', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Test',
        stokSaatIni: 0,
        satuan: 'gram',
        stokMinimum: 50,
      );

      expect(bahan.isStokHabis, true);
    });

    test('isStokAman should return true when stok > minimum', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Kopi',
        stokSaatIni: 100,
        satuan: 'gram',
        stokMinimum: 50,
      );

      expect(bahan.isStokAman, true);
    });

    test('stokFormatted should display stok with unit', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Kopi',
        stokSaatIni: 100.5,
        satuan: 'gram',
        stokMinimum: 50,
      );

      expect(bahan.stokFormatted, '100.5 gram');
    });

    test('copyWith should create new instance with updated values', () {
      const original = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Original',
        stokSaatIni: 100,
        satuan: 'gram',
        stokMinimum: 50,
      );

      final updated = original.copyWith(stokSaatIni: 200);

      expect(updated.stokSaatIni, 200);
      expect(updated.namaBahan, 'Original'); // unchanged
    });
  });

  group('BahanBakuModel Stok Percentage Tests', () {
    test('stokPercentage should calculate correctly', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Test',
        stokSaatIni: 100,
        satuan: 'gram',
        stokMinimum: 50,
      );

      // 100 / 50 * 100 = 200%
      expect(bahan.stokPercentage, 200);
    });

    test('stokPercentage should return 100 when minimum is 0', () {
      const bahan = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Test',
        stokSaatIni: 100,
        satuan: 'gram',
        stokMinimum: 0,
      );

      expect(bahan.stokPercentage, 100);
    });
  });

  group('BahanBakuModel Equality Tests', () {
    test('two bahan with same data should be equal', () {
      const bahan1 = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Kopi',
        stokSaatIni: 100,
        satuan: 'gram',
        stokMinimum: 50,
      );
      const bahan2 = BahanBakuModel(
        idBahan: '1',
        namaBahan: 'Kopi',
        stokSaatIni: 100,
        satuan: 'gram',
        stokMinimum: 50,
      );

      expect(bahan1, equals(bahan2));
    });
  });
}

