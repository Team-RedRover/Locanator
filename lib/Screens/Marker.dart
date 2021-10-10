import 'package:flutter/material.dart';
import 'package:locanator/Database/DbManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerScreen extends StatefulWidget {
  MarkerScreen({Key key}) : super(key: key);

  @override
  _MarkerScreenState createState() => _MarkerScreenState();
}

class _MarkerScreenState extends State<MarkerScreen> {
  DatabaseManager dbmanager = DatabaseManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282a36),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
        actions: <Widget>[],
        title: Text(
          "Trash Can",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFF282a36),
      ),
      body: new StreamBuilder(
        stream: FirebaseFirestore.instance.collection("posts").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              'No Data...',
            );
          } else {
            // DocumentSnapshot items = snapshot.data.documents;

            return new Container();
          }
        },
      ),
    );
  }
}
