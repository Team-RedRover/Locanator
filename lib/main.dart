import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './Screens/MapSample.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Locanator());
}

class Locanator extends StatelessWidget {
  final String logo = 'assets/logo.svg';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Locanator',
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () => {},
                child: Icon(
                  Icons.menu,
                  size: 27,
                ),
              ),
            ),
            //   FlatButton(
            //       onPressed: () => {},
            //       child: Text(
            //         "Menu",
            //         style: TextStyle(color: Colors.white, fontSize: 18),
            //       ),
            //       color: Color(0xFF6272a4))
          ],
          title: Row(
            children: [
              SvgPicture.asset(
                logo,
                width: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  "Locanator",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF282a36),
        ),
        body: MapSample(),
      ),
    );
  }
}
