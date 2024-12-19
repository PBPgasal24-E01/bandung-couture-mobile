// promo_detail.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bandung_couture_mobile/models/promo/promo.dart';

class PromoDetailDialog extends StatelessWidget {
  final Promo promo;
  final VoidCallback onClose;

  const PromoDetailDialog({
    super.key,
    required this.promo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        promo.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              promo.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'Discount: ${promo.discountPercentage}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Promo Code: ${promo.promoCode}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Valid Until: ${DateFormat('dd MMM yyyy').format(promo.endDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: onClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Back',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
