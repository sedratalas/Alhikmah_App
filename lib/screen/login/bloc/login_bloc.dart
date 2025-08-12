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
        final token = await authenticationService.login(
          user: LoginRequestModel(
            username: event.username,
            password: event.password,
          ),
        );
        final box = await Hive.openBox('tokenBox');
        await box.put('tokens', token);
        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailed(message: "$e"));
      }
    });
  }
}