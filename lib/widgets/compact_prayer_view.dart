import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/providers/location_provider.dart';
import 'package:simple_azaan/providers/prayer_times_provider.dart';

class CompactPrayerView extends StatefulWidget {
  const CompactPrayerView({super.key});

  @override
  State<CompactPrayerView> createState() => _CompactPrayerViewState();
}

class _CompactPrayerViewState extends State<CompactPrayerView> {
  Timer? _countdownTimer;
  String _timeToNextPrayer = '';

  @override
  void initState() {
    super.initState();
    // Calculate initial countdown immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _timeToNextPrayer = _calculateTimeToNextPrayer();
        });
      }
    });
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeToNextPrayer = _calculateTimeToNextPrayer();
        });
      }
    });
  }

  String _calculateTimeToNextPrayer() {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    final nextPrayer = prayerTimesProvider.nextPrayer;
    
    if (nextPrayer == null) {
      return 'No upcoming prayers';
    }

    final now = DateTime.now();
    final difference = nextPrayer.prayerTime.difference(now);
    
    if (difference.isNegative) {
      return 'Prayer time passed';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes >= 5) {
      return '${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Consumer2<LocationProvider, PrayerTimesProvider>(
      builder: (context, locationProvider, prayerTimesProvider, child) {
        final prayers = prayerTimesProvider.prayers;
        final currentPrayer = prayerTimesProvider.currentPrayer;
        final nextPrayer = prayerTimesProvider.nextPrayer;

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
          width: screenWidth,
          height: screenHeight,
          color: kAppBackgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Date and Location at top
                  const SizedBox(height: 20),
                  Text(
                    dateDisplay,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locationDisplay,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w200,
                      color: Colors.black54,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Center content vertically
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                  // Current Prayer Section
                  if (currentPrayer != null) ...[
                    Text(
                      currentPrayer.name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.18,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      currentPrayer.getTimeString(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.11,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // Countdown Section
                  if (nextPrayer != null) ...[
                    Text(
                      'Next Prayer In',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w200,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _timeToNextPrayer,
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.w200,
                        color: Colors.black87,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Next Prayer Section
                    Text(
                      'Next Prayer',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w200,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nextPrayer.name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      nextPrayer.getTimeString(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w200,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ] else ...[
                    // No next prayer available
                    Text(
                      'No upcoming prayers today',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w300,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                      ],
                    ),
                  ),
                  
                  // Subtle hint for switching views at bottom
                  Text(
                    'Swipe to switch views',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w200,
                      color: Colors.black38,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
