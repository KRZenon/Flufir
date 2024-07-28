// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBrCdRAHahHX__xsrSoNehBX-hsZ2Nui_M',
    appId: '1:417478185482:web:485f712c7e4388bd4045f3',
    messagingSenderId: '417478185482',
    projectId: 'travelapp-98c84',
    authDomain: 'travelapp-98c84.firebaseapp.com',
    storageBucket: 'travelapp-98c84.appspot.com',
    measurementId: 'G-X13NQ0T25X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPKlNlYXH1ux1oIpoGPHj-ABt3ctP0USk',
    appId: '1:417478185482:android:a7a81579382e6e3b4045f3',
    messagingSenderId: '417478185482',
    projectId: 'travelapp-98c84',
    storageBucket: 'travelapp-98c84.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAMEuTDqTEuKF0Mvx4OoqkMkgqdZM7QJTk',
    appId: '1:417478185482:ios:982ee3a457c7046c4045f3',
    messagingSenderId: '417478185482',
    projectId: 'travelapp-98c84',
    storageBucket: 'travelapp-98c84.appspot.com',
    iosBundleId: 'com.example.flufir',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAMEuTDqTEuKF0Mvx4OoqkMkgqdZM7QJTk',
    appId: '1:417478185482:ios:982ee3a457c7046c4045f3',
    messagingSenderId: '417478185482',
    projectId: 'travelapp-98c84',
    storageBucket: 'travelapp-98c84.appspot.com',
    iosBundleId: 'com.example.flufir',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBrCdRAHahHX__xsrSoNehBX-hsZ2Nui_M',
    appId: '1:417478185482:web:e8fca8d45b3b79b34045f3',
    messagingSenderId: '417478185482',
    projectId: 'travelapp-98c84',
    authDomain: 'travelapp-98c84.firebaseapp.com',
    storageBucket: 'travelapp-98c84.appspot.com',
    measurementId: 'G-DMP0BJ13GH',
  );

}