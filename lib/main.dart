import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './Screens/MapSample.dart';
import './Screens/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Locanator',
    home: Locanator(),
  ));
}

class Locanator extends StatefulWidget {
  @override
  _LocanatorState createState() => _LocanatorState();
}

class _LocanatorState extends State<Locanator> {
  final String logo = 'assets/logo.svg';
  bool dropdownVisibility = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
            },
            child: Text(
              "Login",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          PopupMenuButton<String>(
            color: Color(0xFF44475a),
            icon: Icon(
              Icons.menu,
              size: 27,
            ),
            onSelected: (String result) async {
              if (result == "Logout") {
                await FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Help', 'Report', 'Settings', 'Logout'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      choice == "Help"
                          ? Icon(Icons.help, color: Colors.white)
                          : choice == "Settings"
                              ? Icon(Icons.settings, color: Colors.white)
                              : choice == "Report"
                                  ? Icon(Icons.report, color: Colors.white)
                                  : Icon(Icons.logout, color: Colors.white),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        choice,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
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
    );
  }
}

// class Locanator extends StatelessWidget {
//   final String logo = 'assets/logo.svg';
//   final bool dropdownVisibility = false;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Locanator',
//       home: Scaffold(
//         appBar: AppBar(
//           toolbarHeight: 70,
//           automaticallyImplyLeading: false,
//           actions: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(right: 20),
//               child: GestureDetector(
//                 onTap: () => {},
//                 child: Icon(
//                   Icons.menu,
//                   size: 27,
//                 ),
//               ),
//             ),
//             Visibility(
//                 visible: dropdownVisibility,
//                 child: DropdownButton<String>(
//                   items: <String>['A', 'B', 'C', 'D'].map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (_) {},
//                 ))
//           ],
//           title: Row(
//             children: [
//               SvgPicture.asset(
//                 logo,
//                 width: 50,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 12),
//                 child: Text(
//                   "Locanator",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w400,
//                     fontSize: 24,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Color(0xFF282a36),
//         ),
//         body: MapSample(),
//       ),
//     );
//   }
// }
