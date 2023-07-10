import 'package:flutter/material.dart';
import 'home_page.dart';
import "package:firebase_core/firebase_core.dart";

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDu3TxiFemxsoArePMbtHiSLKi0H0j0-4c",
          authDomain: "joeblake-a0a68.firebaseapp.com",
          projectId: "joeblake-a0a68",
          storageBucket: "joeblake-a0a68.appspot.com",
          messagingSenderId: "684393228079",
          appId: "1:684393228079:web:d7089001904b367ac063da",
          measurementId: "G-B51WBW632G"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
