import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/providers/location_provider.dart';
import 'package:simple_azaan/providers/prayer_times_provider.dart';
import 'package:simple_azaan/screens/home/date_display_widget.dart';
import 'package:simple_azaan/screens/home/go_to_today_widget.dart';
import 'package:simple_azaan/screens/home/location_display_widget.dart';
import 'package:simple_azaan/screens/home/menu_icon_widget.dart';
import 'package:simple_azaan/widgets/prayer_list.dart';
import 'package:simple_azaan/widgets/sleek_loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  LocationProvider? _locationProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _locationProvider = context.read<LocationProvider>();
      _locationProvider!.addListener(_handleLocationChange);
      unawaited(_locationProvider!.initialize());
    });
  }

  void _handleLocationChange() {
    if (!mounted) return;
    final provider = _locationProvider!;
    final location = provider.currentLocation;
    if (provider.state != LocationState.success || location == null) return;

    final prayerProvider = context.read<PrayerTimesProvider>();
    if (prayerProvider.currentLocation != location) {
      unawaited(
        prayerProvider.loadPrayerTimes(
          location,
          date: DateTime.now(),
          forceRefresh: prayerProvider.currentLocation != null,
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      unawaited(context.read<PrayerTimesProvider>().handleAppResumed());
    }
  }

  @override
  void dispose() {
    _locationProvider?.removeListener(_handleLocationChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, PrayerTimesProvider>(
      builder: (context, locationProvider, prayerProvider, child) {
        final prayers = prayerProvider.prayers;
        final dateDisplay = prayers.isNotEmpty
            ? prayers.first.getDateString()
            : prayerProvider.selectedDate.toString().split(' ')[0];
        final locationDisplay =
            locationProvider.currentLocation?.displayName ?? kUnknownLocation;

        return Scaffold(
          backgroundColor: kAppBackgroundColor,
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (prayerProvider.isLoading && prayers.isEmpty)
                  const Center(
                    child: SleekLoadingIndicator(
                      width: 200,
                      height: 2,
                      primaryColor: Colors.black26,
                      backgroundColor: kLoadingBackgroundColor,
                    ),
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: prayerProvider.goToPreviousDay,
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
                            if (locationProvider.hasError &&
                                locationProvider.currentLocation == null)
                              _InlineError(
                                message: locationProvider.errorMessage ??
                                    'Unable to load location.',
                                onRetry: locationProvider.refreshLocation,
                              )
                            else if (prayerProvider.hasError)
                              _InlineError(
                                message: prayerProvider.errorMessage ??
                                    'Unable to load prayer times.',
                                onRetry: prayerProvider.refreshPrayerTimes,
                              )
                            else
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: kHomeBottomOverlayInset,
                                  ),
                                  child: PrayerList(
                                    prayers: prayers,
                                    highlightedPrayer:
                                        prayerProvider.currentPrayer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: prayerProvider.goToNextDay,
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: Colors.black26,
                        iconSize: 30,
                      ),
                    ],
                  ),
                GoToTodayWidget(
                  offstage: prayerProvider.isToday,
                  tapHandler: prayerProvider.goToToday,
                ),
                const MenuIconWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(color: kErrorColor, fontSize: 13),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
