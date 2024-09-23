import 'package:flutter/material.dart';

import '../models/property_listing.dart';

class ListingCard extends StatelessWidget {
  final PropertyListing listing;

  const ListingCard({Key? key, required this.listing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.listing_title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Views: ${listing.view_count}"),
          ],
        ),
      ),
    );
  }
}