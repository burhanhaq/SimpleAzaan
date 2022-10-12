import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:home_widget/home_widget.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // HomeWidget.setAppGroupId('group.com.simpleAzaan');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    // HomeWidget.saveWidgetData<String>('id', _counter.toString());
    // HomeWidget.updateWidget(
    //   name: 'LockScreenWidgetProvider',
    //   // androidName: 'HomeWidgetExampleProvider',
    //   iOSName: 'LockScreenWidget',
    //   // qualifiedAndroidName: 'com.app.HomeWidgetExampleProvider',
    // );

    WidgetKit.setItem(
      'prayerData',
      jsonEncode(PrayerData(
        // DateTime(2022, 10, 9, 5, 0),
        // DateTime(2022, 10, 9, 7, 15),
        // DateTime(2022, 10, 9, 13, 2, 10),
        // DateTime(2022, 10, 9, 13, 2, 20),
        // DateTime(2022, 10, 9, 13, 2, 30),
        // DateTime(2022, 10, 9, 13, 2, 40),
        DateTime.now().add(Duration(seconds: 10)),
        DateTime.now().add(Duration(seconds: 20)),
        DateTime.now().add(Duration(seconds: 30)),
        DateTime.now().add(Duration(seconds: 40)),
        DateTime.now().add(Duration(seconds: 50)),
        DateTime.now().add(Duration(seconds: 60)),
      )),
      'group.com.simpleAzaan',
    );
    WidgetKit.reloadAllTimelines();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class PrayerData {
  final DateTime time1;
  final DateTime time2;
  final DateTime time3;
  final DateTime time4;
  final DateTime time5;
  final DateTime time6;

  PrayerData(
    this.time1,
    this.time2,
    this.time3,
    this.time4,
    this.time5,
    this.time6,
  );

  PrayerData.fromJson(Map<String, dynamic> json)
      : time1 = json['time1'],
        time2 = json['time2'],
        time3 = json['time3'],
        time4 = json['time4'],
        time5 = json['time5'],
        time6 = json['time6'];

  Map<String, dynamic> toJson() => {
        'time1': time1.toIso8601String(),
        'time2': time2.toIso8601String(),
        'time3': time3.toIso8601String(),
        'time4': time4.toIso8601String(),
        'time5': time5.toIso8601String(),
        'time6': time6.toIso8601String(),
      };
}
