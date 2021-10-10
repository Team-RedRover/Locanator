import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:locanator/Components/DistanceFinder.dart';
import 'package:locanator/Screens/Marker.dart';
import '../Database/DbManager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:device_info/device_info.dart';
import './.env.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Set<Marker> markers = Set();
  double currentZoom = 10.0;
  Position _currentPosition;
  double _placeDistance;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.4219983, -122.084),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    loadMarkers();
  }

  GoogleMapController mapController;
  List<LatLng> polylineCoordinates = [];
  List<Polyline> _polylines = [];
  PolylinePoints polylinePoints = PolylinePoints();

  DatabaseManager dbmanager = DatabaseManager();
  final picker = ImagePicker();
  File image;
  DateTime uploadTime;
  double latitude;
  double longitude;
  String id;
  bool full = false;
  List<String> deviceIds;

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            polylines: Set<Polyline>.of(_polylines),
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
            myLocationEnabled: true,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _placeDistance == null ? false : true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                        color: Color(0xFF282a36),
                      ),
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'DISTANCE: ${_placeDistance != null ? _placeDistance.toStringAsFixed(2) : "0"} km',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onCameraClick(context),
        child: const Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF282a36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  getCurrentLocation() async {
    print("Getting current locations");
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    setState(() {
      _polylines.clear();
      polylineCoordinates.clear();
    });

    print(
        "startLan: $startLatitude \nstartLon: $startLongitude \ndestLan: $destinationLatitude \ndestLon: $destinationLongitude");

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.walking,
    );

    // print("result: ${result.points}");

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      // print("result points: ${result.points}");
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    print("coordinates: $polylineCoordinates");

    // Defining an ID
    PolylineId polyId = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: polyId,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    setState(() {
      _polylines.add(polyline);
      print("polyline set: ${_polylines.length}");
    });

    // Calculating to check that the position relative
    // to the frame, and pan & zoom the camera accordingly.
    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    // Accommodate the two locations within the
    // camera view of the map
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );
  }

  addMarker(double lat, double long, String id, String status,
      int numberOfReports, bool load) {
    double hue = 0;
    if (status == "Empty") {
      hue = 90;
    }
    Marker resultMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        markerId: MarkerId(id),
        infoWindow: InfoWindow(
            title: status,
            snippet: numberOfReports.toString() + " total reports"),
        position: LatLng(lat, long),
        onTap: () {
          var currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser != null) {
            print("User is signed in: ${currentUser.uid}");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MarkerScreen(
                          markerId: id,
                        )));

            createPolylines(_currentPosition.latitude,
                _currentPosition.longitude, lat, long);
            _placeDistance = getDistanceFromLatLonInKm(
                _currentPosition.latitude,
                _currentPosition.longitude,
                lat,
                long);
          } else {
            print("User is signed out");
            createPolylines(_currentPosition.latitude,
                _currentPosition.longitude, lat, long);
            _placeDistance = getDistanceFromLatLonInKm(
                _currentPosition.latitude,
                _currentPosition.longitude,
                lat,
                long);
          }
        });
    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              lat,
              long,
            ),
            zoom: 10.0,
          ),
        ),
      );
    }

    if (!load) {
      createPolylines(
          _currentPosition.latitude, _currentPosition.longitude, lat, long);
      _placeDistance = getDistanceFromLatLonInKm(
          _currentPosition.latitude, _currentPosition.longitude, lat, long);
    }

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
          addMarker(lat, long, id, "Full", numberOfReports, true);
        } else {
          addMarker(lat, long, id, "Empty", numberOfReports, true);
        }
      }
      // createPolylines(lats[0], longs[0], lats[1], longs[1]);
    });
  }

  static Future<String> getIdentifier() async {
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        identifier = build.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        identifier = data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }

    return identifier;
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
              color: Color(0xFF282a36),
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
                            checkColor: Color(0xFF282a36),
                            activeColor: Colors.white,
                            value: this.full,
                            onChanged: (bool value) {
                              // print("CHANGED CHECKBOX");
                              setState(() {
                                this.full = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Color(0xFF282a36),
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        uploadTime = DateTime.now();
                        // latitude = 37.4219983;
                        // longitude = -122.100;
                        latitude = 37.4119983;
                        longitude = -122.100;
                        // latitude = 37.4119983;
                        // longitude = -122.08;
                        print("lat: $latitude, long: $longitude");
                        dynamic response = await dbmanager.getDistanceMatch(
                            latitude, longitude);

                        bool match = response[0];
                        String matchId = response[1];

                        if (match) {
                          String deviceId = await getIdentifier();
                          print("deviceID: $deviceId");

                          bool verified = await dbmanager.verifyDeviceId(
                              deviceId, matchId.toString());
                          if (verified) {
                            int newReports = await dbmanager
                                .incrementReportCount(matchId.toString());
                            // if (!mounted) return;
                            Marker mark = markers.firstWhere(
                                (marker) => marker.markerId.value == matchId);
                            print("Deleting mark");
                            markers.remove(mark);
                            addMarker(
                                mark.position.latitude,
                                mark.position.longitude,
                                matchId,
                                mark.infoWindow.title,
                                newReports,
                                false);
                          } else {
                            return AlertDialog(
                                title: Text("Sample Alert Dialog"));
                          }
                        } else {
                          String id = Guid.newGuid.toString();
                          String deviceId = await getIdentifier();

                          List<String> deviceIds = [deviceId];

                          print("deviceID: $deviceId");

                          if (full == true) {
                            addMarker(
                                latitude, longitude, id, "Full", 1, false);
                          } else {
                            addMarker(
                                latitude, longitude, id, "Empty", 1, false);
                          }
                          dbmanager.uploadPost(image, latitude, longitude,
                              uploadTime, 1, full, id, deviceIds);
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
