import 'package:equatable/equatable.dart';

abstract class HadithEvent extends Equatable {
  const HadithEvent();

  @override
  List<Object> get props => [];
}

class FetchHadithByIdEvent extends HadithEvent {
  final int hadithIndex;
  const FetchHadithByIdEvent(this.hadithIndex);

  @override
  List<Object> get props => [hadithIndex];
}

class NextHadithEvent extends HadithEvent {
  const NextHadithEvent();
}

class PreviousHadithEvent extends HadithEvent {
  const PreviousHadithEvent();
}