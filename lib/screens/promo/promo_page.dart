import 'package:bandung_couture_mobile/models/promo/promo.dart';
import 'package:bandung_couture_mobile/screens/promo/promo_detail.dart';
import 'package:bandung_couture_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:bandung_couture_mobile/screens/promo/promo_form.dart';

enum PromoFilter {
  none,
  highestDiscount,
  nearestDeadline,
}

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  bool isLoading = true;
  List<Promo> promos = [];
  PromoFilter currentFilter = PromoFilter.none;

  @override
  void initState() {
    super.initState();
    fetchPromos();
  }

  void _sortPromos() {
    switch (currentFilter) {
      case PromoFilter.highestDiscount:
        promos.sort((a, b) => double.parse(b.discountPercentage)
            .compareTo(double.parse(a.discountPercentage)));
        break;
      case PromoFilter.nearestDeadline:
        promos.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case PromoFilter.none:
        break;
    }
  }

  Future<void> fetchPromos() async {
    final request = context.read<CookieRequest>();
    try {
      bool isVisitor = request.jsonData['role'] == 1;
      String endpoint = isVisitor
          ? '${URL.urlLink}promo/json/'
          : '${URL.urlLink}promo/json_own/';

      final response = await request.get(endpoint);
      if (response is Map<String, dynamic> && response.containsKey('promos')) {
        PromosModel promosModel = PromosModel.fromJson(response);
        setState(() {
          promos = promosModel.promos;
          _sortPromos();
          isLoading = false;
        });
      } else {
        throw Exception("Unexpected response structure");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load promos: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showPromoDetail(Promo promo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PromoDetailDialog(
          promo: promo,
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _deletePromo(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this promo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final request = context.read<CookieRequest>();
      try {
        final response = await request.get('${URL.urlLink}promo/delete_promo_flutter/$id/');

        if (response['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Promo berhasil dihapus'),
                duration: Duration(seconds: 3),
              ),
            );
            fetchPromos();
          }
        } else {
          throw Exception(response['message'] ?? 'Gagal menghapus promo');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isVisitor = request.jsonData['role'] == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isVisitor ? "Promo Spesial" : "Update Promo",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isVisitor ? "Kejar Diskon!" : "Buat Promo Spesial Hari Ini!",
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            if (isVisitor) 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<PromoFilter>(
                  value: currentFilter,
                  isExpanded: true,
                  underline: Container(),
                  hint: const Text('Filter Diskon'),
                  items: const [
                    DropdownMenuItem(
                      value: PromoFilter.none,
                      child: Text('Semua Promo'),
                    ),
                    DropdownMenuItem(
                      value: PromoFilter.highestDiscount,
                      child: Text('Diskon Terbesar'),
                    ),
                    DropdownMenuItem(
                      value: PromoFilter.nearestDeadline,
                      child: Text('Berakhir Segera'),
                    ),
                  ],
                  onChanged: (PromoFilter? value) {
                    if (value != null) {
                      setState(() {
                        currentFilter = value;
                        _sortPromos();
                      });
                    }
                  },
                ),
              ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : promos.isEmpty
                  ? const Center(
                      child: Text(
                        'No Promos Available',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: promos.length,
                      itemBuilder: (context, index) {
                        final promo = promos[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promo.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  promo.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text(
                                      'Diskon: ',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${promo.discountPercentage}%',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      'Kode Promo: ',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        promo.promoCode,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Valid Hingga: ${DateFormat("MMM. dd, yyyy, 'midnight'").format(promo.endDate)}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showPromoDetail(promo),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    child: const Text(
                                      'Detail',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isVisitor) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PromoForm(promo: promo),
                                              ),
                                            );
                                            if (result == true) {
                                              fetchPromos();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                          ),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _deletePromo(promo.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: !isVisitor
        ? FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PromoForm(),
                ),
              );
              if (result == true) {
                fetchPromos();
              }
            },
            child: const Icon(Icons.add),
          )
        : null,
    );
  }
}