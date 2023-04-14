import 'package:flutter/material.dart';

import 'package:simple_azaan/archive/home_screen.dart';
import 'package:simple_azaan/screens/home/home_screen_2.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Simple Azaan',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen2(),
      ),
    );
  }
}
