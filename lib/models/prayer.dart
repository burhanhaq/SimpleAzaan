import 'package:intl/intl.dart';

class Prayer {
  final String name;
  final DateTime prayerTime;
  bool _isCurrentPrayer = false;

  Prayer(
    this.name,
    this.prayerTime,
  );

  DateTime get getPrayerTime => prayerTime;
  bool get isCurrentPrayer => _isCurrentPrayer;

  set isCurrentPrayer(value) {
    _isCurrentPrayer = value;
  }

  bool get hasPrayerPassed {
    return getPrayerTime.isBefore(DateTime.now());
  }

  String getTimeString() {
    String formattedDate = DateFormat('kk:mm').format(prayerTime);
    return formattedDate;
  }

  String getDateString() {
    String formattedDate = DateFormat("EEE, MMM d, ''yy").format(prayerTime);
    return formattedDate;
  }
}
