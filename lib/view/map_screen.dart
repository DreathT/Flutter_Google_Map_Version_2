import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> _markers = {};
  List<LatLng> markerLocations = [];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.6771, 26.5557),
    zoom: 14.4746,
  );

  String infoText = 'Lütfen bulunduğunuz konumu seçiniz';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _addMarker,
            markers: _markers,
          ),
          Positioned(
            top: 10.0,
            left: 10.0,
            child: ElevatedButton(
              onPressed: () {
                if (markerLocations.length == 2) {
                  _calculateDistance(markerLocations[0], markerLocations[1]);
                }
              },
              child: Text(infoText, style: TextStyle(fontSize: 20.0)),
            ),
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng pos) {
    if (_markers.length >= 2) {
      return;
    }

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(pos.toString()),
        position: pos,
      ));
      markerLocations.add(pos);

      if (markerLocations.length == 1) {
        infoText = 'Tamam, şimdi gitmek istediğiniz konumu seçiniz';
      } else if (markerLocations.length == 2) {
        infoText = 'Mesafeyi hesapla';
      }
    });
  }

  Future<void> _calculateDistance(LatLng pos1, LatLng pos2) async {
    double distanceInMeters = Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
    setState(() {
      infoText = 'Konumlar arasındaki mesafe: ${distanceInMeters.toStringAsFixed(2)} metre';
    });
  }
}
