import 'package:equatable/equatable.dart';
import '../../../../core/database/app_database.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class UsersLoadedForLogin extends AuthState {
  final List<User> users;
  const UsersLoadedForLogin(this.users);
  @override
  List<Object> get props => [users];
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthLoginFailed extends AuthState {
  final String message;
  const AuthLoginFailed(this.message);
  @override
  List<Object> get props => [message];
}