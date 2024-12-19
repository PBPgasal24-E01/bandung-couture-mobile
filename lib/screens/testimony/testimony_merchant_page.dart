import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/models/testimony/testimony.dart';
import 'package:bandung_couture_mobile/screens/testimony/testimony_form.dart';
import 'package:bandung_couture_mobile/screens/testimony/testimony_page.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class TestimonyMerchantPage extends StatelessWidget {
  final int storeId;
  final String storeName;
  final String description;

  const TestimonyMerchantPage({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ulasan Toko $storeName"),
          backgroundColor: Colors.white, // AppBar color
          elevation: 4, // Shadow for AppBar
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TestimonyPage()),
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
              25, 25, 25, 25), // Padding for the whole page
          child: Column(
            children: [
              const SizedBox(height: 10),
              TestimonyHeader(
                  storeName: storeName,
                  description: description,
                  storeId: storeId),
              const SizedBox(height: 10),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CurrentTestimony(
                      storeId: storeId,
                      storeName: storeName,
                      description: description,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Color.fromRGBO(255, 236, 179, 1),
                      thickness: 2,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TestimonySection(storeId: storeId),
                    )
                  ],
                ),
              ))
            ],
          ),
        ));
  }
}

class CurrentTestimony extends StatefulWidget {
  final int storeId;
  final String storeName;
  final String description;

  const CurrentTestimony({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.description,
  });

  @override
  State<CurrentTestimony> createState() => _CurrentTestimony();
}

class _CurrentTestimony extends State<CurrentTestimony> {
  Future<CurrentData> fetchFeedback(CookieRequest request) async {
    final response = await request.get(
        '${URL.urlLink}testimony/exist_testimony_by_store/${widget.storeId}');

    final data = CurrentData.fromJson(response);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder(
      future: fetchFeedback(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.status) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ulasan Terakhir",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${snapshot.data!.user}",
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${snapshot.data!.rating}/5",
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${snapshot.data!.testimony}",
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 8),
                        ]),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TestimonyformPage(
                                  edit: true,
                                  storeName: widget.storeName,
                                  id: widget.storeId,
                                  description: widget.description,
                                  instance: Testimony(
                                    pk: snapshot.data!.pk,
                                    user: snapshot.data!.user,
                                    testimony: snapshot.data!.testimony,
                                    rating: snapshot.data!.rating.toString(),
                                  ))),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.amber,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final response = await request.get(
                            '${URL.urlLink}testimony/delete_testimony_flutter/${snapshot.data!.pk}');

                        if (context.mounted) {
                          setState(() {});
                          SnackBar(
                            content: Text(
                                '${response['status']}: ${response['message']}'),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.amber,
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                  ],
                )
              ]);
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TestimonyformPage(
                              edit: false,
                              storeName: widget.storeName,
                              description: widget.description,
                              id: widget.storeId,
                            )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.amber,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              const SizedBox(width: 4),
              const Text(
                "Tambahkan ulasan untuk toko ini!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class TestimonyHeader extends StatefulWidget {
  final String storeName;
  final String description;
  final int storeId;

  const TestimonyHeader({
    super.key,
    required this.storeName,
    required this.description,
    required this.storeId,
  });

  @override
  State<TestimonyHeader> createState() => _TestimonyHeader();
}

class _TestimonyHeader extends State<TestimonyHeader> {
  Future<double> getRating(CookieRequest request) async {
    final userTestimony = await request
        .get('${URL.urlLink}testimony/get_rating/${widget.storeId}');

    double listTestimony = userTestimony["rating"];
    return listTestimony;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder(
      future: getRating(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData) {
            return const Column(
              children: [
                Text(
                  'NA',
                  style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                ),
                SizedBox(height: 8),
              ],
            );
          } else {
            return Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.storeName,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text(
                      "Overal Rating",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Row(
                      children: List.generate(5, (index) {
                        // Change 5 to a smaller number
                        return Center(
                          child: Icon(
                            index < snapshot.data!.round()
                                ? Icons.star
                                : Icons.star_border_outlined,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                  ],
                )
              ],
            );
          }
        }
      },
    );
  }
}

class TestimonySection extends StatefulWidget {
  final int storeId;

  const TestimonySection({
    super.key,
    required this.storeId,
  });

  @override
  State<TestimonySection> createState() => _TestimonySection();
}

class _TestimonySection extends State<TestimonySection> {
  Future<List<Testimony>> fetchTestimony(CookieRequest request) async {
    final userTestimony = await request
        .get('${URL.urlLink}testimony/merchant_json/${widget.storeId}');
    final getExistingTestimony = await request.get(
        '${URL.urlLink}testimony/exist_testimony_by_store/${widget.storeId}');

    final existingTestimony = CurrentData.fromJson(getExistingTestimony);
    List<Testimony> listTestimony = [];
    for (var d in userTestimony) {
      if (d != null) {
        var current_user_testimony = Testimony.fromJson(d);
        if (existingTestimony.status &&
            current_user_testimony.pk == existingTestimony.pk) {
          continue;
        }
        listTestimony.add(current_user_testimony);
      }
    }
    return listTestimony;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder(
      future: fetchTestimony(request),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (!snapshot.hasData) {
            return const Column(
              children: [
                Text(
                  'Belum ada ulasan pada toko ini',
                  style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                ),
                SizedBox(height: 8),
              ],
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${snapshot.data![index].user}",
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${snapshot.data![index].rating}/5",
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${snapshot.data![index].testimony}",
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 8),
                        ]),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
