import 'package:bandung_couture_mobile/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Bandung Couture',
        theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.black, // Warna utama hitam
            onPrimary: Colors.white, // Teks pada warna utama
            secondary: Colors.grey, // Warna aksen abu-abu
            onSecondary: Colors.white, // Teks pada warna aksen
            error: Colors.red, // Warna untuk kesalahan
            onError: Colors.white,
            surface: Colors.white, // Warna permukaan
            onSurface: Colors.black, // Teks pada permukaan
          ),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    );
  }
}
