import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/views/login/login_otp.dart';

import 'home/HomePage.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("firebase initialization completed");
      User user = FirebaseAuth.instance.currentUser;
      if(user!=null){
        print(user.phoneNumber);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(user)),
          (route) => false,
        );
      }
      else{
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => LoginOtp()),
              (route) => false,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    Size size  = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Center(
          child: Column(
            children: [
              Text("MoviesX",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w800
                ),
              ),
              Lottie.asset(
                "assets/jsons/splash.json",
                alignment: Alignment.bottomCenter,
              ),
            ],
          ),
        ),
      )

    );
  }
}
