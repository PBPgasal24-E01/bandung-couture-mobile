// To parse this JSON data, do
//
//     final forum = forumFromJson(jsonString);

import 'dart:convert';

List<Forum> forumFromJson(String str) => List<Forum>.from(json.decode(str).map((x) => Forum.fromJson(x)));

String forumToJson(List<Forum> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Forum {
    String model;
    String pk;
    Fields fields;

    Forum({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Forum.fromJson(Map<String, dynamic> json) => Forum(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    dynamic parent;
    String title;
    String details;
    DateTime time;

    Fields({
        required this.user,
        required this.parent,
        required this.title,
        required this.details,
        required this.time,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        parent: json["parent"],
        title: json["title"],
        details: json["details"],
        time: DateTime.parse(json["time"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "parent": parent,
        "title": title,
        "details": details,
        "time": time.toIso8601String(),
    };
}
