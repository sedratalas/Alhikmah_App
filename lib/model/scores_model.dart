import 'package:meta/meta.dart';
import 'dart:convert';

class ScoresModel {
  final int bookId;
  final String bookTitle;
  final int hadithId;
  final String hadithTitle;
  final int score;
  final DateTime createdAt;

  ScoresModel({
    required this.bookId,
    required this.bookTitle,
    required this.hadithId,
    required this.hadithTitle,
    required this.score,
    required this.createdAt,
  });

  ScoresModel copyWith({
    int? bookId,
    String? bookTitle,
    int? hadithId,
    String? hadithTitle,
    int? score,
    DateTime? createdAt,
  }) =>
      ScoresModel(
        bookId: bookId ?? this.bookId,
        bookTitle: bookTitle ?? this.bookTitle,
        hadithId: hadithId ?? this.hadithId,
        hadithTitle: hadithTitle ?? this.hadithTitle,
        score: score ?? this.score,
        createdAt: createdAt ?? this.createdAt,
      );

  factory ScoresModel.fromRawJson(String str) => ScoresModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ScoresModel.fromJson(Map<String, dynamic> json) => ScoresModel(
    bookId: json["book_id"],
    bookTitle: json["book_title"],
    hadithId: json["hadith_id"],
    hadithTitle: json["hadith_title"],
    score: json["score"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "book_id": bookId,
    "book_title": bookTitle,
    "hadith_id": hadithId,
    "hadith_title": hadithTitle,
    "score": score,
    "created_at": createdAt.toIso8601String(),
  };
}
