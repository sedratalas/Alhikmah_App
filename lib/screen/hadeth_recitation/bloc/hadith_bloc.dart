import 'package:alhekmah_app/model/hadith_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'hadith_event.dart';
import 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState>{
  final List<Hadith> ahadithList;
  int _currentIndex;
  HadithBloc({
    required this.ahadithList,
    required int initialIndex,
  }) : _currentIndex = initialIndex,
        super(HadithLoadingState()){
    on<FetchHadithByIdEvent>( (event,emit){
      if(event.hadithId>=0 && event.hadithId<ahadithList.length){
        final hadith = ahadithList[event.hadithId];
        _currentIndex = event.hadithId;
        emit(HadithLoadedState(
            currentHadith: hadith,
            currentHadithIndex: _currentIndex
        ));
      }else{
        emit(const HadithErrorState("الحديث المطلوب غير موجود."));
      }
    });

    on<NextHadithEvent>((event,emit){
      if(state is HadithLoadedState){
        if(_currentIndex < ahadithList.length -1){
          _currentIndex ++;
          emit(HadithLoadedState(
              currentHadith: ahadithList[_currentIndex],
              currentHadithIndex: _currentIndex,
          ));
        }
      }

    });

    on<PreviousHadithEvent>((event,emit){
      if(state is HadithLoadedState){
        if(_currentIndex > 0){
          _currentIndex --;
          emit(HadithLoadedState(
              currentHadith: ahadithList[_currentIndex],
              currentHadithIndex: _currentIndex,
          )

          );
        }
      }
    });

  }

}