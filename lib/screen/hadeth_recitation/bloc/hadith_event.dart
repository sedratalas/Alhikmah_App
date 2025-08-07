import 'package:equatable/equatable.dart';

abstract class HadithEvent extends Equatable {
const HadithEvent();

@override
List<Object> get props => [];
}
class FetchHadithByIdEvent extends HadithEvent {
  final int hadithId;
  const FetchHadithByIdEvent(this.hadithId);

  @override
  List<Object> get props => [hadithId];
}

class NextHadithEvent extends HadithEvent{
  const NextHadithEvent();
}

class PreviousHadithEvent extends HadithEvent{
  const PreviousHadithEvent();
}

