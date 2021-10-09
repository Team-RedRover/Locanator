import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'dart:io';

class DatabaseManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getReports(File image, double latitude, double longitude,
      DateTime uploadTime, int numberOfReports, bool full, String id) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    // uploads data into firestore
    return posts
        .doc(id)
        .set({
          'latitude': latitude,
          'longitude': longitude,
          'uploadTime': uploadTime,
          'full': full,
          'id': id
        })
        .then((value) =>
            print("'latitude' & 'longitude' merged with existing data!"))
        .catchError((error) => print("Failed to merge data: $error"));
  }
}
