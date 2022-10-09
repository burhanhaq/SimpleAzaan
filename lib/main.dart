import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
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
    HomeWidget.setAppGroupId('group.com.simpleAzaan');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    HomeWidget.saveWidgetData<String>('id', _counter.toString());
    HomeWidget.updateWidget(
      name: 'LockScreenWidgetProvider',
      // androidName: 'HomeWidgetExampleProvider',
      iOSName: 'LockScreenWidget',
      // qualifiedAndroidName: 'com.app.HomeWidgetExampleProvider',
    );

    WidgetKit.setItem(
        'widgetData',
        jsonEncode(FlutterWidgetData(_counter.toString())),
        'group.com.simpleAzaan');
    WidgetKit.reloadAllTimelines();
  }

  @override
  Widget build(BuildContext context) {
    var data = "No data yet";
    HomeWidget.getWidgetData<String>('id', defaultValue: 'default')
        .then((value) {
      print('inside method, right before assigning it');
      data = value ?? 'No value found';
      print('inside method, right after assigning it. data: $data');
    });
    print('data: $data');

    Future<dynamic> x =
        WidgetKit.getItem('widgetData', 'group.com.simpleAzaan');
    x.then(((value) {
      print('value: $value');
    }));
    print('x: $x');
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

class FlutterWidgetData {
  final String text;

  FlutterWidgetData(this.text);

  FlutterWidgetData.fromJson(Map<String, dynamic> json) : text = json['text'];

  Map<String, dynamic> toJson() => {
        'text': text,
      };
}
