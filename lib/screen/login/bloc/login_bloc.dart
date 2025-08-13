import 'package:alhekmah_app/model/login_model.dart';
import 'package:alhekmah_app/model/token_model.dart';
import 'package:alhekmah_app/service/auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationService authenticationService;

  LoginBloc({required this.authenticationService}) : super(LoginInitial()) {
    on<TryLogin>((event, emit) async {
      emit(LoginLoading());
      try {
        final TokenResponseModel tokenResponse = await authenticationService.login(
          user: LoginRequestModel(
            username: event.username,
            password: event.password,
          ),
        );


        final box = Hive.box('tokenBox');


        await box.put('accessToken', tokenResponse.accessToken);
        await box.put('refreshToken', tokenResponse.refreshToken);

        emit(LoginSuccess());

      } catch (e) {
        emit(LoginFailed(message: "$e"));
      }
    });
  }
}