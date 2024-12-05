// To parse this JSON data, do
//
//     final store = storeFromJson(jsonString);

import 'dart:convert';

List<Store> storeFromJson(String str) =>
    List<Store>.from(json.decode(str).map((x) => Store.fromJson(x)));

String storeToJson(List<Store> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Store {
  Model model;
  int pk;
  Fields fields;

  Store({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  int? user;
  String brand;
  String description;
  String address;
  String contactNumber;
  String website;
  String socialMedia;
  List<int> categories;

  Fields({
    required this.user,
    required this.brand,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.website,
    required this.socialMedia,
    required this.categories,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        brand: json["brand"],
        description: json["description"],
        address: json["address"],
        contactNumber: json["contact_number"],
        website: json["website"],
        socialMedia: json["social_media"],
        categories: List<int>.from(json["categories"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "brand": brand,
        "description": description,
        "address": address,
        "contact_number": contactNumber,
        "website": website,
        "social_media": socialMedia,
        "categories": List<dynamic>.from(categories.map((x) => x)),
      };
}

enum Model { STORES_STORE }

final modelValues = EnumValues({"stores.store": Model.STORES_STORE});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
