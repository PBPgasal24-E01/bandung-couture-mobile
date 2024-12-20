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
        final response = await request.get(
            '${URL.urlLink}testimony/get_number_of_rating/${currentStore.pk}/');

        if (context.mounted) {
          NumberOfTestimony rating = NumberOfTestimony.fromJson(response);
          if (rating.rating.round() == widget.rating || widget.rating == 6) {
            storesList.add(currentStore);
          }
        }
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
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            "${snapshot.data![index].fields.brand}",
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          RatingIcon(
                            storeId: snapshot.data![index].pk,
                            storeName: snapshot.data![index].fields.brand,
                            description:
                                snapshot.data![index].fields.description,
                            request: request,
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          "${snapshot.data![index].fields.description}",
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
                                "${snapshot.data![index].fields.address}",
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
                            const Icon(Icons.phone,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${snapshot.data![index].fields.contactNumber}",
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
                                "${snapshot.data![index].fields.website}",
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
                            const Icon(Icons.share,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${snapshot.data![index].fields.socialMedia}",
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
              },
            );
          }
        }
      },
    );
  }
}
