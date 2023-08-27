import 'package:flutter/material.dart';
import 'package:simple_azaan/api/aladhan_api.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/screens/home/date_display_widget.dart';
import 'package:simple_azaan/screens/home/go_to_today_widget.dart';
import 'package:simple_azaan/screens/home/menu_icon_widget.dart';
import 'package:simple_azaan/screens/welcome/welcome_screen.dart';
import 'package:simple_azaan/widgets/prayer_name_card.dart';
import 'package:simple_azaan/widgets/prayer_time_card.dart';
import 'package:simple_azaan/models/prayer_data.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> with WidgetsBindingObserver {
  Prayer? fajr;
  Prayer? sunrise;
  Prayer? zuhr;
  Prayer? asr;
  Prayer? maghrib;
  Prayer? isha;
  AppLifecycleState? _appLifecycleState = AppLifecycleState.resumed;

  DateTime dateForFetchingPrayerTimes = DateTime.now();

  AlAdhanApi api = AlAdhanApi(
    city: 'Bellevue',
    state: 'WA',
    country: 'United States',
    method: '2',
  );

  bool canShowWelcomeScreen() {
    if (_appLifecycleState != AppLifecycleState.resumed) {
      return true;
    }
    if (fajr != null) {
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appLifecycleState = state;
    });
    if (state == AppLifecycleState.resumed) {
      if (fajr == null) {
        _updatePrayerTime();
      }
    }
  }

  void _updatePrayerTime() {
    if (fajr != null) {
      return;
    }
    Future<dynamic> x = api.getPrayerTimeForDate(dateForFetchingPrayerTimes);
    x.then((value) {
      PrayerData pd = PrayerData.fromAlAdhanApi(value);
      _updatePrayerState(pd);
    });
  }

  void _getCurrentDayPrayerTime() {
    dateForFetchingPrayerTimes = DateTime.now();
    Future<dynamic> x = api.getPrayerTimeToday();
    x.then((value) {
      PrayerData pd = PrayerData.fromAlAdhanApi(value);
      _updatePrayerState(pd);
    });
  }

  void _getNextDayPrayerTime() {
    dateForFetchingPrayerTimes =
        dateForFetchingPrayerTimes.add(const Duration(days: 1));
    Future<dynamic> x = api.getPrayerTimeForDate(dateForFetchingPrayerTimes);
    x.then((value) {
      PrayerData pd = PrayerData.fromAlAdhanApi(value);
      _updatePrayerState(pd);
    });
  }

  void _getPreviousDayPrayerTime() {
    dateForFetchingPrayerTimes =
        dateForFetchingPrayerTimes.subtract(const Duration(days: 1));
    Future<dynamic> x = api.getPrayerTimeForDate(dateForFetchingPrayerTimes);
    x.then((value) {
      PrayerData pd = PrayerData.fromAlAdhanApi(value);
      _updatePrayerState(pd);
    });
  }

  void _updatePrayerState(PrayerData pd) {
    setState(() {
      fajr = Prayer('Fajr', pd.time1);
      sunrise = Prayer('Sunrise', pd.time2);
      zuhr = Prayer('Zuhr', pd.time3);
      asr = Prayer('Asr', pd.time4);
      maghrib = Prayer('Maghrib', pd.time5);
      isha = Prayer('Isha', pd.time6);
    });
  }

  _getPrayers() {
    List<Prayer?> listOfPrayers = [fajr, sunrise, zuhr, asr, maghrib, isha];
    if (listOfPrayers[0] == null) {
      return <Prayer?>[];
    }

    int currentPrayerIndex = listOfPrayers.indexWhere(
      (element) => element?.hasPrayerPassed == false,
    );

    // TODO: Sets Isha time if -1. Needs to be fixed.
    // if (currentPrayerIndex == -1) {
    //   listOfPrayers[listOfPrayers.length - 1]?.isCurrentPrayer = true;
    // } else if (currentPrayerIndex == 0) {
    //   listOfPrayers[listOfPrayers.length - 1]?.isCurrentPrayer = true;
    // } else if (currentPrayerIndex > 0 &&
    //     currentPrayerIndex <= listOfPrayers.length + 1) {
    //   --currentPrayerIndex;
    //   listOfPrayers[currentPrayerIndex]?.isCurrentPrayer = true;
    // }

    if (currentPrayerIndex >= 0) {
      listOfPrayers[currentPrayerIndex]?.isCurrentPrayer = true;
    }

    return listOfPrayers;
  }

  _getPrayerCards(List<Prayer?> listOfPrayers) {
    return List.generate(listOfPrayers.length, (index) {
      return Column(
        children: [
          PrayerNameCard(prayer: listOfPrayers[index]),
          PrayerTimeCard(
            prayer: listOfPrayers[index],
            timeToDisplay: PrayerTimeDisplay.prayerTime,
          ),
        ],
      );
    });
  }

  bool _isToday(DateTime other) {
    DateTime now = DateTime.now();
    return now.year == other.year &&
        now.month == other.month &&
        now.day == other.day;
  }

  @override
  Widget build(BuildContext context) {
    bool showWelcomeScreen = canShowWelcomeScreen();
    if (showWelcomeScreen) {
      _updatePrayerTime();
    }
    bool showGoToTodayWidget = _isToday(fajr?.getPrayerTime ?? DateTime.now());

    return Container(
      color: const Color(0xfff6f7f9),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _getPreviousDayPrayerTime,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.black26,
                  iconSize: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DateDisplayWidget(
                      date: fajr?.getDateString() ?? 'Current Date',
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _getPrayerCards(_getPrayers()),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _getNextDayPrayerTime,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.black26,
                  iconSize: 30,
                ),
              ],
            ),
            GoToTodayWidget(
              offstage: showGoToTodayWidget,
              tapHandler: _getCurrentDayPrayerTime,
            ),
            const MenuIconWidget(),
            WelcomeScreen(showWelcomeScreen: showWelcomeScreen),
          ],
        ),
      ),
    );
  }
}
