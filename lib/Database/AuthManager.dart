import 'package:firebase_auth/firebase_auth.dart';
import './DbManager.dart';

class AuthManager {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseManager manager = DatabaseManager();

  Future signInWithPhoneNumber(String phoneNumber) async {
    //   ConfirmationResult confirmationResult =
    // await auth.signInWithPhoneNumber("+91 81059 32627");
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91 81059 32627',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int resendToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    // return await confirmationResult.confirm('123123');
  }

  Future<String> login(String email, String password) async {
    try {
      print("Signing in user");
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Successfully signed in user");
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return e.message;
    }
  }
}
