import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookstore/model/Cart_model.dart';
import 'package:bookstore/pages/cart.dart';
import 'package:bookstore/pages/search.dart';
import 'package:bookstore/pages/view.dart';
import 'package:bookstore/pages/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> wishlist = [];
  List<Map<String, dynamic>> cartItems = [];

  Future<void> fetchBooks() async {
    final String apiUrl =
        'https://bookstore.incubation.bridgelabz.com/bookstore_user/get/book';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print("Successful............................................");
        setState(() {
          final List<dynamic> decodedData =
              json.decode(response.body)['result'];
          books =
              decodedData.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  void addToWishlist(Map<String, dynamic> book) async {
    final String bookId = book['_id'];

    try {
      final String apiUrl =
          'https://bookstore.incubation.bridgelabz.com/bookstore_user/add_wish_list_item';

      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({'bookId': bookId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          if (!wishlist.any((item) => item['_id'] == bookId)) {
            wishlist.add(book);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added to Wishlist')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Already in Wishlist')),
            );
          }
        });
      } else {
        final errorMessage = json.decode(response.body)['message'] ??
            'Failed to add item to wishlist';
        print('Failed to add item to wishlist: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to Wishlist')),
        );
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to Wishlist')),
      );
    }
  }

   void fetchWishlist() async {
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

  Future<void> fetchCartItems() async {
    final String apiUrl =
        'https://bookstore.incubation.bridgelabz.com/bookstore_user/get_cart_items';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> decodedData =
              json.decode(response.body)['result'];
          cartItems =
              decodedData.map((item) => item as Map<String, dynamic>).toList();
        });
        print("Cart items fetched successfully");
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
    }

    @override
    void initState() {
      super.initState();
      fetchBooks();
      fetchCartItems(); // Fetch cart items
    }
  }

  void addTocart(String bookId) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Bookstore'),
          leading: const Icon(Icons.book),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WishlistPage(wishlist: wishlist),
                  ),
                );
              },
              icon: const Icon(Icons.favorite),
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchPage(books: books)));
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CartPage(cartItems: cartItems,)));
                },
                icon: const Icon(Icons.shopping_cart)),
          ],
        ),
        body: StaggeredGridView.countBuilder(
          crossAxisCount: 4,
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final isFavorite =
                wishlist.any((item) => item['_id'] == book['_id']);
            return InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => BookView(book: book),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                );
              },
              child: Card(
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
                    Text(
                      book['bookName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(book['author']),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Rs. ${book['discountPrice'].toString()}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 27)),
                        Text(
                          'Rs. ${book['price'].toString()}',
                          style:
                              TextStyle(decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            addToWishlist(book);
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            addToWishlist(book);
                          },
                          child: Text('Add to Bag'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ));
  }
}
