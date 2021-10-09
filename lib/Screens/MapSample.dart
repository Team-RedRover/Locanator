import 'dart:async';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../Database/DbManager.dart';
import '../Components/LocationFinder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_guid/flutter_guid.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  LatLng currentPosition;
  Set<Marker> markers = Set();
  double currentZoom = 10.0;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.4219983, -122.084),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  DatabaseManager dbmanager = DatabaseManager();
  final picker = ImagePicker();
  File image;
  DateTime uploadTime;
  double latitude;
  double longitude;
  String id;
  bool full = false;

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCameraClick,
        child: const Icon(Icons.camera_alt),
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  addMarker(double lat, double long, String id) {
    Marker resultMarker = Marker(
      markerId: MarkerId(id),
      infoWindow: InfoWindow(title: "Available Trash Can"),
      position: LatLng(lat, long),
    );
// Add it to Set
    setState(() {
      markers.add(resultMarker);
      print("markers: $markers");
    });
  }

  loadMarkers() async {
    dynamic response = await dbmanager.loadMarkers();
    List<double> lats = response[0];
    List<double> longs = response[1];
    List<String> ids = response[2];

    setState(() {
      for (var i = 0; i < lats.length; i++) {
        double lat = lats[i];
        double long = longs[i];
        String id = ids[i];
        addMarker(lat, long, id);
      }
    });
  }

  onCameraClick() async {
    await pickImage();
    uploadTime = DateTime.now();
    // Position pos = await determinePosition();
    // latitude = pos.latitude;
    // longitude = pos.longitude;
    latitude = 37.5219983;
    longitude = -122.184;
    print("lat: $latitude, long: $longitude");
    dynamic response = await dbmanager.getDistanceMatch(latitude, longitude);

    bool match = response[0];
    String matchId = response[1];

    if (match) {
      dbmanager
          .incrementReportCount(matchId)
          .toString()
          .toLowerCase()
          .trim()
          .replaceAll("-", "dash")
          .replaceAll(".", "dot")
          .replaceAll(":", "colon");
    } else {
      String id = Guid.newGuid
          .toString()
          .toLowerCase()
          .trim()
          .replaceAll("-", "dash")
          .replaceAll(".", "dot")
          .replaceAll(":", "colon");
      addMarker(latitude, longitude, id);
      dbmanager.uploadPost(image, latitude, longitude, uploadTime, 1, full, id);
    }
  }
}
