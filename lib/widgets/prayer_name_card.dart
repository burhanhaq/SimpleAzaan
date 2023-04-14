import 'package:flutter/material.dart';
import 'package:simple_azaan/models/prayer.dart';

class PrayerNameCard extends StatefulWidget {
  final Prayer? prayer;
  const PrayerNameCard({
    super.key,
    required this.prayer,
  });

  @override
  State<PrayerNameCard> createState() => _PrayerNameCardState();
}

class _PrayerNameCardState extends State<PrayerNameCard> {
  _hasPrayerPassed() {
    if (widget.prayer == null) return false;
    if (widget.prayer!.isPrayerCurrent) return false;
    return widget.prayer!.hasPrayerPassed;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenWidth = screenSize.width;

    var activePrayerNameFontSize = screenWidth * 0.18;
    var inactivePrayerNameFontSize = screenWidth * 0.08;

    var prayerName = widget.prayer?.name ?? 'Prayer';
    var isCurrentPrayer = widget.prayer?.isCurrentPrayer ?? false;

    var prayerNameFontWeight =
        isCurrentPrayer ? FontWeight.w200 : FontWeight.w100;
    var prayerNameFontSize =
        isCurrentPrayer ? activePrayerNameFontSize : inactivePrayerNameFontSize;
    var prayerNameFontColor = isCurrentPrayer ? Colors.black : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        prayerName,
        style: TextStyle(
          fontSize: prayerNameFontSize,
          color: prayerNameFontColor,
          fontWeight: prayerNameFontWeight,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
