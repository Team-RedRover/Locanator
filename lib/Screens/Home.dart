import 'dart:io';

import 'package:flutter/material.dart';
import '../classes/Post.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final picker = ImagePicker();
  File image;
  DateTime uploadTime;

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override // optional bro
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              color: Colors.green,
              child: Text(
                'Take an image!',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await pickImage();
                uploadTime = DateTime.now();
              },
            ),
            image != null ? Image.file(image) : Text("Image not picked yet")
          ],
        ),
      ),
    );
  }
}
