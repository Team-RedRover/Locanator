import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../classes/Post.dart';
import '../Components/LocationFinder.dart';
import 'package:image_picker/image_picker.dart';
import '../Components/DistanceFinder.dart';
import '../Database/DbManager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// TODO: admin panel, admin login, ML image analysis, statistics, user backend ratings, optional user login, pathfinder maps, complaints

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseManager dbmanager = DatabaseManager();
  final picker = ImagePicker();
  File image;
  DateTime uploadTime;
  double latitude;
  double longitude;
  String id;
  bool full = false;

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
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                shape: MaterialStateProperty.all(CircleBorder()),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () async {
                await pickImage();
                uploadTime = DateTime.now();
                Position pos = await determinePosition();
                latitude = pos.latitude;
                longitude = pos.longitude;
                print("lat: $latitude, long: $longitude");
                dynamic response =
                    await dbmanager.getDistanceMatch(latitude, longitude);

                print("response: $response");

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
                  id = DateTime.now()
                      .toString()
                      .toLowerCase()
                      .trim()
                      .replaceAll("-", "dash")
                      .replaceAll(".", "dot")
                      .replaceAll(":", "colon");
                  dbmanager.uploadPost(
                      image, latitude, longitude, uploadTime, 1, full, "");
                }
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ), //SizedBox
                Text(
                  'Full: ',
                  style: TextStyle(fontSize: 17.0),
                ), //Text
                SizedBox(width: 10), //SizedBox
                /** Checkbox Widget **/
                Checkbox(
                  value: this.full,
                  onChanged: (bool value) {
                    setState(() {
                      this.full = value;
                    });
                  },
                ), //Checkbox
              ], //<Widget>[]
            ),
            image != null ? Image.file(image) : Text("")
          ],
        ),
      ),
    );
  }
}
