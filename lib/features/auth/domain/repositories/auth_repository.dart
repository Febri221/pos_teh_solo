import '../../../../core/database/app_database.dart';

abstract class AuthRepository {
  Future<List<User>> getUsers();
  Future<User?> login(int userId, String pin);
}