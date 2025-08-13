
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:alhekmah_app/model/profile_model.dart';
import 'package:alhekmah_app/model/wallet_model.dart';

import '../../../repository/profile_repository.dart';


part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<FetchUserProfile>((event, emit) async {
      emit(LoadingProfileState());
      try {
        final profile = await profileRepository.getProfile();
        final wallet = await profileRepository.getWallet();
        print(profile);
        print(wallet);
        if (profile != null && wallet != null) {
          emit(SuccessLoadingProfileState(
            profileModel: profile,
            walletModel: wallet,
          ));
        } else {
          emit(FailedLoadingProfileState(message: "فشل في جلب بيانات المستخدم أو المحفظة."));
        }
      } catch (e) {
        print("error");
        print(e);
        emit(FailedLoadingProfileState(message: e.toString()));
      }
    });
  }
}
