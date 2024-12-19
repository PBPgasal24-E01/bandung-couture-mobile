import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/models/forum/forum_entry.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/screens/forum/edit_forumentry_form.dart';
import 'package:bandung_couture_mobile/screens/forum/edit_commententry_form.dart';
import 'package:bandung_couture_mobile/models/forum/comment.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class DetailsForumPage extends StatefulWidget {
  final String pk;

  const DetailsForumPage({Key? key, required this.pk}) : super(key: key);

  @override
  _DetailsForumPageState createState() => _DetailsForumPageState();
}

class _DetailsForumPageState extends State<DetailsForumPage> {
  late CookieRequest request;
  late Future<Forum> _forumEntryFuture;
  late Future<List<Comment>> _childForumsFuture;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    request = context.read<CookieRequest>();
    refreshForumEntries();
  }

  Future<Forum> fetchForumEntry(String pk) async {
    final response = await request.get('${URL.urlLink}forum/show_json_by_id/$pk/');
    if (response.isNotEmpty) {
      return Forum.fromJson(response);
    } else {
      throw Exception('Forum entry not found');
    }
  }

  Future<List<Comment>> fetchChildForums(String parentPk) async {
    final response = await request.get('${URL.urlLink}forum/show_json_childs_by_id/$parentPk/');
    List<Comment> comments = [];
    for (var item in response) {
      comments.add(Comment.fromJson(item));
    }
    return comments;
  }

  Future<void> addComment() async {
    String comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar tidak boleh kosong')),
      );
      return;
    }

    final data = jsonEncode(<String, dynamic>{
      'title': "Empty",
      'details': comment,
      'parent': widget.pk,
    });

    final response = await request.postJson(
      '${URL.urlLink}forum/add_flutter/',
      data,
    );

    if (response['status'] == 'success') {
      _commentController.clear();
      setState(() {
        _childForumsFuture = fetchChildForums(widget.pk);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan komentar')),
      );
    }
  }

  Future<void> deleteForum(String pk, bool isMainForum) async {
    final data = jsonEncode(<String, dynamic>{
      'pk': pk,
    });

    final response = await request.postJson(
      '${URL.urlLink}forum/delete_flutter/',
      data,
    );

    if (response['status'] == 'success') {
      if (isMainForum) {
        Navigator.pop(context); 
      } else {
        setState(() {
          _childForumsFuture = fetchChildForums(widget.pk);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus forum')),
      );
    }
  }

  void refreshForumEntries()async {
    setState(() {
      _forumEntryFuture = fetchForumEntry(widget.pk);
      _childForumsFuture = fetchChildForums(widget.pk);
    });

  }

  Widget buildForumCard(Forum forum, bool isMainForum) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  forum.fields.time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
                if (forum.fields.isAuthor)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.yellow),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditForumEntryForm(forumEntry: forum),
                            ),
                          );

                          if (result == true) {
                            refreshForumEntries();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await deleteForum(forum.pk, isMainForum);
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              forum.fields.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              forum.fields.details,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'by @',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      forum.fields.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCommentCard(Comment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comment.fields.time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
                if (comment.fields.isAuthor)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.yellow),
                        onPressed: () async {
                            final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCommentEntryForm(commentEntry: comment),
                            ),
                            );

                            if (result == true) {
                            setState(() {
                              _childForumsFuture = fetchChildForums(widget.pk);
                            });
                            }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await deleteForum(comment.pk, false);
                        },
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              comment.fields.details,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'by @',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  comment.fields.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Komentar:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Masukkan komentar Anda',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChildForums(List<Comment> comments) {
    if (comments.isEmpty) {
      return const Center(child: Text('Belum ada komentar.'));
    }

    return Column(
      children: comments.map((comment) => buildCommentCard(comment)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Forum'),
      ),
      body: FutureBuilder<Forum>(
        future: _forumEntryFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Forum tidak ditemukan.'));
          } else {
            Forum forum = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  buildForumCard(forum, true),
                  const Divider(),
                  FutureBuilder<List<Comment>>(
                    future: _childForumsFuture,
                    builder: (context, childSnapshot) {
                      if (!childSnapshot.hasData || childSnapshot.data!.isEmpty) {
                        return const Center(child: Text('Belum ada komentar.'));
                      } else {
                        List<Comment> comments = childSnapshot.data!;
                        return buildChildForums(comments);
                      }
                    },
                  ),
                  const Divider(),
                  buildCommentSection(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}