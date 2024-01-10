import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttermap/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'HappyFuel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController  _originController = TextEditingController();   
  final TextEditingController  _destinationController = TextEditingController();

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;




  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.6771,  26.5557),
    zoom: 14.4746,
  );

  

  @override
  void initState() {
    super.initState();
    
    _setMarker(LatLng(41.6771,  26.5557));
  }

  void _setMarker(LatLng point) {
    setState((){
      _markers.add(
        Marker(
          markerId: MarkerId('marker'),position: point,
        ),
      );
    });
  }

  void _setPolygon(){
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: polygonLatLngs,
      strokeWidth: 2,
      strokeColor: Colors.transparent,


    ),
    );
  }

  void _setPolyline(List<PointLatLng> points){
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.add(Polyline(
      polylineId: PolylineId(polylineIdVal),
      points: points.map((point) => LatLng(point.latitude,point.longitude),).toList(),
      width: 2,
      color: Colors.blue,
    ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HappyFuel'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                  TextFormField(
                    controller: _originController,
                    
                    decoration: const InputDecoration(hintText: 'Başlangıç Noktası'),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                  TextFormField(
                    controller: _destinationController,
                    
                    decoration: const InputDecoration(hintText: 'Varış Noktası'),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  var directions = await LocationService().getDirections(_originController.text, _destinationController.text);

                  //var place = await LocationService().getPlace(_searchController.text);
                  _goToPlace(directions['start_location']['lat'], directions['start_location']['lng'],directions['bounds_ne'],directions['bounds_sw'],);
                  _setPolyline(directions['polyline_decoded']);
               },
               icon: const Icon(Icons.search),
              ), 
            ],
          ),
        
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (LatLng point) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
              },


            ),
          ),
        ],
      ),
      
    );
  }

   Future<void> _goToPlace(
    //Map<String,dynamic> place,
    double lat,
    double lng,
    Map<String,dynamic> bounds_ne,
    Map<String,dynamic> bounds_sw,
    ) async {
    //final double lat = place['geometry']['location']['lat'];
    //final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(lat, lng),
        zoom: 14.4746,
      ),
    ));
    controller.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(bounds_sw['lat'], bounds_sw['lng']),
        northeast: LatLng(bounds_ne['lat'], bounds_ne['lng']),
      ),
      25,
    ));
    _setMarker(LatLng(lat, lng));
  }

  
}