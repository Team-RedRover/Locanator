import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Components/DistanceFinder.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'dart:io';

class DatabaseManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    File image,
    double latitude,
    double longitude,
    DateTime uploadTime,
    int numberOfReports,
    bool full,
    String id,
    List<String> deviceIds,
    String deviceId,
  ) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    // generate unique guid, no check for clash, but incredibly unlikely so -_-

    posts
        .doc(id)
        .set({
          'latitude': latitude,
          'longitude': longitude,
          'uploadTime': uploadTime,
          'full': full,
          'numberOfReports': numberOfReports,
          'id': id,
          'deviceIds': deviceIds
        })
        .then((value) =>
            print("'latitude' & 'longitude' merged with existing data!"))
        .catchError((error) => print("Failed to merge data: $error"));

    String url;
    String path = 'Images/$id/$deviceId';
    try {
      await firebase_storage.FirebaseStorage.instance.ref(path).putFile(image);
      print("Successfully added media files");
      url = await getDownloadUrl(path);
    } on firebase_core.FirebaseException catch (e) {
      print("Error upload files: ${e.message}");
    }

    return url;
  }

  Future<String> getImageUrls(String id) async {
    firebase_storage.ListResult result = await firebase_storage
        .FirebaseStorage.instance
        .ref("/Images/$id")
        .listAll();

    print("result: ${result.items}");

    return await result.items[0].getDownloadURL();
  }

  Future<String> getDownloadUrl(String path) async {
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(path)
        .getDownloadURL();
    return downloadURL;
  }

  Future<dynamic> loadMarkers() async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    print("Loading markers");

    List<double> lats = [];
    List<double> longs = [];
    List<String> ids = [];
    List<bool> statuses = [];
    List<int> listOfReports = [];
    // List<String> deviceIds = [];

    await posts.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print("doc: $doc");
        double lat = doc["latitude"];
        double long = doc["longitude"];
        String id = doc["id"];
        bool status = doc["full"];
        int numberOfReports = doc['numberOfReports'];
        // String deviceId = doc["deviceId"];
        lats.add(lat);
        longs.add(long);
        ids.add(id);
        statuses.add(status);
        listOfReports.add(numberOfReports);
        // deviceIds.add(deviceId);
      });
    });

    print("lats: $lats");

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

  Future<bool> verifyDeviceId(String deviceId, String id) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    List<String> deviceIds = [];

    await posts.doc(id).get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        dynamic data = documentSnapshot.data();
        deviceIds = data['deviceIds'];

        print("deviceIds: $deviceIds");
        print("deviceId: $deviceId");

        if (deviceIds.contains(deviceId)) {
          return false;
        } else {
          deviceIds.add(deviceId);
          await posts
              .doc(id)
              .update({'deviceIds': deviceIds})
              .then((value) => print("Number of deviceIds Updated"))
              .catchError((error) =>
                  print("Failed to update Number of deviceIds: $error"));
          return true;
        }
      }
    });

    if (deviceIds.length == 1) {
      return true;
    } else {
      return false;
    }
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

  Future markAsEmpty(String id) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    return await posts
        .doc(id)
        .update({'full': false})
        .then((value) => print("Number of Reports Updated"))
        .catchError(
            (error) => print("Failed to update Number of Reports: $error"));
  }
}
