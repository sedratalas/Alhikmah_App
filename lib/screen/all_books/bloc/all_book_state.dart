part of 'all_book_bloc.dart';

@immutable
sealed class AllBookState {}

final class AllBookInitial extends AllBookState {}
class LoadingBooksState extends AllBookState {}

class SuccessLoadingBooksState extends AllBookState {
  final List<RemotBook> books;
  SuccessLoadingBooksState({required this.books});
}

class FailedLoadingBooksState extends AllBookState {
  final String message;
  FailedLoadingBooksState({required this.message});
}