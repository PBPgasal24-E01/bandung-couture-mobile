import 'dart:convert';
import 'package:bandung_couture_mobile/models/testimony/testimony.dart';
import 'package:bandung_couture_mobile/screens/testimony/testimony_merchant_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bandung_couture_mobile/constants/url.dart';

class TestimonyformPage extends StatefulWidget {
  final Testimony? instance;
  final String storeName;
  final String description;
  final bool edit;
  final int id;

  const TestimonyformPage({
    super.key,
    this.instance,
    required this.edit,
    required this.storeName,
    required this.id,
    required this.description,
  });

  @override
  State<TestimonyformPage> createState() {
    return _TestimonyFormPageState();
  }
}

class _TestimonyFormPageState extends State<TestimonyformPage> {
  final _formKey = GlobalKey<FormState>();

  late String _testimony;
  late int _rating;

  @override
  void initState() {
    super.initState();

    if (widget.edit) {
      _testimony = widget.instance!.testimony;
      _rating = int.parse(widget.instance!.rating);
    } else {
      _testimony = "";
      _rating = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Tambahkan Ulasan Untuk ${widget.storeName}',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Define the action to take when the back arrow is pressed
            Navigator.pop(
                context); // Example: to go back to the previous screen
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: _testimony,
                decoration: InputDecoration(
                  hintText: "Tempat ini sangat bagus!",
                  labelText: "Ulasan",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _testimony = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Testimoni tidak boleh kosong!";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                initialValue: _rating.toString(),
                decoration: InputDecoration(
                  hintText: "Rating",
                  labelText: "Rating",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _rating = int.tryParse(value!) ?? 0;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Rating tidak boleh kosong!";
                  }
                  if (int.tryParse(value) == null) {
                    return "Rating harus berupa angka!";
                  }

                  if (int.parse(value) < 1 || int.parse(value) > 5) {
                    return "Rating harus diantara 1-5!";
                  }
                  return null;
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String url = widget.edit
                          ? '${URL.urlLink}testimony/edit_testimony_flutter/'
                          : '${URL.urlLink}testimony/add_testimony_flutter/';

                      final response = await request.postJson(
                        url,
                        jsonEncode(<String, String>{
                          'testimony': _testimony,
                          'rating': _rating.toString(),
                          'store_id': widget.id.toString(),
                          if (widget.edit) 'pk': widget.instance!.pk.toString()
                        }),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '${response['status']}: ${response['message']}'),
                        ));
                        if (response['status'] == 'success') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TestimonyMerchantPage(
                                        storeName: widget.storeName,
                                        description: widget.description,
                                        storeId: widget.id,
                                      )));
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
