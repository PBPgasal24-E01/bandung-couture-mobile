import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/models/Wishlist/wishlist.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bandung_couture_mobile/widgets/stores/multi_select.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Wishlist> wishlistItems = []; // Wishlist data shared with child widgets
  List<Store> storeItems = [];
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
        _refreshWishlist(request);
      });
    }
  }

  // Function to refresh wishlist data
  Future<void> _refreshWishlist(CookieRequest request) async {
    // Fetch updated wishlist items
    final updatedWishlist = await fetchWishlistItems(request);
    final updatedStore = await getAvailableStores(request);
    setState(() {
      wishlistItems = updatedWishlist;
      if (storeItems.length < 2) {
        storeItems = updatedStore;
      }
    });
  }

  Future<void> _refreshRecommended(CookieRequest request) async {
    // Fetch updated wishlist items
    final updatedWishlist = await fetchWishlistItems(request);
    final updatedStore = await getAvailableStores(request);
    setState(() {
      wishlistItems = updatedWishlist;
      storeItems = updatedStore;
    });
  }

  @override
  void initState() {
    super.initState();
    // Use context to access CookieRequest after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _refreshWishlist(request);
      _refreshRecommended(request); // Load initial data
    });
  }

  Future<List<Wishlist>> fetchWishlistItems(CookieRequest request) async {
    final response = await request.get(
        '${URL.urlLink}wishlist/view_Mob/?categories-filter=${_categories.join(',')}');
    List<dynamic> data = response; // Pastikan tipe data di sini
    List<Wishlist> wishList = [];

    for (var d in data) {
      if (d != null) {
        final storeId = d["fields"]["store"];
        final secondResponse =
            await request.get('${URL.urlLink}stores/get-store/$storeId');

        // Modify the structure of the data
        secondResponse[0]["fields"]["addedAt"] = d["fields"]["added_at"];
        secondResponse[0]["model"] = d["model"];
        secondResponse[0]["pk"] = d["pk"];
        secondResponse[0]["fields"]["storeID"] = d["fields"]["store"];
        secondResponse[0]["fields"].remove("user");

        // Add to wishlist
        wishList.add(Wishlist.fromJson(secondResponse[0]));
      }
    }
    return wishList;
  }

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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    var isContributor = request.jsonData['role'] == 2;
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
            Align(
              alignment: Alignment.center, // Aligns the button to the center
              child: ElevatedButton.icon(
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4, // Shadow effect
                ),
              ),
            ),
            const SizedBox(height: 25),
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
                child: !isContributor
                    ? WishlistSection(
                        wishlistItems: wishlistItems,
                        onUpdate: () => _refreshWishlist(request),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center content vertically
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center content horizontally
                        children: [
                          Text(
                            'Wishlist tidak berlaku untuk contributor',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
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
              child: !isContributor
                  ? ReccomendedSection(
                      storeItems: storeItems,
                      onUpdate: () => _refreshRecommended(request),
                    ) // Replace with your content widget
                  : const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center content vertically
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center content horizontally
                      children: [
                        Text(
                          'Wishlist tidak berlaku untuk contributor',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
            ))
          ],
        ),
      ),
    );
  }
}

class WishlistSection extends StatelessWidget {
  final List<dynamic> wishlistItems; // Data from the parent
  final VoidCallback onUpdate; // Callback to refresh parent

  const WishlistSection({
    super.key,
    required this.wishlistItems,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (wishlistItems.isEmpty) {
      // Handle empty wishlist
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum ada toko di dalam wishlist',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    } else {
      // Build the list of wishlist items
      return ListView.builder(
        itemCount: wishlistItems.length,
        itemBuilder: (_, index) => Card(
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
                Text(
                  wishlistItems[index].fields.brand,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  wishlistItems[index].fields.description,
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        wishlistItems[index].fields.address,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
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
                        wishlistItems[index].fields.contactNumber,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
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
                        wishlistItems[index].fields.website,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.blue,
                        ),
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
                        wishlistItems[index].fields.socialMedia,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Jalankan request untuk menghapus item wishlist
                      final response = await context.read<CookieRequest>().get(
                          '${URL.urlLink}wishlist/remove_mob/${wishlistItems[index].pk}/');

                      // Jika sukses, panggil onUpdate untuk refresh data
                      if (response['status'] == 'success') {
                        onUpdate(); // Memanggil fungsi di parent untuk refresh wishlist
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Button color
                    ),
                    child: const Text(
                      "Remove from Wishlist",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class ReccomendedSection extends StatelessWidget {
  final List<dynamic> storeItems; // Data from the parent
  final VoidCallback onUpdate; // Callback to refresh parent

  const ReccomendedSection({
    super.key,
    required this.storeItems,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (storeItems.isEmpty) {
      // Handle empty wishlist
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum ada toko yang direkomendasikan',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    } else {
      // Build the list of wishlist items
      return ListView.builder(
        itemCount: storeItems.length,
        itemBuilder: (_, index) => Card(
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
                Text(
                  storeItems[index].fields.brand,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  storeItems[index].fields.description,
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        storeItems[index].fields.address,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
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
                        storeItems[index].fields.contactNumber,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
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
                        storeItems[index].fields.website,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.blue,
                        ),
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
                        storeItems[index].fields.socialMedia,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Jalankan request untuk menghapus item wishlist
                      final response = await context.read<CookieRequest>().get(
                          '${URL.urlLink}wishlist/add/${storeItems[index].pk}/');

                      // Jika sukses, panggil onUpdate untuk refresh data
                      if (response['message'] == 'added') {
                        onUpdate(); // Memanggil fungsi di parent untuk refresh wishlist
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button color
                    ),
                    child: const Text(
                      "Add to Wishlist",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
