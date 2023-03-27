import 'package:flutter/material.dart';
import 'package:simple_azaan/prayer.dart';

class PrayerCard extends StatefulWidget {
  final Prayer prayer;
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

    var prayerPassed = widget.prayer.prayerTime.isBefore(DateTime.now());

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(vertical: 3),
      color: Colors.amber,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          widget.prayer.name,
          style: TextStyle(
            fontSize: 30,
            decoration:
                prayerPassed ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        Text(
          widget.prayer.getTimeString(),
          style: TextStyle(
            fontSize: 30,
            decoration:
                prayerPassed ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        )
      ]),
    );
  }
}
