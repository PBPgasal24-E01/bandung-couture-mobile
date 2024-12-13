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
  String brand;
  String description;
  String address;
  String contactNumber;
  String website;
  String socialMedia;
  List<int> categories;
  DateTime addedAt;

  WishlistFields({
    required this.brand,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.website,
    required this.socialMedia,
    required this.categories,
    required this.addedAt,
  });

  factory WishlistFields.fromJson(Map<String, dynamic> json) => WishlistFields(
        brand: json["brand"],
        description: json["description"],
        address: json["address"],
        contactNumber: json["contact_number"],
        website: json["website"],
        socialMedia: json["social_media"],
        categories: List<int>.from(json["categories"].map((x) => x)),
        addedAt: DateTime.parse(json["addedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "brand": brand,
        "description": description,
        "address": address,
        "contact_number": contactNumber,
        "website": website,
        "social_media": socialMedia,
        "categories": List<dynamic>.from(categories
            .map((x) => x)), // Menggunakan store.toJson untuk serialisasi
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
