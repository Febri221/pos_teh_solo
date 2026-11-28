import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoadUsersForLogin extends AuthEvent {}

class AttemptLogin extends AuthEvent {
  final int userId;
  final String pin;
  const AttemptLogin({required this.userId, required this.pin});
  @override
  List<Object> get props => [userId, pin];
}

class LogoutRequested extends AuthEvent {}