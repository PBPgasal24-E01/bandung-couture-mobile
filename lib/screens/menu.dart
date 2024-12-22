
import 'package:bandung_couture_mobile/constants/app_images.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/models/promo/promo.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:bandung_couture_mobile/screens/promo/promo_page.dart';
import 'package:bandung_couture_mobile/screens/stores/stores_page.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:math';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Promo> promos = [];
  List<Store> allStores = []; 
  List<Store> stores = [];    
  List<Store> filteredStores = [];
  bool isLoading = true;
  final PageController _promoController = PageController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _promoController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchInitialData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.wait([
        fetchPromos(),
        fetchStoresData(),
      ]);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Store>> fetchStores(CookieRequest request) async {
    final response = await request.get('${URL.urlLink}stores/show-rest-all');
    var data = response;
    List<Store> storesList = [];
    for (var d in data) {
      if (d != null) {
        storesList.add(Store.fromJson(d));
      }
    }
    return storesList;
  }
  
  Future<void> fetchStoresData() async {
    try {
      final request = context.read<CookieRequest>();
      final fetchedStores = await fetchStores(request);
      
      // Simpan semua store ke dalam allStores
      allStores = fetchedStores;
      
      // Ambil 5 store secara random untuk ditampilkan sebagai featured
      setState(() {
        stores = getRandomStores(allStores, 5);
        filteredStores = stores; // Default saat tidak searching
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stores: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> fetchPromos() async {
    setState(() {
      isLoading = true;
    });
    try {
      final request = context.read<CookieRequest>();
      const endpoint = '${URL.urlLink}promo/json/';

      final response = await request.get(endpoint);
      if (response is Map<String, dynamic> && response.containsKey('promos')) {
        PromosModel promosModel = PromosModel.fromJson(response);
        setState(() {
          promos = promosModel.promos;
          promos = getRandomPromos(promos, 5);
          isLoading = false;
        });
      } else {
        throw Exception("Unexpected response structure");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load promos: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  List<Promo> getRandomPromos(List<Promo> promos, int count) {
    final random = Random();
    List<Promo> shuffledPromos = List.from(promos);
    shuffledPromos.shuffle(random);
    return shuffledPromos.take(min(count, shuffledPromos.length)).toList();
  }

  List<Store> getRandomStores(List<Store> stores, int count) {
    final random = Random();
    List<Store> shuffledStores = List.from(stores);
    shuffledStores.shuffle(random);
    return shuffledStores.take(min(count, shuffledStores.length)).toList();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // Jika kotak pencarian kosong, kembali ke featured stores
        filteredStores = stores;
      } else {
        // Gunakan allStores untuk filtering agar hasil pencarian tidak terbatas
        filteredStores = allStores
            .where((store) =>
                store.fields.brand.toLowerCase().contains(query) ||
                store.fields.description.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Widget _buildStoreContainer(Store store, int index) {
  int imageIndex = index % AppImages.stores.length; // Mengambil index secara berulang
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gambar Store
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(AppImages.stores[imageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informasi Store
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.fields.brand,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store.fields.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        centerTitle: false, 
        backgroundColor: Colors.white,
        elevation: 4,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                AppImages.logo,
                width: 40, // Ukuran logo
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8), // Jarak antara logo dan teks
            const Text(
              'BANDUNG COUTURE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      drawer: const LeftDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchInitialData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Promo Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Exclusive Fashion Promos',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PromoPage(),
                                    ),
                                  );
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 180,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _promoController,
                                  itemCount: promos.length,
                                  itemBuilder: (context, index) {
                                    final promo = promos[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black87, Colors.grey.shade800],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${promo.discountPercentage}% OFF',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            promo.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            promo.description,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Positioned.fill(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                        onPressed: () {
                                          _promoController.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                        onPressed: () {
                                          _promoController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.search, color: Colors.black),
                          hintText: 'Search for fashion stores...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                      ),
                    ),

                    // Search Results (shown only when searching)
                    if (_searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Search Results (${filteredStores.length})',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const StoresPage(),
                                      ),
                                    );
                                  },
                                  child: const Text('View All Stores'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...filteredStores.asMap().entries.map((entry) => _buildStoreContainer(entry.value, entry.key)).toList(),
                          ],
                        ),
                      ),

                    // Featured Stores Section
                    if (_searchController.text.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Featured Stores',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const StoresPage(),
                                      ),
                                    );
                                  },
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...stores.asMap().entries.map((entry) => _buildStoreContainer(entry.value, entry.key)).toList(),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.white,
    );
  }
}



