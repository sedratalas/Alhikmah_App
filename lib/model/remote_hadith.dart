import 'package:meta/meta.dart';
import 'dart:convert';

class RemotHadith {
  final String title;
  final String content;
  final String raawi;
  final int id;
  final int bookId;
  final DateTime createdAt;
  final dynamic updatedAt;

  RemotHadith({
    required this.title,
    required this.content,
    required this.raawi,
    required this.id,
    required this.bookId,
    required this.createdAt,
    required this.updatedAt,
  });

  RemotHadith copyWith({
    String? title,
    String? content,
    String? raawi,
    int? id,
    int? bookId,
    DateTime? createdAt,
    dynamic updatedAt,
  }) =>
      RemotHadith(
        title: title ?? this.title,
        content: content ?? this.content,
        raawi: raawi ?? this.raawi,
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory RemotHadith.fromRawJson(String str) => RemotHadith.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RemotHadith.fromJson(Map<String, dynamic> json) => RemotHadith(
    title: json["title"],
    content: json["content"],
    raawi: json["raawi"],
    id: json["id"],
    bookId: json["book_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
    "raawi": raawi,
    "id": id,
    "book_id": bookId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt,
  };
}
