import 'dart:convert';
import 'package:bandung_couture_mobile/models/stores/store.dart';

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
        model: modelValues.map[
            json["model"]]!, // Will throw error if model is not in modelValues
        pk: json["pk"], // This should be an integer
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
  Store store;
  DateTime addedAt;

  WishlistFields({
    required this.user,
    required this.store,
    required this.addedAt,
  });

  factory WishlistFields.fromJson(Map<String, dynamic> json) => WishlistFields(
        user: json["user"],
        store: Store.fromJson(json["store"]), // Handle null store
        addedAt: DateTime.parse(json["added_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "store": store.toJson(), // Menggunakan store.toJson untuk serialisasi
        "added_at": addedAt.toIso8601String(),
      };
}

enum Model { WISHLIST_WISHLIST }

final modelValues = EnumValues({"wishlist.wishlist": Model.WISHLIST_WISHLIST});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
