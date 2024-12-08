import 'package:bandung_couture_mobile/screens/forum/forum.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class AddForumEntryForm extends StatefulWidget {
  @override
  _AddForumEntryFormState createState() => _AddForumEntryFormState();
}

class _AddForumEntryFormState extends State<AddForumEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  Future<void> addForumEntry(CookieRequest request) async {
    final String title = _titleController.text;
    final String details = _detailsController.text;

    
    final response = await request.postJson(
      '${URL.urlLink}forum/add_flutter/',
      jsonEncode(<String, String>{
        'title': title,
        'details': details,
      })
    );


    if (context.mounted) {
        if (response['status'] == 'success') {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(
            content: Text("Forum baru berhasil disimpan!"),
            ));
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
            );
        } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(
                content:
                    Text("Terdapat kesalahan, silakan coba lagi."),
            ));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Forum Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(labelText: 'Details'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addForumEntry(request);
                  }
                },
                child: Text('Submit'),
              )
              ],

            ),
  
          ),
        ),
      ),
    );
  }
}