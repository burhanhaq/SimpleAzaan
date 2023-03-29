import 'package:intl/intl.dart';

class Prayer {
  final String name;
  final DateTime prayerTime;
  bool isPrayerCurrent = false;

  Prayer(
    this.name,
    this.prayerTime,
  );

  DateTime get getPrayerTime => prayerTime;
  bool get isCurrentPrayer => isPrayerCurrent;

  set isCurrentPrayer(value) {
    isPrayerCurrent = value;
  }

  bool get hasPrayerPassed {
    return getPrayerTime.isBefore(DateTime.now());
  }

  String getTimeString() {
    String formattedDate = DateFormat('kk:mm').format(prayerTime);
    return formattedDate;
  }
}
