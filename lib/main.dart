import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:home_widget/home_widget.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';

import 'package:simple_azaan/prayer_data.dart';
import 'package:simple_azaan/aladhan_api.dart';
import 'package:simple_azaan/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Azaan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple Azaan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updatePrayerTime();
    getPrayerTimeFromStorage();
  }

  void _updatePrayerTime() {
    AlAdhanApi api = AlAdhanApi();
    Future<dynamic> x = api.getPrayerTimeToday();
    x.then((value) {
      // print(value);
      var pd = PrayerData.fromAlAdhanApi(value);
      // print('time1: ${pd.time1}');
      // print('time2: ${pd.time2}');
      // print('time3: ${pd.time3}');
      // print('time4: ${pd.time4}');
      // print('time5: ${pd.time5}');
      // print('time6: ${pd.time6}');

      // PrayerData prayerData1 = PrayerData(
      //   // DateTime(2022, 10, 9, 5, 0),
      //   // DateTime(2022, 10, 9, 7, 15),
      //   // DateTime(2022, 10, 9, 13, 2, 10),
      //   // DateTime(2022, 10, 9, 13, 2, 20),
      //   // DateTime(2022, 10, 9, 13, 2, 30),
      //   // DateTime(2022, 10, 9, 13, 2, 40),
      //   DateTime.now().add(Duration(seconds: 10)),
      //   DateTime.now().add(Duration(seconds: 20)),
      //   DateTime.now().add(Duration(seconds: 30)),
      //   DateTime.now().add(Duration(seconds: 40)),
      //   DateTime.now().add(Duration(seconds: 50)),
      //   DateTime.now().add(Duration(seconds: 60)),
      // );

      WidgetKit.setItem(
        'prayerData',
        jsonEncode(pd),
        'group.com.simpleAzaan',
      );
      // Shouldn't be required for lock screen widgets
      // WidgetKit.reloadAllTimelines();
    });
    setState(() {
      lastUpdated = DateTime.now();
    });
  }

  PrayerData? pd;
  void getPrayerTimeFromStorage() async {
    Future<dynamic> jsonPrayerData = WidgetKit.getItem(kPrayerKey, kGroup);
    PrayerData pd2 = await jsonPrayerData.then((value) {
      // print(jsonDecode(value));
      return PrayerData.fromJson(jsonDecode(value));
    });
    setState(() {
      pd = pd2;
      // lastUpdated = DateTime.now();
    });
    // return pd;
  }

  // getPrayerTimeFromStorage().then((value) => pd = value);

  @override
  Widget build(BuildContext context) {
    _updatePrayerTime();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Last updated:',
            ),
            Text(
              '$lastUpdated',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Column(
              children: [
                Row(
                  children: [
                    const Text('Fajr'),
                    Text(pd == null ? "" : pd!.getTimeString(pd!.time1)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Sunrise'),
                    Text(pd == null ? "" : pd!.getTimeString(pd!.time2)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Zuhr'),
                    Text(pd == null ? "" : pd!.getTimeString(pd!.time3)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Asr'),
                    Text(pd == null ? "" : pd!.getTimeString(pd!.time4)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Maghrib'),
                    Text(pd == null ? "" : pd!.getTimeString(pd!.time5)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Isha'),
                    Text(pd == null ? "" : pd!.getTimeString(pd!.time6)),
                  ],
                ),
              ],
            ),
            FloatingActionButton(
              onPressed: () {
                _updatePrayerTime();
                getPrayerTimeFromStorage();
              },
              tooltip: 'Update',
              child: const Icon(Icons.update),
            ),
          ],
        ),
      ),
    );
  }
}
