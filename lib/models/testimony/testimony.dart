// To parse this JSON data, do
//
//     final testimony = testimonyFromJson(jsonString);

import 'dart:convert';

List<Testimony> testimonyFromJson(String str) =>
    List<Testimony>.from(json.decode(str).map((x) => Testimony.fromJson(x)));

String testimonyToJson(List<Testimony> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Testimony {
  int pk;
  String user;
  String testimony;
  String rating;

  Testimony({
    required this.pk,
    required this.user,
    required this.testimony,
    required this.rating,
  });

  factory Testimony.fromJson(Map<String, dynamic> json) => Testimony(
        pk: json["pk"],
        user: json["user"],
        testimony: json["testimony"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "pk": pk,
        "user": user,
        "testimony": testimony,
        "rating": rating,
      };
}

NumberOfTestimony numberOfTestimonyFromJson(String str) =>
    NumberOfTestimony.fromJson(json.decode(str));

String numberOfTestimonyToJson(NumberOfTestimony data) =>
    json.encode(data.toJson());

class NumberOfTestimony {
  int rating;
  int count;

  NumberOfTestimony({
    required this.rating,
    required this.count,
  });

  factory NumberOfTestimony.fromJson(Map<String, dynamic> json) =>
      NumberOfTestimony(
        rating: json["rating"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "rating": rating,
        "count": count,
      };
}
