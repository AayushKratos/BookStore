import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartModel extends ChangeNotifier {
  final String apiUrl = 'https://yourapiurl.com/cart'; // Update with your API URL
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  int get itemCount => _items.length;

  // Fetch cart items from the API
  Future<void> fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        _items = decodedData.map((item) => item as Map<String, dynamic>).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      print(e);
    }
  }

  // Add item to the cart
  Future<void> addItem(Map<String, dynamic> book) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book),
      );

      if (response.statusCode == 200) {
        _items.add(book);
        notifyListeners();
      } else {
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      print(e);
    }
  }

  // Remove item from the cart
  Future<void> removeItem(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$bookId'),
      );

      if (response.statusCode == 200) {
        _items.removeWhere((item) => item['_id'] == bookId);
        notifyListeners();
      } else {
        throw Exception('Failed to remove item from cart');
      }
    } catch (e) {
      print(e);
    }
  }

  // Optionally, update item in the cart
  Future<void> updateItem(Map<String, dynamic> book) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/${book['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book),
      );

      if (response.statusCode == 200) {
        final index = _items.indexWhere((item) => item['_id'] == book['_id']);
        if (index != -1) {
          _items[index] = book;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update item in cart');
      }
    } catch (e) {
      print(e);
    }
  }
}
