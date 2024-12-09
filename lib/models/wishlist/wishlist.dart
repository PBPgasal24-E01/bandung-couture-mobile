// To parse this JSON data, do
//
//     final wishlist = wishlistFromJson(jsonString);

import 'dart:convert';

List<Wishlist> wishlistFromJson(String str) =>
    List<Wishlist>.from(json.decode(str).map((x) => Wishlist.fromJson(x)));

String wishlistToJson(List<Wishlist> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Wishlist {
  Model model;
  int pk;
  WishlistFields fields;

  Wishlist({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: WishlistFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class WishlistFields {
  int user;
  int store;
  DateTime addedAt;

  WishlistFields({
    required this.user,
    required this.store,
    required this.addedAt,
  });

  factory WishlistFields.fromJson(Map<String, dynamic> json) => WishlistFields(
        user: json["user"],
        store: json["store"],
        addedAt: DateTime.parse(json["added_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "store": store,
        "added_at": addedAt.toIso8601String(),
      };
}

enum Model { WISHLISTS_WISHLIST }

final modelValues =
    EnumValues({"wishlists.wishlist": Model.WISHLISTS_WISHLIST});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
