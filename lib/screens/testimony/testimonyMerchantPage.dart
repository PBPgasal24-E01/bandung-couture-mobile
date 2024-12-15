import 'dart:async';

import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/models/testimony/testimony.dart';
import 'package:bandung_couture_mobile/widgets/ratingIcon.dart';
import 'package:bandung_couture_mobile/widgets/wishlistBtn.dart';
import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TestimonyMerchantPage extends StatelessWidget {
  final int storeId;
  final String storeName;

  const TestimonyMerchantPage({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ulasan Toko $storeName"),
          backgroundColor: Colors.white, // AppBar color
          elevation: 4, // Shadow for AppBar
        ),
        drawer: const LeftDrawer(),
        body: Padding(
            padding: const EdgeInsets.all(16.0), // Padding for the whole page
            child: TestimonySection(
              storeId: storeId,
            )));
  }
}

class TestimonySection extends StatefulWidget {
  final int storeId;

  const TestimonySection({
    super.key,
    required this.storeId,
  });

  @override
  State<TestimonySection> createState() => _TestimonySection();
}

class _TestimonySection extends State<TestimonySection> {
  Future<List<Testimony>> fetchTestimony(CookieRequest request) async {
    final user_testimony = await request
        .get('${URL.urlLink}testimony/merchant_json/${widget.storeId}');

    List<Testimony> listTestimony = [];
    for (var d in user_testimony) {
      if (d != null) {
        listTestimony.add(Testimony.fromJson(d));
      }
    }
    return listTestimony;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder(
      future: fetchTestimony(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData) {
            return const Column(
              children: [
                Text(
                  'Belum ada ulasan pada toko ini',
                  style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                ),
                SizedBox(height: 8),
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
                          Row(
                            children: [
                              Text(
                                "${snapshot.data![index].user}",
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "${snapshot.data![index].rating}/5",
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${snapshot.data![index].testimony}",
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 8),
                        ]),
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
