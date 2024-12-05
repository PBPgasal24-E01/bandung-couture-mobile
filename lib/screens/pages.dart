import 'package:flutter/material.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kamu menekan tombol Promo')),
            );
          },
          child: const Text('Tekan untuk Promo'),
        ),
      ),
    );
  }
}

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kamu menekan tombol Wishlist')),
            );
          },
          child: const Text('Tekan untuk Wishlist'),
        ),
      ),
    );
  }
}
