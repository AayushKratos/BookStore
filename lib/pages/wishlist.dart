import 'package:flutter/material.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key, required List<Map<String, dynamic>> wishlist});

  @override
  _WishlistPageState createState() => _WishlistPageState();

}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> wishlist = [];

  Future<void> fetchWishlist() async {
    final String apiUrl =
        'https://bookstore.incubation.bridgelabz.com/bookstore_user/get_wishlist_items';

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
          wishlist = List<Map<String, dynamic>>.from(data['result']);
        });
        print("Successfully fetched wishlist items.");
      } else {
        throw Exception('Failed to load wishlist items');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addToWishlist(String bookId) async {
  final String apiUrl =
      'https://bookstore.incubation.bridgelabz.com/bookstore_user/add_wish_list_item';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: json.encode({'bookId': bookId}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("Successfully added item to wishlist.");
      fetchWishlist(); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to Wishlist')),
      );
    } else {
      print('Failed to add item to wishlist: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to Wishlist')),
      );
    }
  } catch (e) {
    print('Error adding item to wishlist: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding to Wishlist')),
    );
  }
}


  Future<void> deleteFromWishlist(String bookId) async {
    final String apiUrl =
        'https://bookstore.incubation.bridgelabz.com/bookstore_user/remove_wishlist_item/$bookId';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          wishlist.removeWhere((book) => book['id'] == bookId);
        });
        print("Successfully removed item from wishlist.");
      } else {
        throw Exception('Failed to remove item from wishlist');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Text(
                'Your wishlist is empty.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final book = wishlist[index];
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
                                    deleteFromWishlist(book['id']);
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
