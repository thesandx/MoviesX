import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/login/login_otp.dart';

import 'home/HomePage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initialize(BuildContext context) {
    Firebase.initializeApp().whenComplete(() {
      print("firebase initialization completed");
      User user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print(user.phoneNumber);
        CommonData.retriveAPIKey().then((value) async{

          if (value) {
            //print(CommonData.tmdb_api_key);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user)),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginOtp()),
              (route) => false,
            );
          }
        });
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginOtp()),
          (route) => false,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Future.delayed(Duration(seconds: 3)).then((value) => initialize(context));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MoviesX",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.w800),
              ),
              Lottie.asset(
                "assets/jsons/splash.json",
                alignment: Alignment.bottomCenter,
              ),
            ],
          ),
        ));
  }
}
