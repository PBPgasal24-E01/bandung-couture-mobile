class Promo {
  final String id;
  final String title;
  final String description;
  final String discountPercentage;
  final String promoCode;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;

  Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.promoCode,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      discountPercentage: json['discount_percentage'],
      promoCode: json['promo_code'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdBy: json['created_by'],
    );
  }
}

class PromosModel {
  final List<Promo> promos;

  PromosModel({required this.promos});

  factory PromosModel.fromJson(Map<String, dynamic> json) {
    var promosList = json['promos'] as List;
    List<Promo> promoObjects = promosList.map((promoJson) => Promo.fromJson(promoJson)).toList();
    return PromosModel(promos: promoObjects);
  }
}