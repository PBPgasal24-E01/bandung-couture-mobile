// To parse this JSON data, do
//
//     final forum = forumFromJson(jsonString);

import 'dart:convert';

List<Forum> forumFromJson(String str) => List<Forum>.from(json.decode(str).map((x) => Forum.fromJson(x)));

String forumToJson(List<Forum> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Forum {
    String pk;
    Fields fields;

    Forum({
        required this.pk,
        required this.fields,
    });

    factory Forum.fromJson(Map<String, dynamic> json) => Forum(
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
    String parent;
    bool isAuthor;

    Fields({
        required this.id,
        required this.title,
        required this.details,
        required this.time,
        required this.username,
        required this.parent,
        required this.isAuthor,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        id: json["id"],
        title: json["title"],
        details: json["details"],
        time: json["time"],
        username: json["username"],
        parent: json["parent"],
        isAuthor: json["is_author"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "details": details,
        "time": time,
        "username": username,
        "parent": parent,
        "is_author": isAuthor,
    };
}
