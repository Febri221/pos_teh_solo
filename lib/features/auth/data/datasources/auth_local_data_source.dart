import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class AuthLocalDataSource {
  final AppDatabase database;

  AuthLocalDataSource(this.database);

  // Seeding akun default (Owner dan Mamak) jika database kosong
  Future<void> seedDefaultUsers() async {
    final existingUsers = await database.select(database.users).get();
    if (existingUsers.isEmpty) {
      await database.batch((batch) {
        batch.insertAll(
          database.users,
          [
            UsersCompanion.insert(
              name: 'Adhe Muhadzyre',
              pin: '1234', // PIN default Owner
              role: 'owner',
            ),
            UsersCompanion.insert(
              name: 'Mamak',
              pin: '5678', // PIN default Mamak
              role: 'cashier',
            ),
          ],
        );
      });
    }
  }

  // Ambil semua daftar user untuk pilihan login
  Future<List<User>> getAllUsers() async {
    await seedDefaultUsers();
    return await database.select(database.users).get();
  }

  // Verifikasi login berdasarkan ID user dan PIN
  Future<User?> loginWithPin(int userId, String pin) async {
    final user = await (database.select(database.users)
          ..where((u) => u.id.equals(userId) & u.pin.equals(pin)))
        .getSingleOrNull();
    return user;
  }
}