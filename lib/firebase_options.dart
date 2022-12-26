// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7fCe2iy73YTouONZFazPaCUu5gmwOWn4',
    appId: '1:716896267310:web:80dc3db7809bf1f09e43bf',
    messagingSenderId: '716896267310',
    projectId: 'moviesx-463cf',
    authDomain: 'moviesx-463cf.firebaseapp.com',
    storageBucket: 'moviesx-463cf.appspot.com',
    measurementId: 'G-RDSPH5VB4Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuMuvqNyaR-F1KvnMx_8NW-ODb_jI611A',
    appId: '1:716896267310:android:a0508480849da1e99e43bf',
    messagingSenderId: '716896267310',
    projectId: 'moviesx-463cf',
    storageBucket: 'moviesx-463cf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBq50j_uQuuVdhFrb39DJCjJfHYuTV6ZG8',
    appId: '1:716896267310:ios:62ea1c4cfcf2eb1e9e43bf',
    messagingSenderId: '716896267310',
    projectId: 'moviesx-463cf',
    storageBucket: 'moviesx-463cf.appspot.com',
    androidClientId: '716896267310-58f4te53jncfhkgmnfvrgd90foepvsr1.apps.googleusercontent.com',
    iosClientId: '716896267310-id86kst94de7stn6ed2ahudo3rov1msa.apps.googleusercontent.com',
    iosBundleId: 'com.thesandx.movieApp',
  );
}