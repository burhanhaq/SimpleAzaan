import 'package:flutter/material.dart';
import 'package:simple_azaan/aladhan_api.dart';
import 'package:simple_azaan/prayer.dart';
import 'package:simple_azaan/prayer_card.dart';
import 'package:simple_azaan/prayer_data.dart';
import 'package:simple_azaan/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Prayer? fajr;
  Prayer? sunrise;
  Prayer? zuhr;
  Prayer? asr;
  Prayer? maghrib;
  Prayer? isha;

  void _updatePrayerTime() {
    AlAdhanApi api = AlAdhanApi(
      city: 'Quakertown',
      state: 'PA',
      country: 'United States',
      method: '2',
    );
    Future<dynamic> x = api.getPrayerTimeToday();
    x.then((value) {
      PrayerData pd = PrayerData.fromAlAdhanApi(value);

      setState(() {
        fajr = Prayer('Fajr', pd.time1);
        sunrise = Prayer('Sunrise', pd.time2);
        zuhr = Prayer('Zuhr', pd.time3);
        asr = Prayer('Asr', pd.time4);
        maghrib = Prayer('Maghrib', pd.time5);
        isha = Prayer('Isha', pd.time6);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _updatePrayerTime();

    var screenSize = MediaQuery.of(context).size;
    var clockDiameter = screenSize.width / 1.3;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xfff6f7f9),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Container(
                  height: clockDiameter,
                  width: clockDiameter,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffffffff),
                  ),
                ),
                const Spacer(),
                Column(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrayerCard(prayer: fajr),
                      PrayerCard(prayer: sunrise),
                      PrayerCard(prayer: zuhr),
                      PrayerCard(prayer: asr),
                      PrayerCard(prayer: maghrib),
                      PrayerCard(prayer: isha),
                    ],
                  ),
                ]),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 0,
          child: SettingsPage(),
        ),
      ],
    );
  }
}
