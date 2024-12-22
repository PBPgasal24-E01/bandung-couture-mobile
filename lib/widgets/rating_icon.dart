import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/models/testimony/testimony.dart';
import 'package:bandung_couture_mobile/screens/testimony/testimony_merchant_page.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class RatingIcon extends StatefulWidget {
  final int storeId;
  final String storeName;
  final String description;
  final CookieRequest request;

  const RatingIcon({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.request,
    required this.description,
  });

  @override
  State<RatingIcon> createState() => _RatingIconState();
}

class _RatingIconState extends State<RatingIcon> {
  Future<NumberOfTestimony> fetchNumberOfRating() async {
    final response = await widget.request
        .get('${URL.urlLink}testimony/get_number_of_rating/${widget.storeId}/');

    NumberOfTestimony rating = NumberOfTestimony.fromJson(response);
    return rating;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NumberOfTestimony>(
      future: fetchNumberOfRating(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestimonyMerchantPage(
                    storeId: widget.storeId,
                    storeName: widget.storeName,
                    description: widget.description,
                  ),
                ),
              );
            },
            child: Row(children: [
              Row(
                children: List.generate(5, (index) {
                  // Change 5 to a smaller number
                  return Center(
                    child: Icon(
                      index < snapshot.data!.rating.round()
                          ? Icons.star
                          : Icons.star_border_outlined,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 2),
              Text(
                "(${snapshot.data!.count})",
                style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey),
              ),
            ]),
          );
        } else {
          return const Text("0");
        }
      },
    );
  }
}
