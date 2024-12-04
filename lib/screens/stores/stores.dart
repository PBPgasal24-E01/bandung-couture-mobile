import 'package:flutter/material.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kamu menekan tombol Product')),
            );
          },
          child: const Text('Tekan untuk Product'),
        ),
      ),
    );
  }
}
