import 'package:alhekmah_app/model/signup_model.dart';
import 'package:alhekmah_app/service/auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthenticationService authenticationService;
  SignupBloc({required this.authenticationService}) : super(SignupInitial()) {
    on<TrySignup>((event, emit) async{
      emit(SignupLoading());
      try{
       await authenticationService.register(user: event.signupModel);
        emit(SignupSuccess());
      }catch(e){
        emit(SignupFailed(message: "$e"));
      }
    });
  }
}
