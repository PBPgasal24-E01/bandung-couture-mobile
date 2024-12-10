import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:bandung_couture_mobile/screens/stores/contributor_stores_page.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    var isContributor = request.jsonData['role'] == 2;

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
              "Stores",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Space between title and button

            if (true)
              Column(children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.black, // Button color
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      "My Stores Contribution",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContributorStoresPage()),
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
                padding: const EdgeInsets.all(16),
                child: const StoresSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoresSection extends StatefulWidget {
  const StoresSection({super.key});

  @override
  State<StoresSection> createState() => _StoresSectionState();
}

class _StoresSectionState extends State<StoresSection> {
  Future<List<Store>> fetchStores(CookieRequest request) async {
    final response = await request.get('${URL.urlLink}stores/show-rest-all');

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
