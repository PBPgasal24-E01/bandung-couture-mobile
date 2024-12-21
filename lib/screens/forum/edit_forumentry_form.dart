import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/models/forum/forum_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:bandung_couture_mobile/constants/url.dart';

class EditForumEntryForm extends StatefulWidget {
  final Forum forumEntry;

  const EditForumEntryForm({Key? key, required this.forumEntry}) : super(key: key);

  @override
  _EditForumEntryFormState createState() => _EditForumEntryFormState();
}

class _EditForumEntryFormState extends State<EditForumEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late CookieRequest request;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.forumEntry.fields.title);
    _detailsController = TextEditingController(text: widget.forumEntry.fields.details);
    request = context.read<CookieRequest>();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = jsonEncode(<String, dynamic>{
        'pk': widget.forumEntry.pk,
        'title': _titleController.text,
        'details': _detailsController.text,
      });
      final response = await request.postJson(
        '${URL.urlLink}forum/edit_flutter/',
        data,
      );

      if (response['status'] == 'success') {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update the forum entry')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Forum Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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