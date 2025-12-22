import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/menu_model.dart';
import 'package:frontend_rk_cafee/data/models/cart_item_model.dart';

/// Unit tests untuk CartItemModel
/// Menguji prinsip OOP:
/// - Composition: CartItemModel menggunakan MenuModel
/// - Computed properties (subtotal)
/// - Immutability
void main() {
  late MenuModel testMenu;

  setUp(() {
    testMenu = const MenuModel(
      idMenu: '1',
      namaMenu: 'Kopi Susu',
      kategori: 'Minuman',
      harga: 15000,
    );
  });

  group('CartItemModel Tests', () {
    test('should create cart item with menu and jumlah', () {
      final cartItem = CartItemModel(menu: testMenu, jumlah: 2);

      expect(cartItem.menu, testMenu);
      expect(cartItem.jumlah, 2);
    });

    test('subtotal should calculate correctly', () {
      final cartItem = CartItemModel(menu: testMenu, jumlah: 3);

      // 15000 * 3 = 45000
      expect(cartItem.subtotal, 45000);
    });

    test('subtotalFormatted should format correctly', () {
      final cartItem = CartItemModel(menu: testMenu, jumlah: 2);

      // 15000 * 2 = 30000
      expect(cartItem.subtotalFormatted, 'Rp 30.000');
    });

    test('copyWith should update jumlah', () {
      final original = CartItemModel(menu: testMenu, jumlah: 1);
      final updated = original.copyWith(jumlah: 5);

      expect(updated.jumlah, 5);
      expect(updated.menu, testMenu);
      expect(updated.subtotal, 75000);
    });

    test('copyWith without params should return same values', () {
      final original = CartItemModel(menu: testMenu, jumlah: 2);
      final copy = original.copyWith();

      expect(copy.jumlah, 2);
      expect(copy.menu, testMenu);
    });

    test('increment should increase jumlah by 1', () {
      final original = CartItemModel(menu: testMenu, jumlah: 1);
      final incremented = original.increment();

      expect(incremented.jumlah, 2);
    });

    test('decrement should decrease jumlah by 1', () {
      final original = CartItemModel(menu: testMenu, jumlah: 3);
      final decremented = original.decrement();

      expect(decremented.jumlah, 2);
    });

    test('decrement should not go below 1', () {
      final original = CartItemModel(menu: testMenu, jumlah: 1);
      final decremented = original.decrement();

      expect(decremented.jumlah, 1);
    });
  });

  group('CartItemModel Equality Tests', () {
    test('two cart items with same menu should be equal', () {
      final item1 = CartItemModel(menu: testMenu, jumlah: 1);
      final item2 = CartItemModel(menu: testMenu, jumlah: 1);

      expect(item1, equals(item2));
    });

    test('cart items with different jumlah should not be equal', () {
      final item1 = CartItemModel(menu: testMenu, jumlah: 1);
      final item2 = CartItemModel(menu: testMenu, jumlah: 2);

      expect(item1, isNot(equals(item2)));
    });
  });

  group('CartItemModel Edge Cases', () {
    test('should handle zero price menu', () {
      const freeMenu = MenuModel(
        idMenu: '2',
        namaMenu: 'Promo Gratis',
        kategori: 'Promo',
        harga: 0,
      );

      final cartItem = CartItemModel(menu: freeMenu, jumlah: 5);

      expect(cartItem.subtotal, 0);
    });

    test('should handle large quantities', () {
      final cartItem = CartItemModel(menu: testMenu, jumlah: 100);

      expect(cartItem.subtotal, 1500000);
    });
  });
}

