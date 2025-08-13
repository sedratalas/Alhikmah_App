
import 'package:alhekmah_app/model/standard_hadith_model.dart';
import 'package:dio/dio.dart';

import '../model/standard_remote_book.dart';

class BookService{
  final Dio dio;
  BookService({required this.dio});
  late Response response;
  String baseUrl = "books/";

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
      throw Exception("فشل جلب الكتب من السيرفر: $e");
    }
}

Future<List<Hadith>?>getBookHadiths(String bookId)async{
    try{
      response = await dio.get(baseUrl+bookId+"/hadiths");
      List<Hadith> hadiths = [];
      for(int i=0; i< response.data.length ;i++){
        hadiths.add(Hadith.fromJson(response.data[i]));
      }
      return hadiths;
    }catch(e){
      print(e);
      return null;
    }
}

}