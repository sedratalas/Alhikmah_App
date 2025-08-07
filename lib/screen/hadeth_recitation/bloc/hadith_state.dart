import 'package:alhekmah_app/model/hadith_model.dart';
import 'package:equatable/equatable.dart';

abstract class HadithState extends Equatable {
  const HadithState();

  @override
  List<Object> get props => [];
}

class HadithInitialState extends HadithState{
  final int currentHadithIndex;
  const HadithInitialState(this.currentHadithIndex);

  @override
  List<Object> get props => [currentHadithIndex];
}

class HadithLoadingState extends HadithState {}

class HadithLoadedState extends HadithState {
  final Hadith currentHadith;
  final int currentHadithIndex;

  const HadithLoadedState({
    required this.currentHadith,
    required this.currentHadithIndex,
  });

  @override
  List<Object> get props => [currentHadith, currentHadithIndex];

}

class HadithErrorState extends HadithState {
  final String message;
  const HadithErrorState(this.message);

  @override
  List<Object> get props => [message];
}

