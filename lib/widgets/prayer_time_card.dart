import 'package:flutter/material.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/constants.dart';

class PrayerTimeCard extends StatefulWidget {
  final Prayer? prayer;
  final PrayerTimeDisplay timeToDisplay;
  const PrayerTimeCard({
    super.key,
    required this.prayer,
    required this.timeToDisplay,
  });

  @override
  State<PrayerTimeCard> createState() => _PrayerTimeCardState();
}

class _PrayerTimeCardState extends State<PrayerTimeCard> {
  _hasPrayerPassed() {
    if (widget.prayer == null) return false;
    if (widget.prayer!.isCurrentPrayer) return false;
    return widget.prayer!.hasPrayerPassed;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenWidth = screenSize.width;
    var screenHeight = screenSize.height;

    var activePrayerTimeFontSize = screenWidth * 0.11;
    var inactivePrayerTimeFontSize = screenWidth * 0.08;
    var timeToNextPrayerFontSize = screenWidth * 0.06;

    var prayerTime = widget.prayer?.getTimeString() ?? '12:00';
    var isCurrentPrayer = widget.prayer?.isCurrentPrayer ?? false;

    var prayerTimeFontWeight =
        isCurrentPrayer ? FontWeight.w300 : FontWeight.w200;

    var prayerTimeFontSize =
        isCurrentPrayer ? activePrayerTimeFontSize : inactivePrayerTimeFontSize;
    var prayerTimeFontColor = isCurrentPrayer ? Colors.black : Colors.grey;

    return LayoutBuilder(builder: (context, constraints) {
      switch (widget.timeToDisplay) {
        case PrayerTimeDisplay.prayerTime:
          return PrayerTimeWidget(
            screenHeight: screenHeight,
            prayerTime: prayerTime,
            prayerTimeFontSize: prayerTimeFontSize,
            prayerTimeFontColor: prayerTimeFontColor,
            prayerTimeFontWeight: prayerTimeFontWeight,
          );
        case PrayerTimeDisplay.timeToNextPrayer:
          return Container(
            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
            child: Text(
              '4 minutes 3 seconds to',
              style: TextStyle(
                fontSize: timeToNextPrayerFontSize,
                color: prayerTimeFontColor,
                fontWeight: prayerTimeFontWeight,
                decoration: TextDecoration.none,
              ),
            ),
          );
      }
    });
  }
}

class PrayerTimeWidget extends StatelessWidget {
  const PrayerTimeWidget({
    super.key,
    required this.screenHeight,
    required this.prayerTime,
    required this.prayerTimeFontSize,
    required this.prayerTimeFontColor,
    required this.prayerTimeFontWeight,
  });

  final double screenHeight;
  final String prayerTime;
  final double prayerTimeFontSize;
  final Color prayerTimeFontColor;
  final FontWeight prayerTimeFontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
      child: Text(
        prayerTime,
        style: TextStyle(
          fontSize: prayerTimeFontSize,
          color: prayerTimeFontColor,
          fontWeight: prayerTimeFontWeight,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
