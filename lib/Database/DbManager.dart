import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Components/DistanceFinder.dart';
import 'dart:io';

class DatabaseManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> uploadPost(File image, double latitude, double longitude,
      DateTime uploadTime, int numberOfReports, bool full, String id) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    // generate unique guid, no check for clash, but incredibly unlikely so -_-

    // uploads data into firestore
    return posts
        .doc(id)
        .set({
          'latitude': latitude,
          'longitude': longitude,
          'uploadTime': uploadTime,
          'full': full,
          'numberOfReports': numberOfReports,
          'id': id,
        })
        .then((value) =>
            print("'latitude' & 'longitude' merged with existing data!"))
        .catchError((error) => print("Failed to merge data: $error"));
  }

  Future<dynamic> loadMarkers() async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    List<double> lats = List<double>();
    List<double> longs = List<double>();
    List<String> ids = List<String>();
    List<bool> statuses = List<bool>();
    List<int> listOfReports = List<int>();

    await posts.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double lat = doc["latitude"];
        double long = doc["longitude"];
        String id = doc["id"];
        bool status = doc["full"];
        int numberOfReports = doc['numberOfReports'];
        lats.add(lat);
        longs.add(long);
        ids.add(id);
        statuses.add(status);
        listOfReports.add(numberOfReports);
      });
    });

    return [lats, longs, ids, statuses, listOfReports];
  }

  Future<int> incrementReportCount(String id) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    int initialReports;

    await posts.doc(id).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        print("data: $data");
        initialReports = data['numberOfReports'];

        await posts
            .doc(id)
            .update({'numberOfReports': initialReports + 1})
            .then((value) => print("Number of Reports Updated"))
            .catchError(
                (error) => print("Failed to update Number of Reports: $error"));
      }
    });

    return initialReports + 1;
  }

  // loop through all trash cans in database, find match if below a certain distanceThreshold, break once match is found
  Future<dynamic> getDistanceMatch(double lat, double long) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    bool match = false;
    // distanceThreshold = 50m (0.05km)
    double distanceThreshold = 0.05;
    String postid;

    await posts.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double lat2 = doc["latitude"];
        String id = doc["id"];
        double long2 = doc["longitude"];
        double distance = getDistanceFromLatLonInKm(lat, long, lat2, long2);

        print("distance: $distance");

        if (distance < distanceThreshold) {
          postid = id;
          match = true;
        }
      });
    });

    print("match: $match");

    return [match, postid];
  }
}
