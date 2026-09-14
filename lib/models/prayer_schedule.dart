import 'package:simple_azaan/models/location.dart';
import 'package:simple_azaan/models/prayer_data.dart';

class PrayerSchedule {
  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime generatedAt;
  final Location location;
  final String calculationMethod;
  final List<PrayerData> days;

  PrayerSchedule({
    this.schemaVersion = currentSchemaVersion,
    required this.generatedAt,
    required this.location,
    required this.calculationMethod,
    required List<PrayerData> days,
  }) : days = List.unmodifiable(days);

  factory PrayerSchedule.fromJson(Map<String, dynamic> json) {
    return PrayerSchedule(
      schemaVersion: json['schemaVersion'] as int? ?? currentSchemaVersion,
      generatedAt: DateTime.parse(json['generatedAt'] as String).toLocal(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      calculationMethod: json['calculationMethod'] as String? ?? '2',
      days: (json['days'] as List<dynamic>)
          .map((day) => PrayerData.fromJson(day as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'location': location.toJson(),
        'calculationMethod': calculationMethod,
        'days': days.map((day) => day.toJson()).toList(),
      };
}
