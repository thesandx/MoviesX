import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/views/home/HomePage.dart';
import 'package:movie_app/views/login/login_otp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoviesX',
      theme: ThemeData(
          fontFamily: 'Nunito', scaffoldBackgroundColor: const Color(0xF3f5f7)),
      home: LoginOtp(),
      debugShowCheckedModeBanner: false,
    );
  }
}
