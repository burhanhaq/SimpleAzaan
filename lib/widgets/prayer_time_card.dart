import 'package:flutter/material.dart';

import 'package:simple_azaan/models/prayer.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    super.key,
    required this.prayer,
    required this.fontSize,
    this.isHighlighted = false,
  });

  final Prayer? prayer;
  final double fontSize;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Text(
      prayer?.getTimeString() ?? '12:00',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: isHighlighted ? Colors.black : Colors.grey,
        fontWeight: isHighlighted ? FontWeight.w300 : FontWeight.w200,
        decoration: TextDecoration.none,
      ),
    );
  }
}
