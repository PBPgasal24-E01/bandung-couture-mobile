import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/screens/login.dart';
import 'package:bandung_couture_mobile/screens/menu.dart';
import 'package:bandung_couture_mobile/screens/pages.dart';
import 'package:bandung_couture_mobile/screens/promo/promo_page.dart';
import 'package:bandung_couture_mobile/screens/stores/stores_page.dart';
import 'package:bandung_couture_mobile/screens/testimony/testimony_page.dart';
import 'package:bandung_couture_mobile/screens/wishlist/wishlistPage.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              children: [
                Text(
                  'Bandung Couture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                  "Manage and track your products here!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Menu Home
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          // Menu Product
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Stores'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoresPage(),
                ),
              );
            },
          ),
          // Menu Promo
          ListTile(
            leading: const Icon(Icons.local_offer_outlined),
            title: const Text('Promo'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PromoPage(),
                ),
              );
            },
          ),
          // Menu Wishlist
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Wishlist'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistPage(),
                ),
              );
            },
          ),
          // Menu Forum
          ListTile(
            leading: const Icon(Icons.forum_outlined),
            title: const Text('Forum'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForumPage(),
                ),
              );
            },
          ),
          // Menu Rating
          ListTile(
            leading: const Icon(Icons.star_border_outlined),
            title: const Text('Rating'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestimonyPage(),
                ),
              );
            },
          ),
          // Menu Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final response =
                  await request.logout("${URL.urlLink}auth/logout/");
              String message = response["message"];

              if (context.mounted) {
                if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$message Sampai jumpa, $uname."),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
