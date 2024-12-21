import 'package:bandung_couture_mobile/constants/url.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class WishlistButton extends StatefulWidget {
  final int storeId;
  final CookieRequest request;

  const WishlistButton({
    super.key,
    required this.storeId,
    required this.request,
  });

  @override
  _WishlistButtonState createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  bool _isWishlisted = false; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus(); // Check the initial status when widget is first created
  }

  // Method to check if the store is already in the wishlist
  Future<void> _checkWishlistStatus() async {
    bool status = await checkIsWishlisted(widget.request, widget.storeId);
    setState(() {
      _isWishlisted = status;
    });
  }

  Future<void> _toggleWishlist() async {
    final url = _isWishlisted
        ? '${URL.urlLink}wishlist/remove/${widget.storeId}/'
        : '${URL.urlLink}wishlist/add/${widget.storeId}/';
    await widget.request.get(url);

    setState(() {
      _isWishlisted = !_isWishlisted;
    });
  }

  Future<bool> checkIsWishlisted(CookieRequest request, int storeId) async {
    final response =
        await request.get('${URL.urlLink}wishlist/check/$storeId/');
    return response['is_in_wishlist'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggleWishlist,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _isWishlisted ? Colors.red : Colors.green, // Button color
      ),
      child: Text(
        _isWishlisted ? "Remove from Wishlist" : "Add to Wishlist",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
