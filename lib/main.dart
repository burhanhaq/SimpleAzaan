import 'package:flutter/material.dart';

import 'package:simple_azaan/screens/home/home_screen_2.dart';
import 'package:simple_azaan/service/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize iOS local notifications and request permissions
  await NotificationService().init();
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
