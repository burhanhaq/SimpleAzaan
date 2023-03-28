// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_widgetkit/flutter_widgetkit.dart';

// import 'package:simple_azaan/prayer_data.dart';
// import 'package:simple_azaan/aladhan_api.dart';
// import 'package:simple_azaan/constants.dart';

// class OldHomePage extends StatefulWidget {
//   const OldHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<OldHomePage> createState() => _OldHomePageState();
// }

// class _OldHomePageState extends State<OldHomePage> {
//   DateTime lastUpdated = DateTime.now();

//   @override
//   void initState() {
//     super.initState();
//     _updatePrayerTime();
//     getPrayerTimeFromStorage();
//   }

//   void _updatePrayerTime() {
//     AlAdhanApi api = AlAdhanApi();
//     Future<dynamic> x = api.getPrayerTimeToday();
//     x.then((value) {
//       var pd = PrayerData.fromAlAdhanApi(value);

//       WidgetKit.setItem(
//         'prayerData',
//         jsonEncode(pd),
//         'group.com.simpleAzaan',
//       );
//       // Shouldn't be required for lock screen widgets
//       // WidgetKit.reloadAllTimelines();
//     });
//     setState(() {
//       lastUpdated = DateTime.now();
//     });
//   }

//   PrayerData? pd;
//   void getPrayerTimeFromStorage() async {
//     Future<dynamic> jsonPrayerData = WidgetKit.getItem(kPrayerKey, kGroup);
//     PrayerData pd2 = await jsonPrayerData.then((value) {
//       return PrayerData.fromJson(jsonDecode(value));
//     });
//     setState(() {
//       pd = pd2;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     _updatePrayerTime();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Last updated:',
//             ),
//             Text(
//               '$lastUpdated',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             Column(
//               children: [
//                 Row(
//                   children: [
//                     const Text('Fajr'),
//                     Text(pd == null ? "" : pd!.getTimeString(pd!.time1)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text('Sunrise'),
//                     Text(pd == null ? "" : pd!.getTimeString(pd!.time2)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text('Zuhr'),
//                     Text(pd == null ? "" : pd!.getTimeString(pd!.time3)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text('Asr'),
//                     Text(pd == null ? "" : pd!.getTimeString(pd!.time4)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text('Maghrib'),
//                     Text(pd == null ? "" : pd!.getTimeString(pd!.time5)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     const Text('Isha'),
//                     Text(pd == null ? "" : pd!.getTimeString(pd!.time6)),
//                   ],
//                 ),
//               ],
//             ),
//             FloatingActionButton(
//               onPressed: () {
//                 _updatePrayerTime();
//                 getPrayerTimeFromStorage();
//               },
//               tooltip: 'Update',
//               child: const Icon(Icons.update),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
