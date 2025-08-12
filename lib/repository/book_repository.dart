// import 'package:alhekmah_app/model/standard_remote_book.dart';
// import 'package:alhekmah_app/service/book_service.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:hive/hive.dart';
// import 'package:alhekmah_app/data/local_data.dart';
//
// class BookRepository {
//   final BookService _bookService;
//   late final Box<RemotBook> _bookBox;
//
//   BookRepository(this._bookService);
//
//   Future<void> init() async {
//     _bookBox = await Hive.openBox<RemotBook>('booksBox');
//   }
//
//   Future<List<RemotBook>> getAllBooks() async {
//
//     final localBooks = [getLocalArbaeenBook()];
//
//     try {
//       final connectivityResult = await (Connectivity().checkConnectivity());
//       if (connectivityResult != ConnectivityResult.none) {
//
//         final remoteBooks = await _bookService.getAllBooks();
//
//         await _bookBox.clear();
//         await _bookBox.addAll(remoteBooks);
//
//         return [...localBooks, ...remoteBooks];
//       } else {
//         final savedBooks = _bookBox.values.toList();
//         if (savedBooks.isNotEmpty) {
//           return [...localBooks, ...savedBooks];
//         } else {
//
//           throw Exception("لا يوجد اتصال بالإنترنت ولا توجد بيانات مخزنة.");
//         }
//       }
//     } catch (e) {
//
//       final savedBooks = _bookBox.values.toList();
//       if (savedBooks.isNotEmpty) {
//         return [...localBooks, ...savedBooks];
//       }
//       throw Exception("حدث خطأ في تحميل البيانات.");
//     }
//   }
// }
import 'package:alhekmah_app/model/standard_remote_book.dart';
import 'package:alhekmah_app/service/book_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:alhekmah_app/data/local_data.dart';

class BookRepository {
  final BookService _bookService;
  late final Box<RemotBook> _bookBox;

  BookRepository(this._bookService);

  Future<void> init() async {
    _bookBox = await Hive.openBox<RemotBook>('booksBox');
    print('Hive box "booksBox" is initialized and open.');
  }

  Future<List<RemotBook>> getAllBooks() async {
    print('getAllBooks() function started.');
    final localBooks = [getLocalArbaeenBook()];
    print('Local books created. Count: ${localBooks.length}');

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      print('Connectivity check result: $connectivityResult');

      if (connectivityResult != ConnectivityResult.none) {
        print('Internet connection detected. Fetching data from API...');

        // هاد السطر هو الأهم: ممكن يكون فيه خطأ في الـ API
        final remoteBooks = await _bookService.getAllBooks();
        print('Successfully fetched ${remoteBooks.length} remote books.');

        await _bookBox.clear();
        await _bookBox.addAll(remoteBooks);
        print('Successfully saved remote books to Hive.');

        return [...localBooks, ...remoteBooks];
      } else {
        print('No internet connection. Trying to load from Hive...');
        final savedBooks = _bookBox.values.toList();
        if (savedBooks.isNotEmpty) {
          print('Found ${savedBooks.length} saved books in Hive.');
          return [...localBooks, ...savedBooks];
        } else {
          print('Hive box is empty.');
          throw Exception("لا يوجد اتصال بالإنترنت ولا توجد بيانات مخزنة.");
        }
      }
    } catch (e) {
      // هاد الجزء بيمسك أي خطأ وبيطبعلك رسالته بالضبط
      print('An unexpected error occurred: $e');
      final savedBooks = _bookBox.values.toList();
      if (savedBooks.isNotEmpty) {
        print('Loading data from Hive due to previous error. Found ${savedBooks.length} books.');
        return [...localBooks, ...savedBooks];
      }
      throw Exception("حدث خطأ في تحميل البيانات: $e");
    }
  }
}