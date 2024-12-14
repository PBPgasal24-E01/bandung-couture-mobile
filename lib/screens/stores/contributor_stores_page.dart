import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:bandung_couture_mobile/screens/stores/store_form.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ContributorStoresPage extends StatelessWidget {
  const ContributorStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stores"),
        backgroundColor: Colors.white, // AppBar color
        elevation: 4, // Shadow for AppBar
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding for the whole page
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Section
            const Text(
              "Manage Your Stores",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Space between title and button

            Column(children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.black, // Button color,
                ),
                child: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      "Add a Store",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StoreFormPage()),
                  );
                },
              ),

              const SizedBox(height: 30), // Space between button and section
            ]),

            // Store Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Light background for the section
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16), // Padding inside the section
                child: const ContributorStoresSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContributorStoresSection extends StatefulWidget {
  const ContributorStoresSection({super.key});

  @override
  State<ContributorStoresSection> createState() =>
      _ContributorStoresSectionState();
}

class _ContributorStoresSectionState extends State<ContributorStoresSection> {
  Future<List<Store>> fetchStores(CookieRequest request) async {
    final response = await request.get('${URL.urlLink}stores/show-rest-own');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object MoodEntry
    List<Store> storesList = [];
    for (var d in data) {
      if (d != null) {
        storesList.add(Store.fromJson(d));
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
          if (!snapshot.hasData) {
            return const Column(
              children: [
                Text(
                  'Belum ada toko dalam sistem',
                  style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                ),
                SizedBox(height: 8),
              ],
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => Card(
                elevation: 4, // Elevation for the shadow effect
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Inner padding for the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${snapshot.data![index].fields.brand}",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                              overflow:
                                  TextOverflow.ellipsis, // Handles long text
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
                          const Icon(Icons.share, size: 14, color: Colors.grey),
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
                      Row(
                        children: [
                          ElevatedButton(
                              child: const Text('Edit'),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StoreFormPage(
                                          instance: snapshot.data![index])),
                                );
                              }),
                          ElevatedButton(
                              child: const Text('Delete'),
                              onPressed: () async {
                                var response = await request.postJson(
                                    '${URL.urlLink}stores/delete-mobile',
                                    jsonEncode(<String, String>{
                                      'pk': snapshot.data![index].pk.toString(),
                                    }));

                                if (context.mounted) {
                                  setState(() =>
                                      {}); //only to rebuild the stores section
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(response['description']),
                                  ));
                                }
                              }),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
