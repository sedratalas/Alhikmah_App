part of 'signup_bloc.dart';

@immutable
sealed class SignupEvent {}
class TrySignup extends SignupEvent{
  final SignupModel signupModel;
  TrySignup({required this.signupModel});
}
