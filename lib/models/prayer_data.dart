import 'package:intl/intl.dart';

class PrayerData {
  final DateTime time1;
  final DateTime time2;
  final DateTime time3;
  final DateTime time4;
  final DateTime time5;
  final DateTime time6;

  PrayerData(
    this.time1,
    this.time2,
    this.time3,
    this.time4,
    this.time5,
    this.time6,
  );

  String getTimeString(DateTime t) {
    String formattedDate = DateFormat('kk:mm').format(t);
    return formattedDate;
  }

  PrayerData.fromAlAdhanApi(Map<String, dynamic> json)
      : time1 = DateTime.parse(json['data']['timings']['Fajr']).toLocal(),
        time2 = DateTime.parse(json['data']['timings']['Sunrise']).toLocal(),
        time3 = DateTime.parse(json['data']['timings']['Dhuhr']).toLocal(),
        time4 = DateTime.parse(json['data']['timings']['Asr']).toLocal(),
        time5 = DateTime.parse(json['data']['timings']['Maghrib']).toLocal(),
        time6 = DateTime.parse(json['data']['timings']['Isha']).toLocal();

  // Load from persisted JSON (stored as UTC ISO-8601) and convert to local
  PrayerData.fromJson(Map<String, dynamic> json)
      : time1 = DateTime.parse(json['time1']).toLocal(),
        time2 = DateTime.parse(json['time2']).toLocal(),
        time3 = DateTime.parse(json['time3']).toLocal(),
        time4 = DateTime.parse(json['time4']).toLocal(),
        time5 = DateTime.parse(json['time5']).toLocal(),
        time6 = DateTime.parse(json['time6']).toLocal();

  Map<String, dynamic> toJson() => {
        // Store as UTC ISO-8601 so iOS can parse reliably
        'time1': time1.toUtc().toIso8601String(),
        'time2': time2.toUtc().toIso8601String(),
        'time3': time3.toUtc().toIso8601String(),
        'time4': time4.toUtc().toIso8601String(),
        'time5': time5.toUtc().toIso8601String(),
        'time6': time6.toUtc().toIso8601String(),
      };
}
