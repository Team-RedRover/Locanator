import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import '../Components/DistanceFinder.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'dart:io';

class DatabaseManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> uploadPost(File image, double latitude, double longitude,
      DateTime uploadTime, int numberOfReports, bool full) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    // generate unique guid, no check for clash, but incredibly unlikely so -_-
    String id = Guid.newGuid.toString();

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

  Future<void> incrementReportCount(String id) async {
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

    // print("reports: $initialReports");
  }

  // loop through all trash cans in database, find match if below a certain distanceThreshold, break once match is found
  Future<dynamic> getDistanceMatch(double lat, double long) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    bool match = false;
    String postid;

    await posts.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        double lat2 = doc["latitude"];
        String id = doc["id"];
        double long2 = doc["longitude"];
        // distanceThreshold = 50m (0.05km)
        double distance = getDistanceFromLatLonInKm(lat, long, lat2, long2);

        print("distance: $distance");

        if (distance < 0.05) {
          postid = id;
          match = true;
        }
      });
    });

    print("match: $match");

    return [match, postid];
  }
}
