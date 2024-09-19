import 'package:bookstore/model/Cart_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: cart.items.isEmpty
          ? Center(child: Text('No items in the cart'))
          : ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (context, index) {
                final book = cart.items[index];
                return ListTile(
                  title: Text(book['bookName']),
                  subtitle: Text(book['author']),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      cart.removeItem(book['_id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed from Cart')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
