import 'package:flutter/material.dart';

class BookView extends StatelessWidget {
  final Map<String, dynamic> book;
  const BookView({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/cover.png',
                    fit: BoxFit.cover, height: 100, width: 100),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['bookName'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(book['author']),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Divider(),
            SizedBox(height: 15,),
            Row(
              children: [
                SizedBox(height: 15),
                Text(book['description']),
              ],
            )
          ],
        ),
      ),
    );
  }
}
