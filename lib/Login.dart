import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_chat.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  User currentUser;

  Future<Null> handleSignIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential firebaseUser =
        await firebaseAuth.signInWithCredential(credential);
    User user = firebaseUser.user;
    if (user != null) {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid).get();
      //print(result);
     final List<DocumentSnapshot> documents = result.documents;
     //print(documents);
      if (documents.length == 0) {
        FirebaseFirestore.instance.collection('users').add({
          'nickname': user.displayName,
          'photoUrl': user.photoUrl,
          'id': user.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        });
        FirebaseFirestore.instance.collection('users').document(user.uid).setData({
          'nickname': user.displayName,
          'photoUrl': user.photoUrl,
          'id': user.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        });

        // Write data to local
        currentUser = user;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        //print("income");
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        //await prefs.setString('aboutMe', documents[0]['aboutMe']);
        //print(documents[0]['nickname']);

      }
       Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => Main_chat(),
          ));
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Login_by(
          'images/google.png', "Continue with Google", () => handleSignIn()),
    ));
  }
}

Container Login_by(namefile, text, Function ontab) {
  return Container(
    height: 40,
    child: RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            namefile,
            height: 30,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 17),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      onPressed: ontab,
      color: Colors.indigo,
      textColor: Colors.white,
    ),
    margin: EdgeInsets.symmetric(horizontal: 50),
  );
}
