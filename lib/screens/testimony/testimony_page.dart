import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:bandung_couture_mobile/models/testimony/testimony.dart';
import 'package:bandung_couture_mobile/widgets/rating_icon.dart';
import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TestimonyPage extends StatelessWidget {
  const TestimonyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stores Testimony and Rating"),
        backgroundColor: Colors.white, // AppBar color
        elevation: 4, // Shadow for AppBar
      ),
      drawer: const LeftDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16.0), // Padding for the whole page
        child: Column(
          children: [
            Expanded(
              child: TestimonyFilter(),
            )
          ],
        ),
      ),
    );
  }
}

class CardPage extends StatefulWidget {
  final String brand;
  final String description;
  final String address;
  final String contactNumber;
  final String website;
  final String socialMedia;
  final int pk;
  final int currentRating;

  const CardPage({
    super.key,
    required this.pk,
    required this.brand,
    required this.description,
    required this.address,
    required this.contactNumber,
    required this.website,
    required this.socialMedia,
    required this.currentRating,
  });

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    Future<bool> filterRating(CookieRequest request, int pk) async {
      final response = await request
          .get('${URL.urlLink}testimony/get_number_of_rating/$pk/');

      if (context.mounted) {
        NumberOfTestimony rating = NumberOfTestimony.fromJson(response);
        if (rating.rating.round() == widget.currentRating ||
            widget.currentRating == 6) {
          return true;
        }
      }
      return false;
    }

    return FutureBuilder(
        future: filterRating(request, widget.pk),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        widget.brand,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      RatingIcon(
                        storeId: widget.pk,
                        storeName: widget.brand,
                        description: widget.description,
                        request: request,
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.address,
                            style: const TextStyle(
                                fontSize: 12.0, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.contactNumber,
                            style: const TextStyle(
                                fontSize: 12.0, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.web, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.website,
                            style: const TextStyle(
                                fontSize: 12.0, color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.share, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.socialMedia,
                            style: const TextStyle(
                                fontSize: 12.0, color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink(); // This renders nothing.
          }
        });
  }
}

class TestimonyFilter extends StatefulWidget {
  const TestimonyFilter({super.key});

  @override
  State<TestimonyFilter> createState() => _TestimonyFilterState();
}

class _TestimonyFilterState extends State<TestimonyFilter> {
  int _rating = 6;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DropdownButton<String>(
        value: (_rating == 6 ? 'Semuanya' : _rating.toString()),
        items: <String>['0', '1', '2', '3', '4', '5', 'Semuanya']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            if (value == 'Semuanya') {
              _rating = 6;
            } else {
              _rating = int.parse(value!);
            }
          });
        },
      ),
      Expanded(
        child: TestimonySection(rating: _rating),
      )
    ]);
  }
}

class TestimonySection extends StatefulWidget {
  final int rating;

  const TestimonySection({super.key, required this.rating});

  @override
  State<TestimonySection> createState() => _TestimonySectionState();
}

class _TestimonySectionState extends State<TestimonySection> {
  Future<List<Store>> fetchStores(CookieRequest request) async {
    final response = await request.get('${URL.urlLink}stores/show-rest-all');
    var data = response;
    List<Store> storesList = [];
    for (var d in data) {
      if (d != null) {
        var currentStore = Store.fromJson(d);
        storesList.add(currentStore);
      }
    }
    return storesList;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return FutureBuilder(
      future: fetchStores(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.data!.length == 0) {
            return const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belum ada toko dalam sistem',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      return CardPage(
                        pk: snapshot.data![index].pk,
                        brand: snapshot.data![index].fields.brand,
                        description: snapshot.data![index].fields.description,
                        address: snapshot.data![index].fields.address,
                        contactNumber:
                            snapshot.data![index].fields.contactNumber,
                        website: snapshot.data![index].fields.website,
                        socialMedia: snapshot.data![index].fields.socialMedia,
                        currentRating: widget.rating,
                      );
                    },
                  ),
                )
              ],
            );
          }
        }
      },
    );
  }
}
