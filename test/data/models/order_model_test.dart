import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/order_model.dart';

/// Unit tests untuk OrderModel
/// Menguji prinsip OOP:
/// - Enum (OrderStatus)
/// - Factory constructor
/// - Status checking
void main() {
  group('OrderModel Tests', () {
    test('fromJson should correctly parse order data', () {
      final json = {
        'id_order': '1',
        'id_user': 'user-1',
        'jumlah_order': 2,
        'total_bayar': 30000,
        'status_pesanan': 'BARU',
        'tanggal': '2024-01-15T10:30:00Z',
        'Menu': {
          'nama_menu': 'Kopi Susu',
        },
      };

      final order = OrderModel.fromJson(json);

      expect(order.idOrder, '1');
      expect(order.idUser, 'user-1');
      expect(order.jumlahOrder, 2);
      expect(order.totalBayar, 30000);
      expect(order.statusPesanan, OrderStatus.baru);
      expect(order.namaMenu, 'Kopi Susu');
    });

    test('fromJson should handle alternative field names', () {
      final json = {
        'id_order': '2',
        'id_user': 'user-2',
        'jumlah_order': 1,
        'total_harga': 15000, // alternative to total_bayar
        'status': 'SEDANG DIBUAT', // alternative to status_pesanan
        'tanggal': '2024-01-15T10:30:00Z',
      };

      final order = OrderModel.fromJson(json);

      expect(order.totalBayar, 15000);
      expect(order.statusPesanan, OrderStatus.sedangDibuat);
    });

    test('fromJson should handle nested Menu data', () {
      final json = {
        'id_order': '3',
        'id_user': 'user-3',
        'jumlah_order': 1,
        'total_bayar': 25000,
        'status_pesanan': 'SELESAI',
        'tanggal': '2024-01-15T10:30:00Z',
        'Menu': {
          'nama_menu': 'Nasi Goreng',
        },
      };

      final order = OrderModel.fromJson(json);

      expect(order.namaMenu, 'Nasi Goreng');
    });

    test('toJson should correctly serialize order data', () {
      final order = OrderModel(
        idOrder: '1',
        idUser: 'user-1',
        jumlahOrder: 2,
        totalBayar: 30000,
        statusPesanan: OrderStatus.baru,
        tanggal: DateTime(2024, 1, 15, 10, 30),
      );

      final json = order.toJson();

      expect(json['id_order'], '1');
      expect(json['id_user'], 'user-1');
      expect(json['total_bayar'], 30000);
      expect(json['status_pesanan'], 'BARU');
    });

    test('totalBayarFormatted should format correctly', () {
      final order = OrderModel(
        idOrder: '1',
        idUser: 'user-1',
        jumlahOrder: 1,
        totalBayar: 25000,
        statusPesanan: OrderStatus.baru,
        tanggal: DateTime.now(),
      );

      expect(order.totalBayarFormatted, 'Rp 25.000');
    });

    test('copyWith should create new instance with updated values', () {
      final original = OrderModel(
        idOrder: '1',
        idUser: 'user-1',
        jumlahOrder: 1,
        totalBayar: 15000,
        statusPesanan: OrderStatus.baru,
        tanggal: DateTime.now(),
      );

      final updated = original.copyWith(statusPesanan: OrderStatus.selesai);

      expect(updated.statusPesanan, OrderStatus.selesai);
      expect(updated.idOrder, '1'); // unchanged
    });
  });

  group('OrderStatus Tests', () {
    test('fromString should parse status correctly', () {
      expect(OrderStatusExtension.fromString('BARU'), OrderStatus.baru);
      expect(OrderStatusExtension.fromString('SEDANG DIBUAT'), OrderStatus.sedangDibuat);
      expect(OrderStatusExtension.fromString('SELESAI'), OrderStatus.selesai);
    });

    test('fromString should default to baru for unknown status', () {
      expect(OrderStatusExtension.fromString('UNKNOWN'), OrderStatus.baru);
    });

    test('displayName should return readable text', () {
      expect(OrderStatus.baru.displayName, 'Baru');
      expect(OrderStatus.sedangDibuat.displayName, 'Sedang Dibuat');
      expect(OrderStatus.selesai.displayName, 'Selesai');
    });

    test('value should return uppercase text', () {
      expect(OrderStatus.baru.value, 'BARU');
      expect(OrderStatus.sedangDibuat.value, 'SEDANG DIBUAT');
      expect(OrderStatus.selesai.value, 'SELESAI');
    });
  });

  group('OrderModel Status Check Tests', () {
    test('isBaru should return true for new orders', () {
      final baruOrder = OrderModel(
        idOrder: '1',
        idUser: 'user-1',
        jumlahOrder: 1,
        totalBayar: 15000,
        statusPesanan: OrderStatus.baru,
        tanggal: DateTime.now(),
      );

      expect(baruOrder.isBaru, true);
      expect(baruOrder.isSedangDibuat, false);
      expect(baruOrder.isSelesai, false);
    });

    test('isSelesai should return true for completed orders', () {
      final selesaiOrder = OrderModel(
        idOrder: '1',
        idUser: 'user-1',
        jumlahOrder: 1,
        totalBayar: 15000,
        statusPesanan: OrderStatus.selesai,
        tanggal: DateTime.now(),
      );

      expect(selesaiOrder.isBaru, false);
      expect(selesaiOrder.isSedangDibuat, false);
      expect(selesaiOrder.isSelesai, true);
    });
  });
}

