import 'package:flutter/material.dart';
import 'package:locanator/Database/DbManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerScreen extends StatefulWidget {
  final String markerId;

  MarkerScreen({Key key, this.markerId}) : super(key: key);

  @override
  _MarkerScreenState createState() => _MarkerScreenState();
}

class _MarkerScreenState extends State<MarkerScreen> {
  DatabaseManager dbmanager = DatabaseManager();
  String imageUrl =
      "https://firebasestorage.googleapis.com/v0/b/locanator-71ddd.appspot.com/o/Images%2F3d52c965-c15d-4b73-9aaf-b40530aa8c7e%2F05953ffc682255e0?alt=media&token=df04aebe-c12a-47b9-9ed5-e5438560e945";

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
        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              'No Data...',
            );
          } else {
            dynamic items = snapshot.data.docs;

            print("MarkerId: ${widget.markerId}");

            for (var i = 0; i < items.length; i++) {
              DocumentSnapshot doc = items[i];
              if (doc.id == widget.markerId) {
                print("document: ${doc.id}");
                String status = "Empty";
                if (doc["full"] == true) {
                  status = "Full";
                }
                return Center(
                  child: SingleChildScrollView(
                    child: new Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.report, color: Colors.white),
                                  Text(
                                    " Reports: ${doc["numberOfReports"]}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.checklist, color: Colors.white),
                                  Text(
                                    " Status: $status",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: TextButton(
                                      style: ButtonStyle(
                                        alignment: Alignment.center,
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blueGrey),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await dbmanager
                                            .markAsEmpty(widget.markerId);
                                      },
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.refresh,
                                              color: Color(0xFF282a36)),
                                          Text(
                                            " Mark as empty",
                                            style: TextStyle(
                                              color: Color(0xFF282a36),
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Images",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 24),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.network(imageUrl),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }
}
