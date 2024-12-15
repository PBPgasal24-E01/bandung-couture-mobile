import 'package:bandung_couture_mobile/screens/stores/stores_page.dart';
import 'package:flutter/material.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';

class TestimonyPage extends StatelessWidget {
  const TestimonyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Stores Testimony and Rating"),
          backgroundColor: Colors.white, // AppBar color
          elevation: 4, // Shadow for AppBar
        ),
        drawer: const LeftDrawer(),
        body: const Padding(
            padding: EdgeInsets.all(16.0), // Padding for the whole page
            child: StoresSection()
            // Column(
            //   children: [
            //     StoresSection(),
            //   ],
            // )),
            ));
  }
}

// class StoresWithTestimony extends StatefulWidget {
//   const StoresWithTestimony({super.key});

//   @override
//   State<StoresWithTestimony> createState() => _StoreWihtTestimonyState();
// }

// class _StoreWihtTestimonyState extends State<StoresWithTestimony> {
//   Future<List<Store>> fetchStores(CookieRequest request) async {
//     final response =
//         await request.get('${URL.urlLink}testimony/get_all_merchant/');
//     var data = response;
//     List<Store> storesList = [];
//     for (var d in data) {
//       if (d != null) {
//         storesList.add(Store.fromJson(d));
//       }
//     }
//     return storesList;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final request = context.watch<CookieRequest>();
//     var isVisitor = request.jsonData['role'] == 1;
//     return FutureBuilder(
//       future: fetchStores(request),
//       builder: (context, AsyncSnapshot snapshot) {
//         if (snapshot.data == null) {
//           return const Center(child: CircularProgressIndicator());
//         } else {
//           if (!snapshot.hasData) {
//             return const Column(
//               children: [
//                 Text(
//                   'Belum ada toko dalam sistem',
//                   style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
//                 ),
//                 SizedBox(height: 8),
//               ],
//             );
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (_, index) {
//                 return Card(
//                   elevation: 4,
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(children: [
//                           Text(
//                             "${snapshot.data![index].fields.brand}",
//                             style: const TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           RatingIcon(
//                             storeId: snapshot.data![index].pk,
//                             storeName: ,
//                             request: request,
//                           ),
//                         ]),
//                         const SizedBox(height: 8),
//                         Text(
//                           "${snapshot.data![index].fields.description}",
//                           style: const TextStyle(fontSize: 14.0),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(Icons.location_on,
//                                 size: 14, color: Colors.grey),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 "${snapshot.data![index].fields.address}",
//                                 style: const TextStyle(
//                                     fontSize: 12.0, color: Colors.grey),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(Icons.phone,
//                                 size: 14, color: Colors.grey),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 "${snapshot.data![index].fields.contactNumber}",
//                                 style: const TextStyle(
//                                     fontSize: 12.0, color: Colors.grey),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(Icons.web, size: 14, color: Colors.grey),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 "${snapshot.data![index].fields.website}",
//                                 style: const TextStyle(
//                                     fontSize: 12.0, color: Colors.blue),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(Icons.share,
//                                 size: 14, color: Colors.grey),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 "${snapshot.data![index].fields.socialMedia}",
//                                 style: const TextStyle(
//                                     fontSize: 12.0, color: Colors.blue),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         if (isVisitor)
//                           Align(
//                             alignment: Alignment.bottomRight,
//                             child: WishlistButton(
//                               storeId: snapshot.data![index].pk,
//                               request: request,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         }
//       },
//     );
//   }
// }
