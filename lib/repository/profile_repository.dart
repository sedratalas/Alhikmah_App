// في ملف جديد: lib/repository/profile_repository.dart
import 'package:alhekmah_app/model/profile_model.dart';
import 'package:alhekmah_app/model/wallet_model.dart';
import 'package:alhekmah_app/service/profile_service.dart';

class ProfileRepository {
  final ProfileService profileService;

  ProfileRepository({required this.profileService});

  Future<ProfileModel?> getProfile() async {
    return await profileService.getProfile();
  }

  Future<WalletModel?> getWallet() async {
    return await profileService.getWallet();
  }
}