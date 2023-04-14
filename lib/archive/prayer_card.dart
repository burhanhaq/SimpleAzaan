import 'package:flutter/material.dart';
import 'package:simple_azaan/models/prayer.dart';

class PrayerCard extends StatefulWidget {
  final Prayer? prayer;
  const PrayerCard({
    super.key,
    required this.prayer,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  _hasPrayerPassed() {
    if (widget.prayer == null) return false;
    if (widget.prayer!.isCurrentPrayer) return false;
    return widget.prayer!.hasPrayerPassed;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var cardWidth = screenSize.width * 0.8;
    var cardHeight = cardWidth / 7;

    var prayerName = widget.prayer?.name ?? 'Prayer';
    var prayerTime = widget.prayer?.getTimeString() ?? '12:00';
    var isCurrentPrayer = widget.prayer?.isCurrentPrayer ?? false;

    var prayerNameFontWeight =
        isCurrentPrayer ? FontWeight.w800 : FontWeight.w500;
    var prayerNameFontColor = _hasPrayerPassed() ? Colors.grey : Colors.green;

    var prayerTimeFontWeight =
        isCurrentPrayer ? FontWeight.w800 : FontWeight.w400;
    var prayerTimeFontColor = _hasPrayerPassed() ? Colors.grey : Colors.green;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: TextStyle(
              fontSize: 30,
              color: prayerNameFontColor,
              fontWeight: prayerNameFontWeight,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            prayerTime,
            style: TextStyle(
              fontSize: 30,
              color: prayerTimeFontColor,
              fontWeight: prayerTimeFontWeight,
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }
}
