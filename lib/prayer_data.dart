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

  PrayerData.fromAlAdhanApi(Map<String, dynamic> json)
      : time1 = DateTime.parse(json['data']['timings']['Fajr']).toLocal(),
        time2 = DateTime.parse(json['data']['timings']['Sunrise']).toLocal(),
        time3 = DateTime.parse(json['data']['timings']['Dhuhr']).toLocal(),
        time4 = DateTime.parse(json['data']['timings']['Asr']).toLocal(),
        time5 = DateTime.parse(json['data']['timings']['Maghrib']).toLocal(),
        time6 = DateTime.parse(json['data']['timings']['Isha']).toLocal();

  PrayerData.fromJson(Map<String, dynamic> json)
      : time1 = json['time1'],
        time2 = json['time2'],
        time3 = json['time3'],
        time4 = json['time4'],
        time5 = json['time5'],
        time6 = json['time6'];

  Map<String, dynamic> toJson() => {
        'time1': time1.toIso8601String(),
        'time2': time2.toIso8601String(),
        'time3': time3.toIso8601String(),
        'time4': time4.toIso8601String(),
        'time5': time5.toIso8601String(),
        'time6': time6.toIso8601String(),
      };
}
