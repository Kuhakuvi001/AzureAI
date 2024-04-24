import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDjmA-O9EWZ5rXnOkkxgaYjs2CDbycGWGg",
            authDomain: "sampleui-1zh37m.firebaseapp.com",
            projectId: "sampleui-1zh37m",
            storageBucket: "sampleui-1zh37m.appspot.com",
            messagingSenderId: "332626720164",
            appId: "1:332626720164:web:220ba29b6b71e92b733d31"));
  } else {
    await Firebase.initializeApp();
  }
}
