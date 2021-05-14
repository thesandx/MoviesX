import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:movie_app/views/SplashScreen.dart';
import 'package:movie_app/views/home/HomePage.dart';
import 'package:movie_app/views/login/login_otp.dart';
import 'package:flutter/services.dart';


createLogger() {
  Logger.root.level = Level.ALL;

  LogzIoApiAppender(
    apiToken: "ObLFoumDvIXWrKrQIHUIUAtjcqryiCxU",
    url: "https://listener.logz.io:8071/",
    labels: {
      "version": "1.0.0", // dynamically later on
      "build": "2" // dynamically later on
    },
  )..attachToLogger(Logger.root);
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  createLogger();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoviesX',
      theme: ThemeData(
          fontFamily: 'Nunito'),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
