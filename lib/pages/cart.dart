import 'package:flutter/material.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required List<Map<String, dynamic>> cartItems});

  @override
  _CartPageState createState() => _CartPageState();

}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> cartItems= [];

  Future<void> fetchCartItems() async {
    final String apiUrl =
        'https://bookstore.incubation.bridgelabz.com/bookstore_user/get_cart_items';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(data['result']);
        });
        print("Successfully fetched cart items.");
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addTocart(String bookId) async {
  final String apiUrl =
      'https://bookstore.incubation.bridgelabz.com/bookstore_user/add_cart_list_item';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode({'bookId': bookId}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("Successfully added item to cart.");
      fetchCartItems(); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart')),
      );
    } else {
      print('Failed to add item to cart: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart')),
      );
    }
  } catch (e) {
    print('Error adding item to cart: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding to cart')),
    );
  }
}


  Future<void> deleteFromCart(String bookId) async {
    final String apiUrl =
        'https://bookstore.incubation.bridgelabz.com/bookstore_user/remove_cart_item/$bookId';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((book) => book['id'] == bookId);
        });
        print("Successfully removed item from cart.");
      } else {
        throw Exception('Failed to remove item from cart');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final book = cartItems[index];
                return Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/cover.png',
                        fit: BoxFit.cover,
                        height: 150,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['bookName'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(book['author']),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    deleteFromCart(book['id']);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
    );
  }
}
