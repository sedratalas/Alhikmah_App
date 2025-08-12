import 'package:alhekmah_app/model/remote_book.dart';
import 'package:alhekmah_app/service/book_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'all_book_event.dart';
part 'all_book_state.dart';

class AllBookBloc extends Bloc<AllBookEvent, AllBookState> {
  final BookService bookService;
  AllBookBloc({required this.bookService}) : super(AllBookInitial()) {
    on<FetchAllBooks>((event, emit) async{
      emit(LoadingBooksState());
      try{
        final List<RemotBook> RemoteBooks = await bookService.getAllBooks();
        emit(SuccessLoadingBooksState(remotBook: RemoteBooks));
      }catch(e){
        emit(FailedLoadingBooksState(message: "$e"));
      }
    });
  }
}
