import 'package:flutter/material.dart';

import '../models/place.dart';

class PlaceDetails extends StatelessWidget {
  const PlaceDetails({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Center(
          child: Stack(
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            height: double.infinity,
          ),
        ],
      )),
    );
  }
}
