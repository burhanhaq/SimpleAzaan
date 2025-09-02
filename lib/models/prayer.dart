import 'package:intl/intl.dart';
import 'package:simple_azaan/service/settings_service.dart';
import 'package:simple_azaan/themes/prayer_colors.dart';

class Prayer {
  final String name;
  final DateTime prayerTime;
  bool _isCurrentPrayer = false;

  Prayer(
    this.name,
    this.prayerTime,
  );

  /// Gets the PrayerType enum for this prayer based on its name
  PrayerType? get prayerType {
    return PrayerTypeHelper.getPrayerType(name);
  }

  DateTime get getPrayerTime => prayerTime;
  bool get isCurrentPrayer {
    final DateTime now = DateTime.now();
    if (now.year == prayerTime.year &&
        now.month == prayerTime.month &&
        now.day == prayerTime.day) {
      return _isCurrentPrayer;
    }
    return false;
  }

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
