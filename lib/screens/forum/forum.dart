import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:bandung_couture_mobile/models/forum/forum_entry.dart'; // Ensure this import is correct and the ForumEntry class is defined in this file
import 'dart:convert';
import 'package:bandung_couture_mobile/main.dart';
import 'package:provider/provider.dart';
import 'package:bandung_couture_mobile/constants/url.dart';

class ForumPage extends StatefulWidget {
  final bool idNotFound;
  
  const ForumPage({Key? key, this.idNotFound = false}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool showOnlyMyForums = false;
  
  void showForumForm() {
    // TODO: Implement forum form dialog
  }

  Future<List<Forum>> fetchForumEntries() async {
    final request = context.watch<CookieRequest>();
    final response = await request.get('${URL.urlLink}forum/show_json_raw/'));

    var data = response;

    List<Forum> listMood = [];
    for (var d in data) {
      if (d != null) {
        listMood.add(Forum.fromJson(d));
      }
    }
    return listMood;
  }

  @override
  void initState() {
    super.initState();
    refreshForumEntries();
  }

  void refreshForumEntries() {
    fetchForumEntries();
    setState(() {
      // TODO: Implement forum refresh logic
    });
  }

  @override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
        backgroundColor: Colors.black, // Latar belakang hitam
        iconTheme: const IconThemeData(
          color: Colors.white, // Warna ikon hamburger menu putih
        ),
        actions: const [
          // Avatar di pojok kanan atas
          CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white), // Ikon putih
          ),
          SizedBox(width: 15), // Memberikan jarak di sisi kanan
        ],
      ),
      drawer: const LeftDrawer(),
			body: SingleChildScrollView(
				child: Padding(
					padding: const EdgeInsets.fromLTRB(16, 96, 16, 32),
					child: Column(
						children: [
							if (widget.idNotFound)
								Container(
									width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[500],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Your requested Forum discussion ID is not Found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ElevatedButton(
                    onPressed: showForumForm,
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
                    Checkbox(
                      value: showOnlyMyForums,
                      onChanged: (value) {
                        setState(() {
                          showOnlyMyForums = value ?? false;
                          refreshForumEntries();
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Only Show My Forums',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Forum entries container
              Container(
                child: Column(
                  children: [
                    // TODO: Add forum entry cards
                    Text('Forum entry card placeholder'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}