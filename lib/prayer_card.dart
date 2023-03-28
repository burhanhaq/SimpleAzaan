import 'package:flutter/material.dart';
import 'package:simple_azaan/prayer.dart';

class PrayerCard extends StatefulWidget {
  final Prayer? prayer;
  const PrayerCard({super.key, required this.prayer});

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var cardWidth = screenSize.width * 0.8;
    var cardHeight = cardWidth / 7;

    var prayerPassed =
        widget.prayer?.prayerTime.isBefore(DateTime.now()) ?? false;
    var prayerName = widget.prayer?.name ?? 'Prayer';
    var prayerTime = widget.prayer?.getTimeString() ?? '12:00';

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
              color: prayerPassed ? Colors.grey : Colors.green,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            prayerTime,
            style: TextStyle(
              fontSize: 30,
              color: prayerPassed ? Colors.grey : Colors.green,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }
}
