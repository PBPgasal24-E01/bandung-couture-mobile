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

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    try {
      print(
          "Parsing Wishlist: $json"); // Debug print to show the full JSON object being parsed

      if (json["model"] == null) {
        print("Error: Missing model in Wishlist JSON");
      }
      if (json["pk"] == null) {
        print("Error: Missing pk in Wishlist JSON");
      }
      if (json["fields"] == null) {
        print("Error: Missing fields in Wishlist JSON");
      }

      print(json["model"]);
      print(json["pk"]);
      print(json["fields"]);

      return Wishlist(
        model: modelValues.map[
            json["model"]]!, // Will throw error if model is not in modelValues
        pk: int.parse((json["pk"])), // This should be an integer
        fields: WishlistFields.fromJson(json["fields"]),
      );
    } catch (e) {
      print("Error in Wishlist.fromJson: $e");
      rethrow; // Re-throws the error after logging it
    }
  }

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

  factory WishlistFields.fromJson(Map<String, dynamic> json) {
    try {
      return WishlistFields(
        user: json["user"],
        store: Store.fromJson(json["store"]), // Handle null store
        addedAt: DateTime.parse(json["added_at"]),
      );
    } catch (e) {
      print("Error in WishlistFields.fromJson: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        "user": user,
        "store": store.toJson(), // Menggunakan store.toJson untuk serialisasi
        "added_at": addedAt.toIso8601String(),
      };
}

enum Model { WISHLISTS_WISHLIST }

final modelValues =
    EnumValues({"Wishlists.wishlist": Model.WISHLISTS_WISHLIST});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
