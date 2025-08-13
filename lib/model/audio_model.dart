class AudioModel {
  final String hadith_id;
  final int id;
  final int user_id;
  final String file_path;
  final String transcription;

//<editor-fold desc="Data Methods">
  const AudioModel({
    required this.hadith_id,
    required this.id,
    required this.user_id,
    required this.file_path,
    required this.transcription,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is AudioModel &&
              runtimeType == other.runtimeType &&
              hadith_id == other.hadith_id &&
              id == other.id &&
              user_id == other.user_id &&
              file_path == other.file_path &&
              transcription == other.transcription);

  @override
  int get hashCode =>
      hadith_id.hashCode ^
      id.hashCode ^
      user_id.hashCode ^
      file_path.hashCode ^
      transcription.hashCode;

  @override
  String toString() {
    return 'AudioModel{' +
        ' hadith_id: $hadith_id,' +
        ' id: $id,' +
        ' user_id: $user_id,' +
        ' file_path: $file_path,' +
        ' transcription: $transcription,' +
        '}';
  }

  AudioModel copyWith({
    String? hadith_id,
    int? id,
    int? user_id,
    String? file_path,
    String? transcription,
  }) {
    return AudioModel(
      hadith_id: hadith_id ?? this.hadith_id,
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      file_path: file_path ?? this.file_path,
      transcription: transcription ?? this.transcription,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hadith_id': this.hadith_id,
      'id': this.id,
      'user_id': this.user_id,
      'file_path': this.file_path,
      'transcription': this.transcription,
    };
  }

  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      hadith_id: map['hadith_id'] as String,
      id: map['id'] as int,
      user_id: map['user_id'] as int,
      file_path: map['file_path'] as String,
      transcription: map['transcription'] as String,
    );
  }

//</editor-fold>
}