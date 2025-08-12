part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class TryLogin extends LoginEvent {
  final String username;
  final String password;
  TryLogin({required this.username, required this.password});
}