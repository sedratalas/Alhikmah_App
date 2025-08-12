import 'package:alhekmah_app/model/standard_hadith_model.dart';
import 'package:alhekmah_app/screen/all_books/bloc/all_book_bloc.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:alhekmah_app/screen/login/bloc/login_bloc.dart';
import 'package:alhekmah_app/screen/sign_up/bloc/signup_bloc.dart';
import 'package:alhekmah_app/service/book_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';


import 'core/app_service.dart';
import 'model/hadith_model.dart';
import 'model/standard_remote_book.dart';
import 'model/token_model.dart';
import 'repository/book_repository.dart';
import 'screen/ahadith/ahadith_screen.dart';
import 'screen/all_books/all_books_screen.dart';
import 'screen/bouquet/bouquet_screen.dart';
import 'screen/hadeth_recitation/hadeth_recitation_screen.dart';
import 'screen/sign_up/signup_step1_screen.dart';
import 'screen/sign_up/signup_step2_screen.dart';
import 'screen/splash/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(TokenResponseModelAdapter());
  Hive.registerAdapter(HadithAdapter());
  Hive.registerAdapter(RemotBookAdapter());

  await AppServices.init();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(
            create: (_) => SignupBloc(authenticationService: AppServices.authenticationService)
        ),
        BlocProvider<LoginBloc>(
            create: (_) => LoginBloc(authenticationService: AppServices.authenticationService)
        ),
        BlocProvider<AllBookBloc>(
          create: (_) => AllBookBloc(bookRepository: AppServices.bookRepository)..add(FetchAllBooks()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SignupStep1Screen(),
      ),
    );
  }
}