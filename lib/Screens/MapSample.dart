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
        onPressed: () => onCameraClick(context),
        child: const Icon(Icons.camera_alt),
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  addMarker(
      double lat, double long, String id, String status, int numberOfReports) {
    Marker resultMarker = Marker(
      markerId: MarkerId(id),
      infoWindow: InfoWindow(
          title: status,
          snippet: numberOfReports.toString() + " total reports"),
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
    List<bool> statuses = response[3];
    List<int> listOfReports = response[4];

    setState(() {
      for (var i = 0; i < lats.length; i++) {
        double lat = lats[i];
        double long = longs[i];
        String id = ids[i];
        bool status = statuses[i];
        int numberOfReports = listOfReports[i];
        if (status == true) {
          addMarker(lat, long, id, "Full", numberOfReports);
        } else {
          addMarker(lat, long, id, "Empty", numberOfReports);
        }
      }
    });
  }

  onCameraClick(BuildContext context) async {
    await pickImage();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 60,
              color: Colors.blueGrey,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Full:',
                          style: TextStyle(fontSize: 22.0, color: Colors.white),
                        ),
                        Theme(
                          data: ThemeData(unselectedWidgetColor: Colors.white),
                          child: Checkbox(
                            checkColor: Colors.blueGrey,
                            activeColor: Colors.white,
                            value: this.full,
                            onChanged: (bool value) {
                              print("CHANGED CHECKBOX");
                              setState(() {
                                this.full = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    FlatButton(
                      child: Text("Submit"),
                      height: 30,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      onPressed: () async {
                        Navigator.pop(context);
                        uploadTime = DateTime.now();
                        // Position pos = await determinePosition();
                        // latitude = pos.latitude;
                        // longitude = pos.longitude;
                        latitude = 38.5219993;
                        longitude = -122.184;
                        print("lat: $latitude, long: $longitude");
                        dynamic response = await dbmanager.getDistanceMatch(
                            latitude, longitude);

                        bool match = response[0];
                        String matchId = response[1];

                        if (match) {
                          await dbmanager
                              .incrementReportCount(matchId.toString());
                        } else {
                          String id = Guid.newGuid.toString();
                          if (full == true) {
                            addMarker(latitude, longitude, id, "Full", 1);
                          } else {
                            addMarker(latitude, longitude, id, "Empty", 1);
                          }
                          dbmanager.uploadPost(image, latitude, longitude,
                              uploadTime, 1, full, id);
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
