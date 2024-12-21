import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/screens/stores/contributor_stores_page.dart';
import 'package:bandung_couture_mobile/models/stores/store.dart';
import 'package:bandung_couture_mobile/widgets/stores/multi_select.dart';

class StoreFormPage extends StatefulWidget {
  final Store? instance;
  final bool edit;

  const StoreFormPage({super.key, this.instance}) : edit = instance != null;

  @override
  State<StoreFormPage> createState() => _StoreFormPageState();
}

class _StoreFormPageState extends State<StoreFormPage> {
  final _formKey = GlobalKey<FormState>();

  late String _brand,
      _description,
      _address,
      _contactNumber,
      _website,
      _socialMedia;
  late List<int> _categories;

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
  void initState() {
    super.initState();
    if (widget.edit) {
      _brand = widget.instance!.fields.brand;
      _description = widget.instance!.fields.description;
      _address = widget.instance!.fields.address;
      _contactNumber = widget.instance!.fields.contactNumber;
      _website = widget.instance!.fields.website;
      _socialMedia = widget.instance!.fields.socialMedia;
      _categories = widget.instance!.fields.categories;
    } else {
      _brand = _description =
          _address = _contactNumber = _website = _socialMedia = "";
      _categories = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contribute a Store',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Store Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              _buildTextFormField("Brand", _brand, (value) => _brand = value),
              _buildTextFormField(
                  "Description", _description, (value) => _description = value),

              // Multi-Select Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.category),
                label: const Text("Select Categories"),
                onPressed: _showMultiSelect,
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                  "Address", _address, (value) => _address = value),
              _buildTextFormField("Contact Number", _contactNumber,
                  (value) => _contactNumber = value),
              _buildTextFormField(
                  "Website", _website, (value) => _website = value),
              _buildTextFormField("Social Media", _socialMedia,
                  (value) => _socialMedia = value),

              const SizedBox(height: 30),

              // Save Button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String url = widget.edit
                          ? '${URL.urlLink}stores/edit-mobile'
                          : '${URL.urlLink}stores/add-mobile';
                      final response = await request.postJson(
                        url,
                        jsonEncode(<String, String>{
                          'brand': _brand,
                          'description': _description,
                          'categories': _categories.join(','),
                          'address': _address,
                          'contact_number': _contactNumber,
                          'website': _website,
                          'social_media': _socialMedia,
                          if (widget.edit) 'pk': widget.instance!.pk.toString()
                        }),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            '${response['status']}: ${response['description']}'),
                      ));
                      if (response['status'] == 'success') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ContributorStoresPage()),
                        );
                      }
                    }
                  },
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) => onChanged(value),
      ),
    );
  }
}
