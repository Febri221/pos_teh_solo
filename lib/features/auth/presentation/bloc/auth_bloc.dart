import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';



class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoadUsersForLogin>((event, emit) async {
      emit(AuthLoading());
      try {
        final users = await repository.getUsers();
        emit(UsersLoadedForLogin(users));
      } catch (e) {
        emit(AuthLoginFailed(e.toString()));
      }
    });

    on<AttemptLogin>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await repository.login(event.userId, event.pin);
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const AuthLoginFailed('PIN salah! Coba lagi.'));
          final users = await repository.getUsers();
          emit(UsersLoadedForLogin(users));
        }
      } catch (e) {
        emit(AuthLoginFailed(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthInitial());
      final users = await repository.getUsers();
      emit(UsersLoadedForLogin(users));
    });
  }
}