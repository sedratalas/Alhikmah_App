import 'package:alhekmah_app/model/standard_hadith_model.dart';
import 'package:equatable/equatable.dart';

abstract class HadithState extends Equatable {
  const HadithState();

  @override
  List<Object> get props => [];
}

class HadithInitialState extends HadithState {}

class HadithLoadingState extends HadithState {}

class HadithLoadedState extends HadithState {
  final Hadith currentHadith;
  final int currentHadithIndex;
  final int totalHadiths;

  const HadithLoadedState({
    required this.currentHadith,
    required this.currentHadithIndex,
    required this.totalHadiths,
  });

  @override
  List<Object> get props => [currentHadith, currentHadithIndex, totalHadiths];
}

class HadithErrorState extends HadithState {
  final String message;
  const HadithErrorState(this.message);

  @override
  List<Object> get props => [message];
}