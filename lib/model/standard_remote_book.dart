import 'package:hive/hive.dart';
import 'dart:convert';

import 'standard_hadith_model.dart';

part 'standard_remote_book.g.dart';

@HiveType(typeId: 2)
class RemotBook {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final String author;
  @HiveField(3)
  final int id;
  @HiveField(4)
  final DateTime? createdAt;
  @HiveField(5)
  final dynamic updatedAt;
  @HiveField(6)
  final List<Hadith> hadiths; // هنا التعديل المهم!

  RemotBook({
    required this.title,
    required this.description,
    required this.author,
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.hadiths,
  });

  factory RemotBook.fromRawJson(String str) => RemotBook.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RemotBook.fromJson(Map<String, dynamic> json) => RemotBook(
    title: json["title"],
    description: json["description"],
    author: json["author"],
    id: json["id"],
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    updatedAt: json["updated_at"],
    hadiths: json["hadiths"] != null
        ? List<Hadith>.from(json["hadiths"].map((x) => Hadith.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "author": author,
    "id": id,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt,
    "hadiths": List<dynamic>.from(hadiths.map((x) => x.toJson())),
  };
}