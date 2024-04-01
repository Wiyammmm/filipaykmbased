import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'pages/login.dart';
import 'pages/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyDiQYQqP5q3gSpyT1TZnP1jzMdwkC2FF1I',
    appId: '1:890512655620:android:88de65c3cf5538dfbdbc51',
    messagingSenderId: '1422413396640022852',
    projectId: 'filipay-7460a',
    storageBucket: 'filipay-7460a.appspot.com',
  ));
  await Hive.initFlutter();

  final _myBox = await Hive.openBox('myBox');
  initializeData();
  // firebaseRDB();
  runApp(const MyApp());
}

// void firebaseRDB() {
//   print('firebaseRDB()');
//   FirebaseDatabase.instance
//       .ref()
//       .child('filipayqr')
//       .onChildChanged
//       .listen((event) {
//     print('Message changed: ${event.snapshot.value}');
//   });
// }

Future<void> initializeData() async {
  final _myBox = await Hive.box('myBox');
  _myBox.put('server', {"isConnected": false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filipay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
