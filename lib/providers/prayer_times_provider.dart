import 'package:flutter/material.dart';
import 'package:simple_azaan/models/location.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/repositories/prayer_times_repository.dart';
import 'package:simple_azaan/service/notification_service.dart';
import 'package:simple_azaan/service/widget_sync.dart';

enum PrayerTimesState {
  initial,
  loading,
  success,
  error,
}

class PrayerTimesProvider extends ChangeNotifier {
  final PrayerTimesRepository _repository = PrayerTimesRepository.instance;
  
  PrayerTimesState _state = PrayerTimesState.initial;
  List<Prayer> _prayers = [];
  DateTime _selectedDate = DateTime.now();
  Location? _currentLocation;
  String? _errorMessage;
  PrayerData? _prayerData;

  // Getters
  PrayerTimesState get state => _state;
  List<Prayer> get prayers => _prayers;
  DateTime get selectedDate => _selectedDate;
  Location? get currentLocation => _currentLocation;
  String? get errorMessage => _errorMessage;
  PrayerData? get prayerData => _prayerData;
  bool get isLoading => _state == PrayerTimesState.loading;
  bool get hasError => _state == PrayerTimesState.error;
  bool get hasData => _prayers.isNotEmpty;

  Prayer? get fajr => _prayers.isNotEmpty ? _prayers[0] : null;
  Prayer? get sunrise => _prayers.length > 1 ? _prayers[1] : null;
  Prayer? get zuhr => _prayers.length > 2 ? _prayers[2] : null;
  Prayer? get asr => _prayers.length > 3 ? _prayers[3] : null;
  Prayer? get maghrib => _prayers.length > 4 ? _prayers[4] : null;
  Prayer? get isha => _prayers.length > 5 ? _prayers[5] : null;

  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  Prayer? get currentPrayer {
    return _prayers.where((prayer) => prayer.isCurrentPrayer).firstOrNull;
  }

  Prayer? get nextPrayer {
    final remaining = _prayers.where((prayer) => !prayer.hasPrayerPassed);
    return remaining.isNotEmpty ? remaining.first : null;
  }

  Future<void> loadPrayerTimes(Location location, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    
    if (_currentLocation == location && 
        _selectedDate.day == targetDate.day &&
        _selectedDate.month == targetDate.month &&
        _selectedDate.year == targetDate.year &&
        _state == PrayerTimesState.success) {
      return; // Data already loaded
    }

    try {
      _setState(PrayerTimesState.loading);
      _currentLocation = location;
      _selectedDate = targetDate;

      final result = await _repository.getPrayerTimesWithCache(
        location: location,
        date: targetDate,
      );

      if (result.isSuccess && result.prayerData != null) {
        _prayerData = result.prayerData;
        _updatePrayersFromData(result.prayerData!);
        
        // Sync to iOS widget if it's today's data
        if (_isToday(targetDate)) {
          await WidgetSync.pushPrayerDataToWidget(result.prayerData!);
          
          // Schedule notifications
          NotificationService().scheduleForPrayerData(
            result.prayerData!, 
            cityLabel: location.displayName,
          );
        }
        
        _setState(PrayerTimesState.success);
      } else {
        _setError(result.error ?? 'Failed to load prayer times');
      }
    } catch (e) {
      _setError('Error loading prayer times: ${e.toString()}');
    }
  }

  Future<void> refreshPrayerTimes() async {
    if (_currentLocation != null) {
      // Clear cache for current location/date combination
      _repository.clearCache();
      await loadPrayerTimes(_currentLocation!, date: _selectedDate);
    }
  }

  Future<void> goToNextDay() async {
    if (_currentLocation != null) {
      final nextDay = _selectedDate.add(const Duration(days: 1));
      await loadPrayerTimes(_currentLocation!, date: nextDay);
    }
  }

  Future<void> goToPreviousDay() async {
    if (_currentLocation != null) {
      final previousDay = _selectedDate.subtract(const Duration(days: 1));
      await loadPrayerTimes(_currentLocation!, date: previousDay);
    }
  }

  Future<void> goToToday() async {
    if (_currentLocation != null) {
      await loadPrayerTimes(_currentLocation!, date: DateTime.now());
    }
  }

  void _updatePrayersFromData(PrayerData prayerData) {
    _prayers = [
      Prayer('Fajr', prayerData.time1),
      Prayer('Sunrise', prayerData.time2),
      Prayer('Zuhr', prayerData.time3),
      Prayer('Asr', prayerData.time4),
      Prayer('Maghrib', prayerData.time5),
      Prayer('Isha', prayerData.time6),
    ];

    // Update current prayer status
    _updateCurrentPrayerStatus();
  }

  void _updateCurrentPrayerStatus() {
    // Reset all prayers
    for (var prayer in _prayers) {
      prayer.isCurrentPrayer = false;
    }

    if (!_isToday(_selectedDate)) {
      return; // Don't mark current prayer for past/future dates
    }

    // Find next prayer
    final nextPrayerIndex = _prayers.indexWhere(
      (prayer) => !prayer.hasPrayerPassed,
    );

    // Mark the next upcoming prayer as current
    if (nextPrayerIndex >= 0) {
      _prayers[nextPrayerIndex].isCurrentPrayer = true;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  void clearError() {
    if (_state == PrayerTimesState.error) {
      _errorMessage = null;
      _setState(_prayers.isNotEmpty ? PrayerTimesState.success : PrayerTimesState.initial);
    }
  }

  void _setState(PrayerTimesState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(PrayerTimesState.error);
  }

}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}