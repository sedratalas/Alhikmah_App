import 'package:alhekmah_app/screen/all_books/bloc/all_book_bloc.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:alhekmah_app/service/book_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'model/hadith_model.dart';
import 'screen/ahadith/ahadith_screen.dart';
import 'screen/all_books/all_books_screen.dart';
import 'screen/bouquet/bouquet_screen.dart';
import 'screen/hadeth_recitation/hadeth_recitation_screen.dart';
import 'screen/sign_up/signup_step1_screen.dart';
import 'screen/sign_up/signup_step2_screen.dart';
import 'screen/splash/splash_screen.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final bookService = BookService();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => HadithBloc(
                ahadithList: ahadithList,
                initialIndex: 0,
            ),
        ),
        BlocProvider(create: (context)=> AllBookBloc(bookService: bookService)..add(FetchAllBooks()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AllBooksScreen(),
      ),
    );
  }
}

