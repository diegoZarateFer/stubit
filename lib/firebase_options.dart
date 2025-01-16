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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAweydQZ6JiyE3VRnE2ClbDXxrXijcj3XY',
    appId: '1:895390332443:android:33d3e82e8b1e0b300caabe',
    messagingSenderId: '895390332443',
    projectId: 'stu-bit',
    databaseURL: 'https://stu-bit-default-rtdb.firebaseio.com',
    storageBucket: 'stu-bit.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALaWzwYzE3exx15BBQIzluOetvU_3_nfU',
    appId: '1:895390332443:ios:02faa3c14de7cf970caabe',
    messagingSenderId: '895390332443',
    projectId: 'stu-bit',
    databaseURL: 'https://stu-bit-default-rtdb.firebaseio.com',
    storageBucket: 'stu-bit.firebasestorage.app',
    iosBundleId: 'com.example.stubit',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBvdUg0u-8-k4IAODDImEIOqCfGMVtP0fw',
    appId: '1:895390332443:web:c227b881a411e3950caabe',
    messagingSenderId: '895390332443',
    projectId: 'stu-bit',
    authDomain: 'stu-bit.firebaseapp.com',
    databaseURL: 'https://stu-bit-default-rtdb.firebaseio.com',
    storageBucket: 'stu-bit.firebasestorage.app',
    measurementId: 'G-W4ERNS3EG5',
  );

}