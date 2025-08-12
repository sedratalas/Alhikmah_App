part of 'signup_bloc.dart';

@immutable
sealed class SignupState {}

final class SignupInitial extends SignupState {}
class SignupSuccess extends SignupState{}
class SignupFailed extends SignupState{
  final String message;
  SignupFailed({required this.message});

}
class SignupLoading extends SignupState{}

