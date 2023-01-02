import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/firebase_options.dart';
import 'package:movie_app/views/SplashScreen.dart';
import 'package:movie_app/views/home/HomePage.dart';
import 'package:movie_app/views/login/login_otp.dart';
import 'package:flutter/services.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

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
