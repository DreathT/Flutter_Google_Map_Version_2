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

  Set<Marker> _markers = {}; // Markerları tutmak için bir set oluşturduk
  List<LatLng> markerLocations = []; // Marker konumlarını tutmak için bir liste oluşturduk

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.6771, 26.5557),
    zoom: 14.4746,
  );

  String infoText = 'Lütfen bulunduğunuz konumu seçiniz'; // Kullanıcıya gösterilecek bilgi metni

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
            onTap: _addMarker, // Haritaya tıklanınca _addMarker fonksiyonunu çağırıyoruz
            markers: _markers, // Haritada gösterilecek markerları belirtiyoruz
          ),
          Positioned(
            top: 10.0,
            left: 10.0,
            child: Text(infoText, style: TextStyle(fontSize: 20.0)), // Bilgi metnini ekrana yazdırıyoruz
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng pos) {
    if (_markers.length >= 2) {
      return; // Eğer zaten iki marker varsa, yeni bir marker eklemiyoruz
    }

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(pos.toString()),
        position: pos,
      ));
      markerLocations.add(pos); // Marker konumunu listeye ekliyoruz

      if (markerLocations.length == 1) {
        infoText = 'Lütfen gitmek istediğiniz konumu seçiniz'; // İlk marker seçildikten sonra bilgi metnini güncelliyoruz
      } else if (markerLocations.length == 2) { // Eğer iki marker seçildiyse, aralarındaki mesafeyi hesaplıyoruz
        _calculateDistance(markerLocations[0], markerLocations[1]);
        infoText = ''; // Mesafe hesaplandıktan sonra bilgi metnini siliyoruz
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
      infoText = 'Markerlar arasındaki mesafe: ${distanceInMeters.toStringAsFixed(2)} metre'; // Mesafeyi bilgi metnine yazdırıyoruz
    });
  }
}
