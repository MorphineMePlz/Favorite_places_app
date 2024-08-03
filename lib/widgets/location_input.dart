import 'dart:convert';
import 'dart:math';

import 'package:favorite_places_app/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});
  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  var isGettingLocation = false;
  PlaceLocation? pickedLocation;

  String get locationImage {
    if (pickedLocation == null) {
      return '';
    }

    final lat = pickedLocation!.latitude;
    final lng = pickedLocation!.longitude;

    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyCrN5dgRZ5vtcfeZCPwvgmbFP2VFRkqPMg';
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyCrN5dgRZ5vtcfeZCPwvgmbFP2VFRkqPMg');
    final response = await http.get(url);
    final responseData = json.decode(response.body);
    final address = responseData['results'][0]['formatted_address'];

    if (lat == null || lng == null) {
      return;
    }

    setState(() {
      isGettingLocation = false;
      pickedLocation =
          PlaceLocation(latitude: lat, longitude: lng, address: address);
    });

    widget.onSelectLocation(pickedLocation!);

  }



  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text('No location chosen',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Colors.white));

    if (isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    if (pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    }

    return Column(
      children: [
        Container(
            height: 170,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 4,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.2))),
            width: double.infinity,
            alignment: Alignment.center,
            child: previewContent),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              label: const Text('Get current location'),
              icon: const Icon(Icons.location_on),
            ),
            TextButton.icon(
              onPressed: () {},
              label: const Text('Select on map'),
              icon: const Icon(Icons.map),
            )
          ],
        )
      ],
    );
  }
}
