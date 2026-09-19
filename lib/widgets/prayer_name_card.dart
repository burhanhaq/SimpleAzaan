import 'package:flutter/material.dart';

import 'package:simple_azaan/models/prayer.dart';

class PrayerNameCard extends StatelessWidget {
  const PrayerNameCard({
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
      prayer?.name ?? 'Prayer',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: isHighlighted ? Colors.black : Colors.grey,
        fontWeight: isHighlighted ? FontWeight.w200 : FontWeight.w100,
        decoration: TextDecoration.none,
      ),
    );
  }
}
