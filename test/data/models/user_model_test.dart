import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/data/models/user_model.dart';

/// Unit tests untuk UserModel
/// Menguji prinsip OOP:
/// - Factory constructor (fromJson)
/// - Serialization (toJson)
/// - Enum parsing (UserRole)
/// - Permission checking
void main() {
  group('UserModel Tests', () {
    test('fromJson should correctly parse user data', () {
      final json = {
        'id_user': '1',
        'username': 'owner_test',
        'role': 'OWNER',
      };

      final user = UserModel.fromJson(json);

      expect(user.idUser, '1');
      expect(user.username, 'owner_test');
      expect(user.role, UserRole.owner);
    });

    test('fromJson should handle string id_user', () {
      final json = {
        'id_user': 'uuid-123',
        'username': 'kasir_test',
        'role': 'KASIR',
      };

      final user = UserModel.fromJson(json);

      expect(user.idUser, 'uuid-123');
      expect(user.role, UserRole.kasir);
    });

    test('toJson should correctly serialize user data', () {
      const user = UserModel(
        idUser: '1',
        username: 'test_user',
        role: UserRole.barista,
      );

      final json = user.toJson();

      expect(json['id_user'], '1');
      expect(json['username'], 'test_user');
      expect(json['role'], 'BARISTA');
    });

    test('copyWith should create new instance with updated values', () {
      const original = UserModel(
        idUser: '1',
        username: 'original',
        role: UserRole.kasir,
      );

      final updated = original.copyWith(username: 'updated');

      expect(updated.username, 'updated');
      expect(updated.idUser, '1'); // unchanged
      expect(updated.role, UserRole.kasir); // unchanged
    });
  });

  group('UserRole Tests', () {
    test('fromString should parse role correctly', () {
      expect(UserRoleExtension.fromString('OWNER'), UserRole.owner);
      expect(UserRoleExtension.fromString('KASIR'), UserRole.kasir);
      expect(UserRoleExtension.fromString('BARISTA'), UserRole.barista);
    });

    test('fromString should default to kasir for unknown role', () {
      expect(UserRoleExtension.fromString('UNKNOWN'), UserRole.kasir);
      expect(UserRoleExtension.fromString(''), UserRole.kasir);
    });

    test('value should return uppercase role string', () {
      expect(UserRole.owner.value, 'OWNER');
      expect(UserRole.kasir.value, 'KASIR');
      expect(UserRole.barista.value, 'BARISTA');
    });
  });

  group('UserModel Permission Tests', () {
    test('isOwner should return true for owner role', () {
      const owner = UserModel(
        idUser: '1',
        username: 'owner',
        role: UserRole.owner,
      );

      expect(owner.isOwner, true);
      expect(owner.isKasir, false);
      expect(owner.isBarista, false);
    });

    test('isKasir should return true for kasir role', () {
      const kasir = UserModel(
        idUser: '2',
        username: 'kasir',
        role: UserRole.kasir,
      );

      expect(kasir.isOwner, false);
      expect(kasir.isKasir, true);
      expect(kasir.isBarista, false);
    });

    test('isBarista should return true for barista role', () {
      const barista = UserModel(
        idUser: '3',
        username: 'barista',
        role: UserRole.barista,
      );

      expect(barista.isOwner, false);
      expect(barista.isKasir, false);
      expect(barista.isBarista, true);
    });

    test('canManageMenu should return correct permissions', () {
      const owner = UserModel(idUser: '1', username: 'owner', role: UserRole.owner);
      const kasir = UserModel(idUser: '2', username: 'kasir', role: UserRole.kasir);
      const barista = UserModel(idUser: '3', username: 'barista', role: UserRole.barista);

      expect(owner.canManageMenu, true);
      expect(kasir.canManageMenu, true);
      expect(barista.canManageMenu, false);
    });

    test('canDeleteMenu should return correct permissions', () {
      const owner = UserModel(idUser: '1', username: 'owner', role: UserRole.owner);
      const kasir = UserModel(idUser: '2', username: 'kasir', role: UserRole.kasir);
      const barista = UserModel(idUser: '3', username: 'barista', role: UserRole.barista);

      expect(owner.canDeleteMenu, true);
      expect(kasir.canDeleteMenu, false);
      expect(barista.canDeleteMenu, false);
    });

    test('canCreateOrder should return correct permissions', () {
      const owner = UserModel(idUser: '1', username: 'owner', role: UserRole.owner);
      const kasir = UserModel(idUser: '2', username: 'kasir', role: UserRole.kasir);
      const barista = UserModel(idUser: '3', username: 'barista', role: UserRole.barista);

      expect(owner.canCreateOrder, true);
      expect(kasir.canCreateOrder, true);
      expect(barista.canCreateOrder, false);
    });
  });

  group('UserModel Equality Tests', () {
    test('two users with same data should be equal', () {
      const user1 = UserModel(
        idUser: '1',
        username: 'test',
        role: UserRole.owner,
      );
      const user2 = UserModel(
        idUser: '1',
        username: 'test',
        role: UserRole.owner,
      );

      expect(user1, equals(user2));
    });

    test('two users with different data should not be equal', () {
      const user1 = UserModel(
        idUser: '1',
        username: 'test1',
        role: UserRole.owner,
      );
      const user2 = UserModel(
        idUser: '2',
        username: 'test2',
        role: UserRole.kasir,
      );

      expect(user1, isNot(equals(user2)));
    });
  });
}

