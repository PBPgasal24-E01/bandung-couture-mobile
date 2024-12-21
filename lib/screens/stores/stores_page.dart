import 'package:bandung_couture_mobile/widgets/rating_icon.dart';
import 'package:bandung_couture_mobile/widgets/wishlistBtn.dart';
import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:bandung_couture_mobile/screens/stores/contributor_stores_page.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bandung_couture_mobile/widgets/stores/multi_select.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() {
    return _StorePageState();
  }
}

class _StorePageState extends State<StoresPage> {
  List<int> _categories = [];

  void _showMultiSelect() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final response =
        await request.get('${URL.urlLink}stores/get-categories-mapping?');

    if (!context.mounted) return;

    final nameToPk = (response['data'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));
    final pkToName = (response['inverted_data'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(int.parse(key), value as String));

    List<String> names = nameToPk.keys.toList();
    List<String> initial = [];

    for (int categoryPk in _categories) {
      String? categoryName = pkToName[categoryPk];
      if (categoryName != null) {
        initial.add(categoryName);
      }
    }

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(
          title: "Filter Categories",
          items: names,
          initialItems: initial,
        );
      },
    );

    if (results != null) {
      List<int> categories = [];
      for (var name in results) {
        int? pk = nameToPk[name];
        if (pk != null) categories.add(pk);
      }
      setState(() {
        _categories = categories;
      });
    }
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Text
                  const Text(
                    "Stores",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  // Filter Button
                  ElevatedButton.icon(
                    onPressed: _showMultiSelect,
                    icon: const Icon(Icons.filter_alt, size: 20),
                    label: const Text(
                      "Filter Categories",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4, // Shadow effect
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // Space between title and button

            if (isContributor)
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
                child: StoresSection(categories: _categories),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoresSection extends StatefulWidget {
  final List<int> categories;

  const StoresSection({super.key, required this.categories});

  @override
  State<StoresSection> createState() => _StoresSectionState();
}

class _StoresSectionState extends State<StoresSection> {
  Future<List<Store>> fetchStores(CookieRequest request) async {
    final response = await request.get(
        '${URL.urlLink}stores/show-rest-all?categories-filter=${widget.categories.join(',')}');
    var data = response;
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
    var isVisitor = request.jsonData['role'] == 1;
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
                        if (isVisitor)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: WishlistButton(
                              storeId: snapshot.data![index].pk,
                              request: request,
                            ),
                          ),
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
