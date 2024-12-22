import 'package:bandung_couture_mobile/screens/forum/details_forum.dart';
import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/models/forum/forum_entry.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/screens/forum/add_forumentry_form.dart';
import 'package:bandung_couture_mobile/screens/forum/edit_forumentry_form.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool showOnlyMyForums = false;
  late Future<List<Forum>> _forumEntriesFuture;
  late CookieRequest request;

  @override
  void initState() {
    super.initState();
    request = context.read<CookieRequest>();
    _forumEntriesFuture = fetchForumEntries(request);
  }


  void navigateToAddForumPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddForumEntryForm()),
    ).then((_) {
      refreshForumEntries();
    });
  }

  void navigateToDetailsForum(String pk) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsForumPage(pk: pk,)),
    ).then((_) {
      refreshForumEntries();
    });
  }

  Future<void> refreshForumEntries() async {
    setState(() {
      _forumEntriesFuture = fetchForumEntries(request);
    });
  }

  Future<List<Forum>> fetchForumEntries(CookieRequest request) async {
    final response = await request.get('${URL.urlLink}forum/show_json/');

    var data = response;

    List<Forum> listForum = [];
    for (var d in data) {
      if (Forum.fromJson(d).fields.parent != "None") continue;
      listForum.add(Forum.fromJson(d));
    }
    return listForum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forum"),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: const LeftDrawer(),
      body: RefreshIndicator(
        onRefresh: refreshForumEntries,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 96, 16, 32),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: ElevatedButton(
                      onPressed: navigateToAddForumPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[700],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add New Forum',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showOnlyMyForums = !showOnlyMyForums;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[700],
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 1,
                        ),
                        child: Text(
                          showOnlyMyForums ? 'Show All Forums' : 'Only Show My Forums',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<Forum>>(
                  future: _forumEntriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No forum entries found.');
                    } else {
                      List<Forum> forums = snapshot.data!;
                      if (showOnlyMyForums) {
                        forums = forums.where((forum) => forum.fields.isAuthor).toList();
                      }
                      return Column(
                        children: forums.map((forum) {
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
                                                await request.postJson(
                                                  '${URL.urlLink}forum/delete_flutter/',
                                                  jsonEncode(<String, String>{
                                                    'pk': forum.pk,
                                                  }),
                                                );
                                                refreshForumEntries();
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      navigateToDetailsForum(forum.pk);
                                    },
                                    child: Text(
                                      forum.fields.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
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
                                      GestureDetector(
                                        onTap: () {
                                          navigateToDetailsForum(forum.pk);
                                        },
                                        child: const Text(
                                          'Read more',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
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
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}