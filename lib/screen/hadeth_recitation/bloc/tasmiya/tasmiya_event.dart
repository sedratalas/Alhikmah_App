part of 'tasmiya_bloc.dart';

abstract class TasmiyaEvent extends Equatable {
  const TasmiyaEvent();

  @override
  List<Object> get props => [];
}

class StartRecordingEvent extends TasmiyaEvent {
  const StartRecordingEvent();
}

class StopRecordingEvent extends TasmiyaEvent {
  const StopRecordingEvent();
}

// حدث جديد لتحديث الوقت في حالة التسجيل
class UpdateRecordingTimeEvent extends TasmiyaEvent {
  const UpdateRecordingTimeEvent();
}