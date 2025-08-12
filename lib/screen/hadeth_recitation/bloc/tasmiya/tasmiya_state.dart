part of 'tasmiya_bloc.dart';

abstract class TasmiyaState extends Equatable {
  const TasmiyaState();

  @override
  List<Object> get props => [];
}

class TasmiyaInitial extends TasmiyaState {}

class TasmiyaRecording extends TasmiyaState {
  final String currentTranscription;
  // إضافة متغير لتتبع الوقت المنقضي
  final int elapsedTimeInSeconds;

  const TasmiyaRecording({
    this.currentTranscription = '',
    this.elapsedTimeInSeconds = 0,
  });

  @override
  List<Object> get props => [currentTranscription, elapsedTimeInSeconds];
}

class TasmiyaProcessing extends TasmiyaState {}

class TasmiyaCompleted extends TasmiyaState {
  final List<Map<String, dynamic>> highlightedText;
  final double score;

  const TasmiyaCompleted({required this.highlightedText, required this.score});

  @override
  List<Object> get props => [highlightedText, score];
}

class TasmiyaError extends TasmiyaState {
  final String message;

  const TasmiyaError(this.message);

  @override
  List<Object> get props => [message];
}