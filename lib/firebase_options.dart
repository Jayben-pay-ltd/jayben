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
    apiKey: 'AIzaSyBtdSZXNUBz-mihRv570xrJzafkh7Vz_Do',
    appId: '1:188049715261:web:7061fbdf3d8d92c6f67a54',
    messagingSenderId: '188049715261',
    projectId: 'jayben-de41c',
    authDomain: 'jayben-de41c.firebaseapp.com',
    storageBucket: 'jayben-de41c.appspot.com',
    measurementId: 'G-8DLH1T803K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXCaxBSM96zteh0W00nt_7AgvJJN-_z80',
    appId: '1:188049715261:android:30a52603542b2894f67a54',
    messagingSenderId: '188049715261',
    projectId: 'jayben-de41c',
    storageBucket: 'jayben-de41c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5zT20dWnCZEpJJJMr3O13gBfhI2XBbN8',
    appId: '1:188049715261:ios:eafa8d4f64b3ad73f67a54',
    messagingSenderId: '188049715261',
    projectId: 'jayben-de41c',
    storageBucket: 'jayben-de41c.appspot.com',
    androidClientId: '188049715261-2g1eeu8vmtggofu517tm6uolvt20avpn.apps.googleusercontent.com',
    iosClientId: '188049715261-9rlilg2f8dfh5enupf1j0jv2oun17c03.apps.googleusercontent.com',
    iosBundleId: 'com.jayben.ios.app',
  );
}
