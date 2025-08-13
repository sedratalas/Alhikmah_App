part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}
class LoadingProfileState extends ProfileState {}

class SuccessLoadingProfileState extends ProfileState {
  final ProfileModel profileModel;
  final WalletModel walletModel;
  SuccessLoadingProfileState({required this.profileModel, required this.walletModel});
}

class FailedLoadingProfileState extends ProfileState {
  final String message;
  FailedLoadingProfileState({required this.message});
}