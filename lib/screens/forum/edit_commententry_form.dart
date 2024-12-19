import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/models/forum/comment.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:bandung_couture_mobile/constants/url.dart';

class EditCommentEntryForm extends StatefulWidget {
  final Comment commentEntry;

  const EditCommentEntryForm({Key? key, required this.commentEntry}) : super(key: key);

  @override
  _EditCommentEntryFormState createState() => _EditCommentEntryFormState();
}

class _EditCommentEntryFormState extends State<EditCommentEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _detailsController;
  late CookieRequest request;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController(text: widget.commentEntry.fields.details);
    request = context.read<CookieRequest>();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = jsonEncode(<String, dynamic>{
        'pk': widget.commentEntry.pk,
        'title': "Empty",
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
          const SnackBar(content: Text('Failed to update the comment')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Comment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Comment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter comment details';
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