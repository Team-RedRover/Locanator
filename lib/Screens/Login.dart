import 'package:locanator/Screens/MapSample.dart';

import '../Database/AuthManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  String email;
  String password;
  FirebaseAuth auth = FirebaseAuth.instance;
  String errorMessage = 'Unknown Error';
  bool errorVisible = false;
  final String logo = 'assets/logo.svg';

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
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFF282a36),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  logo,
                  width: 150,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Text(
                    'Locanator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: SizedBox(
                    width: 325,
                    height: 50,
                    child: TextField(
                      onChanged: (newText) {
                        setState(() {
                          email = newText;
                          print('Email is changed to => $email');
                        });
                      },
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Karla-Medium',
                      ),
                      obscureText: false,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        hintText: 'Email address',
                        hintStyle: TextStyle(
                          fontFamily: 'Karla-Medium',
                          color: Colors.grey,
                        ),
                        fillColor: Color(0xFF4b4266),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6272a4),
                            width: 3.5,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6272a4),
                            width: 3.5,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6272a4),
                            width: 3.5,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: SizedBox(
                    width: 325,
                    height: 50,
                    child: TextField(
                      onChanged: (newText) {
                        setState(() {
                          password = newText;
                          print('Password is changed to => $password');
                        });
                      },
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Karla-Medium',
                      ),
                      obscureText: true,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          fontFamily: 'Karla-Medium',
                          color: Colors.grey,
                        ),
                        fillColor: Color(0xFF4b4266),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6272a4),
                            width: 3.5,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6272a4),
                            width: 3.5,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF6272a4),
                            width: 3.5,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        AuthManager manager = AuthManager();
                        String status = await manager.login(
                          email,
                          password,
                        );
                        print("Status: $status");
                        if (status == 'Success') {
                          print("Success");
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => MapSample(),
                          //   ),
                          // );
                          Navigator.pop(context);
                        } else {
                          print("Error is $status");
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF6272a4)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
