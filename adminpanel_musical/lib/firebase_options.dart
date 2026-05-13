import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  // ✅ CONFIGURACIÓN WEB CORREGIDA
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBFs54dtfmUaOTtAB4jBdBURcBzyQUZAls',
    appId: '1:381382176380:web:2195c4c8e2609da38d23f9',
    messagingSenderId: '381382176380',
    projectId: 'hsound-8aad2',
    authDomain: 'hsound-8aad2.firebaseapp.com',
    storageBucket: 'hsound-8aad2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFs54dtfmUaOTtAB4jBdBURcBzyQUZAls',
    appId: '1:381382176380:android:155ac2c8c6ec30b28d23f9',
    messagingSenderId: '381382176380',
    projectId: 'hsound-8aad2',
    storageBucket: 'hsound-8aad2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYAc0i5iuidE8kRRQagMxNZXFyAtcGEjI',
    appId: '1:381382176380:ios:246d154d7632e31a8d23f9',
    messagingSenderId: '381382176380',
    projectId: 'hsound-8aad2',
    storageBucket: 'hsound-8aad2.firebasestorage.app',
    iosClientId: '381382176380-7gdlb6egui2li8l39kfpajnq6reop0to.apps.googleusercontent.com',
    iosBundleId: 'com.example.hsound',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYAc0i5iuidE8kRRQagMxNZXFyAtcGEjI',
    appId: '1:381382176380:ios:246d154d7632e31a8d23f9',
    messagingSenderId: '381382176380',
    projectId: 'hsound-8aad2',
    storageBucket: 'hsound-8aad2.firebasestorage.app',
    iosClientId: '381382176380-7gdlb6egui2li8l39kfpajnq6reop0to.apps.googleusercontent.com',
    iosBundleId: 'com.example.hsound',
  );
}