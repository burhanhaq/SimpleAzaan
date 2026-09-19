import 'package:flutter/material.dart';

import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/widgets/prayer_name_card.dart';
import 'package:simple_azaan/widgets/prayer_time_card.dart';

class PrayerList extends StatelessWidget {
  const PrayerList({
    super.key,
    required this.prayers,
    this.highlightedPrayer,
  });

  final List<Prayer> prayers;
  final Prayer? highlightedPrayer;

  static const int _highlightedFlex = 2;
  static const int _regularFlex = 1;

  @override
  Widget build(BuildContext context) {
    if (prayers.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalFlex = prayers.fold<int>(
          0,
          (sum, prayer) => sum + _flexFor(prayer),
        );

        return Column(
          children: [
            for (final prayer in prayers)
              Flexible(
                flex: _flexFor(prayer),
                child: _PrayerSlot(
                  prayer: prayer,
                  isHighlighted: identical(prayer, highlightedPrayer),
                  slotHeight:
                      constraints.maxHeight * _flexFor(prayer) / totalFlex,
                ),
              ),
          ],
        );
      },
    );
  }

  int _flexFor(Prayer prayer) =>
      identical(prayer, highlightedPrayer) ? _highlightedFlex : _regularFlex;
}

class _PrayerSlot extends StatelessWidget {
  const _PrayerSlot({
    required this.prayer,
    required this.isHighlighted,
    required this.slotHeight,
  });

  final Prayer prayer;
  final bool isHighlighted;
  final double slotHeight;

  @override
  Widget build(BuildContext context) {
    final nameFontSize = (slotHeight * (isHighlighted ? 0.40 : 0.34))
        .clamp(isHighlighted ? 22.0 : 14.0, isHighlighted ? 68.0 : 32.0)
        .toDouble();
    final timeFontSize = (slotHeight * (isHighlighted ? 0.24 : 0.30))
        .clamp(isHighlighted ? 16.0 : 14.0, isHighlighted ? 42.0 : 30.0)
        .toDouble();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrayerNameCard(
            prayer: prayer,
            isHighlighted: isHighlighted,
            fontSize: nameFontSize,
          ),
          PrayerTimeCard(
            prayer: prayer,
            isHighlighted: isHighlighted,
            fontSize: timeFontSize,
          ),
        ],
      ),
    );
  }
}
