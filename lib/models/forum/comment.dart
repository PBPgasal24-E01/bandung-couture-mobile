// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

List<Comment> commentFromJson(String str) => List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
    String pk;
    Fields fields;

    Comment({
        required this.pk,
        required this.fields,
    });

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int id;
    String title;
    String details;
    String time;
    String username;
    bool isAuthor;

    Fields({
        required this.id,
        required this.title,
        required this.details,
        required this.time,
        required this.username,
        required this.isAuthor,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        id: json["id"],
        title: json["title"],
        details: json["details"],
        time: json["time"],
        username: json["username"],
        isAuthor: json["is_author"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "details": details,
        "time": time,
        "username": username,
        "is_author": isAuthor,
    };
}
