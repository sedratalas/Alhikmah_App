import 'package:alhekmah_app/model/standard_remote_book.dart';
import 'package:alhekmah_app/repository/book_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'all_book_event.dart';
part 'all_book_state.dart';

class AllBookBloc extends Bloc<AllBookEvent, AllBookState> {
  final BookRepository bookRepository;
  AllBookBloc({required this.bookRepository}) : super(AllBookInitial()) {
    on<FetchAllBooks>((event, emit) async {
      emit(LoadingBooksState());
      try {
        final books = await bookRepository.getAllBooks();
        emit(SuccessLoadingBooksState(books: books));
      } catch (e) {
        emit(FailedLoadingBooksState(message: e.toString()));
      }
    });
  }
}