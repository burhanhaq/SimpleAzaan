import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/screens/home/date_display_widget.dart';
import 'package:simple_azaan/screens/home/location_display_widget.dart';
import 'package:simple_azaan/screens/home/go_to_today_widget.dart';
import 'package:simple_azaan/screens/home/menu_icon_widget.dart';
import 'package:simple_azaan/screens/welcome/welcome_screen.dart';
import 'package:simple_azaan/widgets/prayer_name_card.dart';
import 'package:simple_azaan/widgets/prayer_time_card.dart';
import 'package:simple_azaan/widgets/sleek_loading_indicator.dart';
import 'package:simple_azaan/providers/location_provider.dart';
import 'package:simple_azaan/providers/prayer_times_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppLifecycleState? _appLifecycleState = AppLifecycleState.resumed;
  bool _isInitialized = false;

  bool canShowWelcomeScreen() {
    if (_appLifecycleState != AppLifecycleState.resumed) {
      return true;
    }

    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    if (prayerTimesProvider.hasData) {
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    if (_isInitialized) return;

    final locationProvider = context.read<LocationProvider>();
    final prayerTimesProvider = context.read<PrayerTimesProvider>();

    await locationProvider.initialize();

    if (locationProvider.currentLocation != null) {
      await prayerTimesProvider
          .loadPrayerTimes(locationProvider.currentLocation!);
    }

    _isInitialized = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appLifecycleState = state;
    });
    if (state == AppLifecycleState.resumed) {
      final prayerTimesProvider = context.read<PrayerTimesProvider>();
      if (!prayerTimesProvider.hasData) {
        _initializeProviders();
      } else {
        prayerTimesProvider.refreshPrayerTimes();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refreshPrayerTimes() {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    prayerTimesProvider.refreshPrayerTimes();
  }

  void _getCurrentDayPrayerTime() async {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    await prayerTimesProvider.goToToday();
  }

  void _getNextDayPrayerTime() {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    prayerTimesProvider.goToNextDay();
  }

  void _getPreviousDayPrayerTime() {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    prayerTimesProvider.goToPreviousDay();
  }

  List<Prayer> _getPrayers(PrayerTimesProvider prayerTimesProvider) {
    return prayerTimesProvider.prayers;
  }

  _getPrayerCards(List<Prayer> listOfPrayers) {
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

  @override
  Widget build(BuildContext context) {
    bool showWelcomeScreen = canShowWelcomeScreen();
    if (showWelcomeScreen) {
      _refreshPrayerTimes();
    }

    return Consumer2<LocationProvider, PrayerTimesProvider>(
      builder: (context, locationProvider, prayerTimesProvider, child) {
        final prayers = _getPrayers(prayerTimesProvider);
        bool showGoToTodayWidget = prayerTimesProvider.isToday;

        String dateDisplay = 'Current Date';
        if (prayers.isNotEmpty) {
          dateDisplay = prayers.first.getDateString();
        } else {
          dateDisplay =
              prayerTimesProvider.selectedDate.toString().split(' ')[0];
        }

        String locationDisplay = kLoadingLocation;
        if (locationProvider.hasError) {
          locationDisplay = 'Error: ${locationProvider.errorMessage}';
        } else if (locationProvider.currentLocation != null) {
          locationDisplay = locationProvider.displayLocation;
        }

        return Container(
          color: kAppBackgroundColor,
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (prayerTimesProvider.isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _getPreviousDayPrayerTime,
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.black26,
                        iconSize: 30,
                      ),
                      const Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: SleekLoadingIndicator(
                            width: 200,
                            height: 2,
                            primaryColor: Colors.black26,
                            backgroundColor: kLoadingBackgroundColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _getNextDayPrayerTime,
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: Colors.black26,
                        iconSize: 30,
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: _getPreviousDayPrayerTime,
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.black26,
                        iconSize: 30,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DateDisplayWidget(date: dateDisplay),
                            LocationDisplayWidget(location: locationDisplay),
                            const SizedBox(height: 10),
                            if (prayerTimesProvider.hasError)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Error loading prayer times',
                                      style: TextStyle(color: kErrorColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      prayerTimesProvider.errorMessage ?? '',
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _refreshPrayerTimes,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: _getPrayerCards(prayers),
                              ),
                          ],
                        ),
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
      },
    );
  }
}
