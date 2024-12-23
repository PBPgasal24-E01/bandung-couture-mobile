import 'package:bandung_couture_mobile/constants/app_images.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/screens/menu.dart';
import 'package:bandung_couture_mobile/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ).copyWith(
          primary: Colors.black,
          secondary: Colors.black,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo diletakkan di luar container login (card)
              Image.asset(
                AppImages.logo,
                height: 150, // perbesar tinggi logo
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40.0),

              // Card untuk login
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Ubah lebar Card agar lebih sempit
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () async {
                          String username = _usernameController.text;
                          String password = _passwordController.text;

                          final response =
                              await request.login('${URL.urlLink}auth/login/', {
                            'username': username,
                            'password': password,
                          });

                          if (request.loggedIn) {
                            String message = response['message'];
                            String uname = response['username'];
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "$message Selamat datang, $uname.")),
                                );
                            }
                          } else {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Login Gagal'),
                                  content: Text(response['message']),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 36.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                          child: RichText(
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Daftar Sekarang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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
