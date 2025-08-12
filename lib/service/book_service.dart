import 'package:alhekmah_app/model/remote_book.dart';
import 'package:alhekmah_app/model/remote_hadith.dart';
import 'package:dio/dio.dart';

class BookService{
  Dio dio = Dio();
  late Response response;
  String baseUrl = 'https://alhekmah-server-side.onrender.com/books/';

  Future<RemotBook?> getOneBook (String bookId)async{
    try{
      response = await dio.get(baseUrl+bookId);
      return RemotBook.fromJson(response.data);
    }catch(e){
      return null;
    }
  }

  Future<List<RemotBook>> getAllBooks()async{
    try{
      response = await dio.get(baseUrl);
      List<RemotBook> books = [];
      for(int i=0; i< response.data.length ;i++){
        books.add(RemotBook.fromJson(response.data[i]));
      }
      return books;
    }catch(e){
      print(e);
      return [];
    }
}

Future<List<RemotHadith>?>getBookHadiths(String bookId)async{
    try{
      response = await dio.get(bookId+"/hadiths");
      List<RemotHadith> hadiths = [];
      for(int i=0; i< response.data.length ;i++){
        hadiths.add(RemotHadith.fromJson(response.data[i]));
      }
      return hadiths;
    }catch(e){
      print(e);
      return null;
    }
}

}