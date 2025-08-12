
import 'package:alhekmah_app/service/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../model/standard_hadith_model.dart';
import '../model/token_model.dart';
import '../repository/book_repository.dart';
import '../service/book_service.dart';
import '../model/standard_remote_book.dart';

class AppServices {
  static late final AuthenticationService authenticationService;
  static late final BookService bookService;
  static late final BookRepository bookRepository;
  static late final Dio dio;

  static Future<void> init() async {
    dio = Dio();
    bookService = BookService();
    authenticationService = AuthenticationService();


    bookRepository = BookRepository(bookService);
    await bookRepository.init();
  }
}