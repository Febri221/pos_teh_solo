import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../../../../core/database/app_database.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<List<User>> getUsers() async {
    return await localDataSource.getAllUsers();
  }

  @override
  Future<User?> login(int userId, String pin) async {
    return await localDataSource.loginWithPin(userId, pin);
  }
}