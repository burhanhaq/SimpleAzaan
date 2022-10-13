import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:home_widget/home_widget.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';

import 'package:simple_azaan/prayer_data.dart';
import 'package:simple_azaan/aladhan_api.dart';

void main() {
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
    // HomeWidget.setAppGroupId('group.com.simpleAzaan');
  }

  void _updatePrayerTime() {
    // setState(() {
    //   _counter++;
    // });
    // HomeWidget.saveWidgetData<String>('id', _counter.toString());
    // HomeWidget.updateWidget(
    //   name: 'LockScreenWidgetProvider',
    //   // androidName: 'HomeWidgetExampleProvider',
    //   iOSName: 'LockScreenWidget',
    //   // qualifiedAndroidName: 'com.app.HomeWidgetExampleProvider',
    // );

    AlAdhanApi api = AlAdhanApi();
    Future<dynamic> x = api.getPrayerTimeToday();
    x.then((value) {
      // print(value);
      var pd = PrayerData.fromAlAdhanApi(value);
      print('time1: ${pd.time1}');
      print('time2: ${pd.time2}');
      print('time3: ${pd.time3}');
      print('time4: ${pd.time4}');
      print('time5: ${pd.time5}');
      print('time6: ${pd.time6}');

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
      WidgetKit.reloadAllTimelines();
    });
  }

  @override
  Widget build(BuildContext context) {
    // var data = "No data yet";
    // HomeWidget.getWidgetData<String>('id', defaultValue: 'default')
    //     .then((value) {
    //   print('inside method, right before assigning it');
    //   data = value ?? 'No value found';
    //   print('inside method, right after assigning it. data: $data');
    // });

    // Future<dynamic> x =
    //     WidgetKit.getItem('widgetData', 'group.com.simpleAzaan');
    // x.then(((value) {
    //   print('value: $value');
    // }));
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
              '${DateTime.now()}',
              style: Theme.of(context).textTheme.headline4,
            ),
            FloatingActionButton(
              onPressed: _updatePrayerTime,
              tooltip: 'Update',
              child: const Icon(Icons.update),
            ),
          ],
        ),
      ),
    );
  }
}
