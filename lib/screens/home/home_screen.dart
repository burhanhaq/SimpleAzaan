import 'package:flutter/material.dart';
import 'package:simple_azaan/api/aladhan_api.dart';
import 'package:simple_azaan/widgets/clock_dial_widget.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/widgets/prayer_card.dart';
import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  _getPrayerCards() {
    List<Prayer?> listOfPrayers = [fajr, sunrise, zuhr, asr, maghrib, isha];
    int currentPrayerIndex = listOfPrayers.indexWhere(
      (element) => element?.hasPrayerPassed == false,
    );

    // TODO: Sets Isha time if -1. Needs to be fixed.
    if (currentPrayerIndex == -1) {
      listOfPrayers[listOfPrayers.length - 1]?.isCurrentPrayer = true;
    } else if (currentPrayerIndex == 0) {
      listOfPrayers[listOfPrayers.length - 1]?.isCurrentPrayer = true;
    } else if (currentPrayerIndex > 0 &&
        currentPrayerIndex <= listOfPrayers.length + 1) {
      --currentPrayerIndex;
      listOfPrayers[currentPrayerIndex]?.isCurrentPrayer = true;
    }

    return List.generate(listOfPrayers.length, (index) {
      return PrayerCard(prayer: listOfPrayers[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    _updatePrayerTime();

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
                ClockDial(),
                const Spacer(),
                Text(
                  fajr?.getDateString() ?? 'Current Date',
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 24,
                    color: Colors.green,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                Column(children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _getPrayerCards(),
                  ),
                ]),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 0,
          child: SettingsScreen(),
        ),
      ],
    );
  }
}
