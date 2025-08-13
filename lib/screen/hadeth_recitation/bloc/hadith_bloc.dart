import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alhekmah_app/model/standard_hadith_model.dart';
import 'package:alhekmah_app/model/standard_remote_book.dart';
import 'hadith_event.dart';
import 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final RemotBook book;
  int _currentIndex;

  HadithBloc({
    required this.book,
    required int initialIndex,
  }) : _currentIndex = initialIndex,
        super(HadithLoadingState()) {
    on<FetchHadithByIdEvent>((event, emit) {
      if (event.hadithIndex >= 0 && event.hadithIndex < book.hadiths.length) {
        final hadith = book.hadiths[event.hadithIndex];
        _currentIndex = event.hadithIndex;
        emit(HadithLoadedState(
          currentHadith: hadith,
          currentHadithIndex: _currentIndex,
          totalHadiths: book.hadiths.length,
        ));
      } else {
        emit(const HadithErrorState("الحديث المطلوب غير موجود."));
      }
    });

    on<NextHadithEvent>((event, emit) {
      if (state is HadithLoadedState) {
        if (_currentIndex < book.hadiths.length - 1) {
          _currentIndex++;
          emit(
              HadithLoadedState(
            currentHadithIndex: _currentIndex,
                currentHadith: book.hadiths[_currentIndex],
                totalHadiths: book.hadiths.length,
          ));
        }
      }
    });

    on<PreviousHadithEvent>((event, emit) {
      if (state is HadithLoadedState) {
        if (_currentIndex > 0) {
          _currentIndex--;
          emit(HadithLoadedState(
            currentHadith: book.hadiths[_currentIndex],
            currentHadithIndex: _currentIndex,
            totalHadiths: book.hadiths.length,
          ));
        }
      }
    });
  }
}