import 'package:meta/meta.dart';
import 'dart:convert';

import 'remote_hadith.dart';


class RemotBook {
  final String title;
  final String description;
  final String author;
  final int id;
  final DateTime createdAt;
  final dynamic updatedAt;
  final List<RemotHadith> hadiths;

  RemotBook({
    required this.title,
    required this.description,
    required this.author,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.hadiths,
  });

  RemotBook copyWith({
    String? title,
    String? description,
    String? author,
    int? id,
    DateTime? createdAt,
    dynamic updatedAt,
    List<RemotHadith>? hadiths,
  }) =>
      RemotBook(
        title: title ?? this.title,
        description: description ?? this.description,
        author: author ?? this.author,
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        hadiths: hadiths ?? this.hadiths,
      );

  factory RemotBook.fromRawJson(String str) => RemotBook.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RemotBook.fromJson(Map<String, dynamic> json) => RemotBook(
    title: json["title"],
    description: json["description"],
    author: json["author"],
    id: json["id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
    hadiths: List<RemotHadith>.from(json["hadiths"].map((x) => RemotHadith.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "author": author,
    "id": id,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt,
    "hadiths": List<dynamic>.from(hadiths.map((x) => x.toJson())),
  };
}