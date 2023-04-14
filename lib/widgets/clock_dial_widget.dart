import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/widgets/clock_graduation.dart';

class ClockDial extends StatefulWidget {
  ClockDial({
    super.key,
    // required this.currentPrayerTime,
    // required this.nextPrayerTime,
    required this.listOfPrayers,
  });
  // DateTime currentPrayerTime;
  // DateTime nextPrayerTime;
  List<Prayer?> listOfPrayers;

  @override
  State<ClockDial> createState() => _ClockDialState();
}

class _ClockDialState extends State<ClockDial> {
  createClockGraduations(DateTime currentPrayerTime, DateTime nextPrayerTime) {
    Duration prayerTimeElapsed = DateTime.now().difference(currentPrayerTime);
    Duration totalPrayerTimeDifference =
        nextPrayerTime.difference(currentPrayerTime);

    const graduationsCount = 40;
    List<Widget> graduations = List.generate(graduationsCount, (index) {
      var angle = -index / graduationsCount * 2 * pi;
      var isGraduationPassedAngle = -prayerTimeElapsed.inSeconds /
          totalPrayerTimeDifference.inSeconds *
          (2 * pi);
      // var isPassed = false;
      return Transform.rotate(
        origin: const Offset(0, 0),
        angle: angle,
        child: ClockGraduation(
            isGraduationPassed: isGraduationPassedAngle < angle),
      );
    });

    return graduations;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var clockDiameter = screenSize.width / 1.3;

    DateTime? currentPrayerTime;
    DateTime? nextPrayerTime;

    Prayer? currentPrayer = widget.listOfPrayers
        .firstWhere((element) => element!.isCurrentPrayer, orElse: () => null);
    if (currentPrayer != null) {
      currentPrayerTime = currentPrayer.getPrayerTime;

      int nextPrayerIndex = widget.listOfPrayers.indexOf(currentPrayer);
      if (nextPrayerIndex == -1) {
      } else if (nextPrayerIndex == widget.listOfPrayers.length - 1) {
        nextPrayerIndex = 0;
      } else {
        ++nextPrayerIndex;
        DateTime oldFajrPrayerTime =
            widget.listOfPrayers[nextPrayerIndex]!.getPrayerTime;
        Prayer newFajrHackPrayer =
            Prayer('Fajr', oldFajrPrayerTime.add(const Duration(days: 1)));
        widget.listOfPrayers[0] = newFajrHackPrayer;
      }
      Prayer? nextPrayer = widget.listOfPrayers[nextPrayerIndex]!;
      nextPrayerTime = nextPrayer.getPrayerTime;
    }

    return Container(
      height: clockDiameter,
      width: clockDiameter,
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xffffffff),
          boxShadow: [
            BoxShadow(
              color: Colors.green,
              blurRadius: 2,
              spreadRadius: 1,
            )
          ]),
      child: Stack(
        alignment: Alignment.center,
        children: createClockGraduations(currentPrayerTime ?? DateTime.now(),
            nextPrayerTime ?? DateTime.now()),
      ),
    );
  }
}
