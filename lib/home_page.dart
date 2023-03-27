import 'package:flutter/material.dart';
import 'package:simple_azaan/aladhan_api.dart';
import 'package:simple_azaan/prayer.dart';
import 'package:simple_azaan/prayer_card.dart';
import 'package:simple_azaan/prayer_data.dart';

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
    var clockDiameter = screenSize.width / 1.5;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.red,
          ),
        ),
        Expanded(
          flex: 100,
          child: Container(
            color: Colors.yellow,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: clockDiameter,
                    width: clockDiameter,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    child: Column(children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PrayerCard(
                            prayer: fajr ??
                                Prayer('Fajr',
                                    DateTime.parse('2020-03-25 00:00:00')),
                          ),
                          PrayerCard(
                            prayer: sunrise ??
                                Prayer('Sunrise',
                                    DateTime.parse('2020-03-25 00:00:00')),
                          ),
                          PrayerCard(
                            prayer: zuhr ??
                                Prayer('Zuhr',
                                    DateTime.parse('2020-03-25 00:00:00')),
                          ),
                          PrayerCard(
                            prayer: asr ??
                                Prayer('Asr',
                                    DateTime.parse('2020-03-25 00:00:00')),
                          ),
                          PrayerCard(
                            prayer: maghrib ??
                                Prayer('Maghrib',
                                    DateTime.parse('2020-03-25 00:00:00')),
                          ),
                          PrayerCard(
                            prayer: isha ??
                                Prayer('Isha',
                                    DateTime.parse('2020-03-25 00:00:00')),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
