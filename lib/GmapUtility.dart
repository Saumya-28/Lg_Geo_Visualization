import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_poly_glide/SSH.dart';
import 'package:geo_poly_glide/providers.dart';
import 'package:geo_poly_glide/settings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'kml/LookAt.dart';

class GmapUtility extends ConsumerStatefulWidget {
  const GmapUtility({Key? key}) : super(key: key);

  @override
  _GmapUtilityState createState() => _GmapUtilityState();
}

class _GmapUtilityState extends ConsumerState<GmapUtility> {
  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  Set<Polygon> _polygon = HashSet<Polygon>();

  LatLng _center = const LatLng(25.697, 87.916);
  int rigcount = 5;
  double zoomvalue = 591657550.500000 / pow(2, 13.15393352508545);
  double latvalue = 28.65665656297236;
  double longvalue = -17.885454520583153;
  double tiltvalue = 41.82725143432617;
  double bearingvalue = 61.403038024902344; // 2D angle

  CameraPosition _kGoogle =  CameraPosition(
    target: LatLng(22.56850509249385, 88.37037933141761),
    zoom: 14,
    bearing: 61.403038024902344,
    tilt: 41.82725143432617,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }



  @override
  Widget build(BuildContext context) {
    bool connected = ref.watch(connectedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gmap Utility'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConnectionScreen()),
              );
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        mapType: MapType.normal,
        compassEnabled: true,
        circles: HashSet<Circle>.of(<Circle>[
          Circle(
            circleId: const CircleId('1'),
            center: _center,
            radius: 5000,
            fillColor: Colors.blue.withOpacity(0.3),
            strokeWidth: 3,
            strokeColor: Colors.blue,
          ),
        ]),
        initialCameraPosition: _kGoogle,
        onTap: (LatLng latLng) {
          _showCircle();
          print('Tapped: $latLng');
          setState(() {
            _center = latLng;
          });
        },
        onCameraIdle: _onCameraIdle,
        onCameraMove: _onCameraMove,
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    bearingvalue = position.bearing; // 2D angle
    longvalue = position.target.longitude; // lat lng
    latvalue = position.target.latitude;
    tiltvalue = position.tilt; // 3D angle
    zoomvalue = 591657550.500000 / pow(2, position.zoom);
  }

  void _onCameraIdle() {
    _handleMapLgMotion();
  }

  void _showCircle() async{
    // await SSH(ref: ref).flyTo( 28.65665656297236, -17.885454520583153, 591657550.500000 / pow(2, 13.15393352508545), 41.82725143432617, 61.403038024902344);
    await SSH(ref: ref).showPolygon();

  }

  Future<void> _handleMapLgMotion() async{
    SSHSession? session = await SSH(ref: ref).motionControls(latvalue, longvalue, zoomvalue / 3, tiltvalue, bearingvalue);
    if (session != null) {
      print(session.stdout);
    }
  }

  List<LatLng> extractCoordinatesFromGeoJson(Map<String, dynamic> geoJson) {
    List<LatLng> points = [];

    if (geoJson.containsKey('type') && geoJson['type'] == 'Feature') {
      Map<String, dynamic>? geometry = geoJson['geometry'];
      if (geometry != null &&
          geometry.containsKey('type') &&
          geometry['type'] == 'LineString') {
        List<dynamic> coords = geometry['coordinates'];
        for (var coord in coords) {
          if (coord is List<dynamic> && coord.length >= 2) {
            double lat = coord[1];
            double lng = coord[0];
            points.add(LatLng(lat, lng));
          }
        }
      }
    }

    return points;
  }
}
