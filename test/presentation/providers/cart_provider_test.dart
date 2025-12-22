import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/menu_model.dart';
import 'package:frontend_rk_cafee/presentation/providers/cart_provider.dart';

/// Unit tests untuk CartProvider
/// Menguji prinsip OOP:
/// - State Management (ChangeNotifier)
/// - Encapsulation (private state)
/// - Business logic (add, remove, update quantity)
void main() {
  late CartProvider cartProvider;
  late MenuModel testMenu1;
  late MenuModel testMenu2;

  setUp(() {
    cartProvider = CartProvider();
    testMenu1 = const MenuModel(
      idMenu: '1',
      namaMenu: 'Kopi Susu',
      kategori: 'Minuman',
      harga: 15000,
    );
    testMenu2 = const MenuModel(
      idMenu: '2',
      namaMenu: 'Nasi Goreng',
      kategori: 'Makanan',
      harga: 25000,
    );
  });

  group('CartProvider Add Item Tests', () {
    test('addItem should add new item to cart', () {
      cartProvider.addItem(testMenu1);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.menu.idMenu, '1');
      expect(cartProvider.items.first.jumlah, 1);
    });

    test('addItem should increase jumlah if item exists', () {
      cartProvider.addItem(testMenu1);
      cartProvider.addItem(testMenu1);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.jumlah, 2);
    });

    test('addItem should add different items separately', () {
      cartProvider.addItem(testMenu1);
      cartProvider.addItem(testMenu2);

      expect(cartProvider.items.length, 2);
    });
  });

  group('CartProvider Remove Item Tests', () {
    test('removeItem should remove item from cart', () {
      cartProvider.addItem(testMenu1);
      cartProvider.removeItem(testMenu1.idMenu);

      expect(cartProvider.items.length, 0);
    });

    test('removeItem should not affect other items', () {
      cartProvider.addItem(testMenu1);
      cartProvider.addItem(testMenu2);
      cartProvider.removeItem(testMenu1.idMenu);

      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.menu.idMenu, '2');
    });

    test('removeItem should do nothing if item not found', () {
      cartProvider.addItem(testMenu1);
      cartProvider.removeItem('non-existent-id');

      expect(cartProvider.items.length, 1);
    });
  });

  group('CartProvider Update Quantity Tests', () {
    test('updateQuantity should update item jumlah', () {
      cartProvider.addItem(testMenu1);
      cartProvider.updateQuantity(testMenu1.idMenu, 5);

      expect(cartProvider.items.first.jumlah, 5);
    });

    test('updateQuantity should remove item if quantity is 0', () {
      cartProvider.addItem(testMenu1);
      cartProvider.updateQuantity(testMenu1.idMenu, 0);

      expect(cartProvider.items.length, 0);
    });

    test('updateQuantity should remove item if quantity is negative', () {
      cartProvider.addItem(testMenu1);
      cartProvider.updateQuantity(testMenu1.idMenu, -1);

      expect(cartProvider.items.length, 0);
    });
  });

  group('CartProvider Increment/Decrement Tests', () {
    test('incrementItem should increase jumlah by 1', () {
      cartProvider.addItem(testMenu1);
      cartProvider.incrementItem(testMenu1.idMenu);

      expect(cartProvider.items.first.jumlah, 2);
    });

    test('decrementItem should decrease jumlah by 1', () {
      cartProvider.addItem(testMenu1, quantity: 3);
      cartProvider.decrementItem(testMenu1.idMenu);

      expect(cartProvider.items.first.jumlah, 2);
    });

    test('decrementItem should remove item if jumlah becomes 0', () {
      cartProvider.addItem(testMenu1);
      cartProvider.decrementItem(testMenu1.idMenu);

      expect(cartProvider.items.length, 0);
    });
  });

  group('CartProvider Total Calculation Tests', () {
    test('totalPrice should return correct total', () {
      cartProvider.addItem(testMenu1); // 15000
      cartProvider.addItem(testMenu2); // 25000

      expect(cartProvider.totalPrice, 40000);
    });

    test('totalPrice should account for quantities', () {
      cartProvider.addItem(testMenu1);
      cartProvider.addItem(testMenu1); // 15000 * 2 = 30000

      expect(cartProvider.totalPrice, 30000);
    });

    test('totalQuantity should return correct count', () {
      cartProvider.addItem(testMenu1);
      cartProvider.addItem(testMenu1); // 2 items
      cartProvider.addItem(testMenu2); // 1 item

      expect(cartProvider.totalQuantity, 3);
    });

    test('totalPriceFormatted should format correctly', () {
      cartProvider.addItem(testMenu1);
      cartProvider.addItem(testMenu2);

      expect(cartProvider.totalPriceFormatted, 'Rp 40.000');
    });
  });

  group('CartProvider Clear Cart Tests', () {
    test('clearCart should remove all items', () {
      cartProvider.addItem(testMenu1);
      cartProvider.addItem(testMenu2);
      cartProvider.clearCart();

      expect(cartProvider.items.length, 0);
      expect(cartProvider.totalPrice, 0);
    });
  });

  group('CartProvider isEmpty Tests', () {
    test('isEmpty should return true when cart is empty', () {
      expect(cartProvider.isEmpty, true);
    });

    test('isEmpty should return false when cart has items', () {
      cartProvider.addItem(testMenu1);
      expect(cartProvider.isEmpty, false);
    });

    test('isNotEmpty should return true when cart has items', () {
      cartProvider.addItem(testMenu1);
      expect(cartProvider.isNotEmpty, true);
    });
  });

  group('CartProvider Helper Methods Tests', () {
    test('containsItem should return true if item exists', () {
      cartProvider.addItem(testMenu1);
      expect(cartProvider.containsItem(testMenu1.idMenu), true);
    });

    test('containsItem should return false if item not exists', () {
      expect(cartProvider.containsItem('non-existent'), false);
    });

    test('getItem should return item if exists', () {
      cartProvider.addItem(testMenu1);
      final item = cartProvider.getItem(testMenu1.idMenu);
      expect(item, isNotNull);
      expect(item!.menu.idMenu, testMenu1.idMenu);
    });

    test('getItem should return null if item not exists', () {
      final item = cartProvider.getItem('non-existent');
      expect(item, isNull);
    });
  });
}

