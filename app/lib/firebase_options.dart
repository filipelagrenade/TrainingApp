/// Firebase configuration options for LiftIQ.
///
/// IMPORTANT: Replace the placeholder values below with your actual Firebase
/// configuration from the Firebase Console.
///
/// To get your configuration:
/// 1. Go to https://console.firebase.google.com/
/// 2. Select your project (or create one)
/// 3. Click the gear icon > Project settings
/// 4. Scroll to "Your apps" and click "Add app" > Flutter
/// 5. Follow the FlutterFire CLI instructions, OR manually copy values below
///
/// Alternatively, run: flutterfire configure
/// This will auto-generate this file with correct values.
library;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for the current platform.
///
/// These values MUST be replaced with your actual Firebase project credentials.
/// The app will show an error if these placeholder values are used.
class DefaultFirebaseOptions {
  /// Returns the Firebase options for the current platform.
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

  /// Whether Firebase has been configured with real credentials.
  ///
  /// Returns false if placeholder values are still in use.
  static bool get isConfigured {
    // Check if the API key is still the placeholder
    return android.apiKey != 'YOUR-ANDROID-API-KEY' &&
        android.apiKey.isNotEmpty;
  }

  // ===========================================================================
  // REPLACE THE VALUES BELOW WITH YOUR FIREBASE CREDENTIALS
  // ===========================================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCKznUGfvaEK6MpOyOKau3NepDCfXc16Ec',
    appId: '1:1056359094939:web:1946e612fedbf0cc3ac43e',
    messagingSenderId: '1056359094939',
    projectId: 'liftiq-app-2ea11',
    authDomain: 'liftiq-app-2ea11.firebaseapp.com',
    storageBucket: 'liftiq-app-2ea11.firebasestorage.app',
  );

  /// Web platform Firebase options.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBunRvkvCGo6otFFaut5hoiDDuvqDXezvo',
    appId: '1:1056359094939:android:d4c95bcf71d626dc3ac43e',
    messagingSenderId: '1056359094939',
    projectId: 'liftiq-app-2ea11',
    storageBucket: 'liftiq-app-2ea11.firebasestorage.app',
  );

  /// Android platform Firebase options.

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAIUcgeu1NMZqwilZj5sItZSpBnSKbBAvw',
    appId: '1:1056359094939:ios:398e1a604822b44a3ac43e',
    messagingSenderId: '1056359094939',
    projectId: 'liftiq-app-2ea11',
    storageBucket: 'liftiq-app-2ea11.firebasestorage.app',
    iosClientId: '1056359094939-abud474q2oarur2uqcl0omepcam4vv14.apps.googleusercontent.com',
    iosBundleId: 'com.example.liftiq',
  );

  /// iOS platform Firebase options.

  /// macOS platform Firebase options.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: 'YOUR-MACOS-APP-ID',
    messagingSenderId: 'YOUR-MESSAGING-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-PROJECT-ID.appspot.com',
    iosBundleId: 'com.liftiq.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCKznUGfvaEK6MpOyOKau3NepDCfXc16Ec',
    appId: '1:1056359094939:web:1c1173e37e9cfc753ac43e',
    messagingSenderId: '1056359094939',
    projectId: 'liftiq-app-2ea11',
    authDomain: 'liftiq-app-2ea11.firebaseapp.com',
    storageBucket: 'liftiq-app-2ea11.firebasestorage.app',
  );

  /// Windows platform Firebase options.
}