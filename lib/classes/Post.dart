import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post({
    this.image,
    this.longitude,
    this.latitude,
    this.uploadTime,
    this.numberOfReports,
    this.full,
  });

  final File image;
  final double latitude;
  final double longitude;
  final Timestamp uploadTime;
  final int numberOfReports;
  final bool full;
}
