import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/models/Wishlist/wishlist.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
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
              "Wishlist Stores",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Space between title and button
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
                child:
                    const WishlistSection(), // Replace with your content widget
              ),
            ),
            const SizedBox(
                height:
                    30), // Add space between WishlistSection and "Recommended Stores"
            const Text(
              "Recommended Stores",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Space between title and button
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
                child:
                    const ReccomendedSection(), // Replace with your content widget
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WishlistSection extends StatefulWidget {
  const WishlistSection({super.key});

  @override
  State<WishlistSection> createState() => _WishlistSectionState();
}

class _WishlistSectionState extends State<WishlistSection> {
  Future<List<Wishlist>> getWishlist(CookieRequest request) async {
    final response = await request.get('${URL.urlLink}wishlist/view_Mob/');
    List<dynamic> data = response; // Pastikan tipe data di sini
    List<Wishlist> wishList = [];

    try {
      for (var d in data) {
        if (d != null) {
          final storeId = d["fields"]["store"];
          final secondResponse =
              await request.get('${URL.urlLink}stores/get-store/$storeId');
          d["fields"]["store"] = secondResponse[0];
          wishList.add(Wishlist.fromJson(d));
        }
      }
      return wishList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder(
      future: getWishlist(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData) {
            return const Column(
              children: [
                Text(
                  'Belum ada toko di dalam wishlist',
                  style: TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
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

class ReccomendedSection extends StatefulWidget {
  const ReccomendedSection({super.key});

  @override
  State<ReccomendedSection> createState() => _ReccomendedSectionState();
}

class _ReccomendedSectionState extends State<ReccomendedSection> {
  Future<List<Store>> getAvailableStores(CookieRequest request) async {
    final response =
        await request.get('${URL.urlLink}wishlist/recommended_Mob/');
    var data = response;
    List<Store> stores = [];
    for (var d in data) {
      if (d != null) {
        stores.add(Store.fromJson(d));
      }
    }
    return stores;
  }

  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder(
      future: getAvailableStores(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData) {
            return const Column(
              children: [
                Text(
                  'Tidak ada rekomendasi toko dalam sistem',
                  style: TextStyle(
                      fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
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
