import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/screens/home/date_display_widget.dart';
import 'package:simple_azaan/screens/home/location_display_widget.dart';
import 'package:simple_azaan/widgets/prayer_list.dart';

void main() {
  final prayers = [
    Prayer('Fajr', DateTime(2026, 9, 13, 5)),
    Prayer('Sunrise', DateTime(2026, 9, 13, 6, 30)),
    Prayer('Zuhr', DateTime(2026, 9, 13, 13)),
    Prayer('Asr', DateTime(2026, 9, 13, 16, 30)),
    Prayer('Maghrib', DateTime(2026, 9, 13, 19)),
    Prayer('Isha', DateTime(2026, 9, 13, 20, 30)),
  ];

  testWidgets('caps location to a single ellipsized line', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            child: LocationDisplayWidget(
              location: 'A Very Long Neighborhood Name, Washington',
            ),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byType(LocationDisplayWidget),
        matching: find.byType(Text),
      ),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets(
    'keeps Isha on screen in a short viewport with a long location',
    (tester) async {
      const viewport = Size(375, 667);
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final overflows = <String>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) {
          overflows.add(details.exceptionAsString());
        }
        previousOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousOnError);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: kAppBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  const DateDisplayWidget(date: "Sat, Sep 13, '26"),
                  const LocationDisplayWidget(
                    location:
                        'North Springfield Township of the Greater Metropolitan Area, Washington',
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: kHomeBottomOverlayInset,
                      ),
                      child: PrayerList(
                        prayers: prayers,
                        highlightedPrayer: prayers.last,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(overflows, isEmpty);
      expect(find.text('Isha'), findsOneWidget);
      expect(find.text('20:30'), findsOneWidget);

      for (final name in [
        'Fajr',
        'Sunrise',
        'Zuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ]) {
        expect(find.text(name), findsOneWidget);
      }

      final locationRect = tester.getRect(find.byType(LocationDisplayWidget));
      expect(locationRect.height, lessThan(28));

      final ishaBottom = tester.getRect(find.text('Isha')).bottom;
      final ishaTimeBottom = tester.getRect(find.text('20:30')).bottom;
      final maxVisibleBottom = viewport.height - kHomeBottomOverlayInset;

      expect(ishaBottom, lessThanOrEqualTo(maxVisibleBottom));
      expect(ishaTimeBottom, lessThanOrEqualTo(maxVisibleBottom));
      expect(ishaBottom, greaterThanOrEqualTo(0));
    },
  );
}
