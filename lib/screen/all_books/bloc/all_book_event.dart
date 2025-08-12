part of 'all_book_bloc.dart';

@immutable
sealed class AllBookEvent {}
class FetchAllBooks extends AllBookEvent{}
