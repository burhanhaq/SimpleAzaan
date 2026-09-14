import 'dart:async';

import 'package:flutter/material.dart';

import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/location.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/models/prayer_schedule.dart';
import 'package:simple_azaan/repositories/prayer_times_repository.dart';
import 'package:simple_azaan/service/notification_service.dart';
import 'package:simple_azaan/service/widget_sync.dart';

enum PrayerTimesState { initial, loading, success, error }

class PrayerTimesProvider extends ChangeNotifier {
  final PrayerTimesRepository _repository = PrayerTimesRepository.instance;

  PrayerTimesState _state = PrayerTimesState.initial;
  List<Prayer> _prayers = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _lastObservedDate = DateTime.now();
  Location? _currentLocation;
  String? _errorMessage;
  PrayerData? _prayerData;
  PrayerSchedule? _schedule;
  Timer? _statusTimer;
  int _requestGeneration = 0;

  PrayerTimesState get state => _state;
  List<Prayer> get prayers => List.unmodifiable(_prayers);
  DateTime get selectedDate => _selectedDate;
  Location? get currentLocation => _currentLocation;
  String? get errorMessage => _errorMessage;
  PrayerData? get prayerData => _prayerData;
  PrayerSchedule? get schedule => _schedule;
  bool get isLoading => _state == PrayerTimesState.loading;
  bool get hasError => _state == PrayerTimesState.error;
  bool get hasData => _prayers.isNotEmpty;

  Prayer? get fajr => _prayerAt(0);
  Prayer? get sunrise => _prayerAt(1);
  Prayer? get zuhr => _prayerAt(2);
  Prayer? get asr => _prayerAt(3);
  Prayer? get maghrib => _prayerAt(4);
  Prayer? get isha => _prayerAt(5);

  Prayer? _prayerAt(int index) =>
      _prayers.length > index ? _prayers[index] : null;

  bool get isToday => _isSameDay(_selectedDate, DateTime.now());

  Prayer? get currentPrayer =>
      isToday ? activePrayerAt(_prayers, DateTime.now()) : null;

  Prayer? get nextPrayer {
    final now = DateTime.now();
    if (_schedule != null && isToday) {
      return nextPrayerAt(
        _schedule!.days.expand(_prayersFromData),
        now,
      );
    }
    return nextPrayerAt(_prayers, now);
  }

  Future<void> loadPrayerTimes(
    Location location, {
    DateTime? date,
    bool refresh = false,
    bool forceRefresh = false,
  }) async {
    final targetDate = date ?? DateTime.now();
    if (!refresh &&
        !forceRefresh &&
        _currentLocation == location &&
        _isSameDay(_selectedDate, targetDate) &&
        _state == PrayerTimesState.success) {
      _scheduleStatusRefresh();
      return;
    }

    final generation = ++_requestGeneration;
    _currentLocation = location;
    _selectedDate = targetDate;
    _errorMessage = null;
    if (forceRefresh) _repository.clearCache();
    _setState(PrayerTimesState.loading);

    final result = await _repository.getPrayerTimesWithCache(
      location: location,
      date: targetDate,
    );

    if (!_isCurrentRequest(generation, location)) return;
    if (!result.isSuccess || result.prayerData == null) {
      _setError(result.error ?? 'Failed to load prayer times');
      return;
    }

    _prayerData = result.prayerData;
    _prayers = _prayersFromData(result.prayerData!);
    _setState(PrayerTimesState.success);
    _scheduleStatusRefresh();

    if (_isSameDay(targetDate, DateTime.now())) {
      await _refreshRollingSchedule(
        location: location,
        today: result.prayerData!,
        generation: generation,
      );
    }
  }

  Future<void> _refreshRollingSchedule({
    required Location location,
    required PrayerData today,
    required int generation,
  }) async {
    List<PrayerData> futureDays = [];
    try {
      futureDays = await _repository.getPrayerTimesRange(
        location: location,
        startDate: DateTime.now().add(const Duration(days: 1)),
        dayCount: kScheduleHorizonDays - 1,
      );
    } catch (_) {
      // Today's data is still useful. A later refresh can extend the window.
    }

    if (!_isCurrentRequest(generation, location) || !isToday) return;

    final schedule = PrayerSchedule(
      generatedAt: DateTime.now(),
      location: location,
      calculationMethod: kDefaultMethod,
      days: [today, ...futureDays],
    );
    _schedule = schedule;

    try {
      await WidgetSync.pushPrayerScheduleToWidget(schedule);
    } catch (_) {
      // Widget refresh is independent from rendering the app.
    }

    try {
      await NotificationService().scheduleForPrayerSchedule(schedule);
    } catch (_) {
      // Keep the timetable usable if notification permission/setup fails.
    }
  }

  Future<void> refreshPrayerTimes() async {
    final location = _currentLocation;
    if (location == null) return;
    await loadPrayerTimes(
      location,
      date: _selectedDate,
      refresh: true,
      forceRefresh: true,
    );
  }

  Future<void> handleAppResumed() async {
    final now = DateTime.now();
    final wasFollowingToday = _isSameDay(_selectedDate, _lastObservedDate);
    final dayChanged = !_isSameDay(now, _lastObservedDate);
    _lastObservedDate = now;

    if (dayChanged && wasFollowingToday && _currentLocation != null) {
      await loadPrayerTimes(
        _currentLocation!,
        date: now,
        refresh: true,
      );
      return;
    }

    notifyListeners();
    _scheduleStatusRefresh();

    final scheduleIsStale = _schedule == null ||
        now.difference(_schedule!.generatedAt) > const Duration(hours: 6);
    if (isToday && scheduleIsStale && _currentLocation != null) {
      await loadPrayerTimes(
        _currentLocation!,
        date: now,
        refresh: true,
      );
    }
  }

  Future<void> goToNextDay() async {
    if (_currentLocation == null) return;
    await loadPrayerTimes(
      _currentLocation!,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day + 1,
      ),
    );
  }

  Future<void> goToPreviousDay() async {
    if (_currentLocation == null) return;
    await loadPrayerTimes(
      _currentLocation!,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day - 1,
      ),
    );
  }

  Future<void> goToToday() async {
    if (_currentLocation == null) return;
    await loadPrayerTimes(_currentLocation!, date: DateTime.now());
  }

  List<Prayer> _prayersFromData(PrayerData data) => [
        Prayer('Fajr', data.time1),
        Prayer('Sunrise', data.time2),
        Prayer('Zuhr', data.time3),
        Prayer('Asr', data.time4),
        Prayer('Maghrib', data.time5),
        Prayer('Isha', data.time6),
      ];

  bool _isCurrentRequest(int generation, Location location) =>
      generation == _requestGeneration && _currentLocation == location;

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  void _scheduleStatusRefresh() {
    _statusTimer?.cancel();
    if (!isToday || _prayers.isEmpty) return;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final boundaries = _prayers
        .map((prayer) => prayer.prayerTime)
        .where((time) => time.isAfter(now))
        .toList()
      ..add(midnight);
    boundaries.sort();

    _statusTimer = Timer(
      boundaries.first.difference(now) + const Duration(milliseconds: 250),
      () {
        notifyListeners();
        _scheduleStatusRefresh();
      },
    );
  }

  void clearError() {
    if (_state != PrayerTimesState.error) return;
    _errorMessage = null;
    _setState(
      _prayers.isNotEmpty ? PrayerTimesState.success : PrayerTimesState.initial,
    );
  }

  void _setState(PrayerTimesState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(PrayerTimesState.error);
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
