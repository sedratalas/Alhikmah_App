import 'package:hive/hive.dart';
import 'dart:convert';

part 'standard_hadith_model.g.dart';

@HiveType(typeId: 1)
class Hadith {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? sanad;
  @HiveField(3)
  final String? matn;
  @HiveField(4)
  final String? content;
  @HiveField(5)
  final String? raawi;
  @HiveField(6)
  final int? bookId;
  @HiveField(7)
  final DateTime? createdAt;
  @HiveField(8)
  final dynamic updatedAt;

  Hadith({
    required this.id,
    required this.title,
    this.sanad,
    this.matn,
    this.content,
    this.raawi,
    this.bookId,
    this.createdAt,
    this.updatedAt,
  });

  factory Hadith.fromRawJson(String str) => Hadith.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
    id: json["id"],
    title: json["title"],
    sanad: json["sanad"],
    matn: json["matn"],
    content: json["content"],
    raawi: json["raawi"],
    bookId: json["book_id"],
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "sanad": sanad,
    "matn": matn,
    "content": content,
    "raawi": raawi,
    "book_id": bookId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt,
  };
}