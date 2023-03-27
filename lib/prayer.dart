import 'package:intl/intl.dart';

class Prayer {
  final String name;
  final DateTime prayerTime;

  Prayer(
    this.name,
    this.prayerTime,
  );

  String getTimeString() {
    String formattedDate = DateFormat('kk:mm').format(prayerTime);
    return formattedDate;
  }
}
