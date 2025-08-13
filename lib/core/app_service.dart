//
// import 'package:alhekmah_app/service/auth_service.dart';
// import 'package:dio/dio.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/adapters.dart';
//
// import '../model/standard_hadith_model.dart';
// import '../model/token_model.dart';
// import '../repository/book_repository.dart';
// import '../service/book_service.dart';
// import '../model/standard_remote_book.dart';
//
// class AppServices {
//   static late final AuthenticationService authenticationService;
//   static late final BookService bookService;
//   static late final BookRepository bookRepository;
//   static late final Dio dio;
//
//   static Future<void> init() async {
//     dio = Dio();
//     bookService = BookService();
//     authenticationService = AuthenticationService();
//
//
//     bookRepository = BookRepository(bookService);
//     await bookRepository.init();
//   }
// }
import 'package:alhekmah_app/service/assembly_ai_service.dart';
import 'package:alhekmah_app/service/auth_service.dart';
import 'package:alhekmah_app/repository/book_repository.dart';
import 'package:alhekmah_app/service/book_service.dart';
import 'package:alhekmah_app/service/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../repository/audio_repository.dart';
import '../repository/profile_repository.dart';
import '../service/audio_service.dart';
import '../service/profile_service.dart';

class AppServices {
  static late final AuthenticationService authenticationService;
  static late final BookService bookService;
  static late final BookRepository bookRepository;
  static late final ProfileService profileService;
  static late final ProfileRepository profileRepository;
  static late final AssemblyAiService assemblyAiService;
  static late final HadithUploadService hadithUploadService;
  static late final HadithRepository hadithRepository;
  static late final DioClient dioClient;

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('tokenBox');
    final tokenBox = Hive.box('tokenBox');

    dioClient = DioClient(tokenBox);

    authenticationService = dioClient.authService;
    bookService = BookService(dio: dioClient.dio);
    profileService = ProfileService(dio: dioClient.dio);
    hadithUploadService = HadithUploadService(dio: dioClient.dio);

    assemblyAiService = AssemblyAiService(dio: Dio());

    bookRepository = BookRepository(bookService);
    profileRepository = ProfileRepository(profileService: profileService);

    hadithRepository = HadithRepository(uploadService: hadithUploadService, assemblyAiService: assemblyAiService);

    await bookRepository.init();
  }
}