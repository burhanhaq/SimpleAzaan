import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_azaan/widgets/clock_graduation.dart';

class ClockDial extends StatefulWidget {
  ClockDial({
    super.key,
    required this.currentPrayerTime,
    required this.nextPrayerTime,
  });
  DateTime currentPrayerTime;
  DateTime nextPrayerTime;

  @override
  State<ClockDial> createState() => _ClockDialState();
}

class _ClockDialState extends State<ClockDial> {
  createClockGraduations() {
    Duration prayerTimeElapsed = DateTime.parse('2023-03-29 15:27:00')
        .difference(widget.currentPrayerTime);
    Duration totalPrayerTimeDifference =
        widget.nextPrayerTime.difference(widget.currentPrayerTime);

    const graduationsCount = 60;
    List<Widget> graduations = List.generate(graduationsCount, (index) {
      var angle = index / graduationsCount * 2 * pi;
      var isGraduationPassedAngle = prayerTimeElapsed.inSeconds /
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
        children: createClockGraduations(),
      ),
    );
  }
}
