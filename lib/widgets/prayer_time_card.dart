import 'package:flutter/material.dart';
import 'package:simple_azaan/models/prayer.dart';

class PrayerTimeCard extends StatefulWidget {
  final Prayer? prayer;
  const PrayerTimeCard({
    super.key,
    required this.prayer,
  });

  @override
  State<PrayerTimeCard> createState() => _PrayerTimeCardState();
}

class _PrayerTimeCardState extends State<PrayerTimeCard> {
  _hasPrayerPassed() {
    if (widget.prayer == null) return false;
    if (widget.prayer!.isPrayerCurrent) return false;
    return widget.prayer!.hasPrayerPassed;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenWidth = screenSize.width;
    var screenHeight = screenSize.height;

    var activePrayerTimeFontSize = screenWidth * 0.11;
    var inactivePrayerTimeFontSize = screenWidth * 0.08;

    var prayerTime = widget.prayer?.getTimeString() ?? '12:00';
    var isCurrentPrayer = widget.prayer?.isCurrentPrayer ?? false;

    var prayerTimeFontWeight =
        isCurrentPrayer ? FontWeight.w300 : FontWeight.w200;

    var prayerTimeFontSize =
        isCurrentPrayer ? activePrayerTimeFontSize : inactivePrayerTimeFontSize;
    var prayerTimeFontColor = isCurrentPrayer ? Colors.black : Colors.grey;

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
