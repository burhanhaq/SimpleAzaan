import 'package:flutter/material.dart';
import 'package:simple_azaan/models/location.dart';
import 'package:simple_azaan/repositories/location_repository.dart';
import 'package:simple_azaan/service/settings_service.dart';
import 'package:simple_azaan/constants.dart';

enum LocationState {
  initial,
  loading,
  success,
  error,
}

class LocationProvider extends ChangeNotifier {
  final LocationRepository _locationRepository = LocationRepository.instance;
  final SettingsService _settingsService = SettingsService.instance;
  
  LocationState _state = LocationState.initial;
  Location? _currentLocation;
  String? _errorMessage;
  bool _useCurrentLocation = true;

  // Getters
  LocationState get state => _state;
  Location? get currentLocation => _currentLocation;
  String? get errorMessage => _errorMessage;
  bool get useCurrentLocation => _useCurrentLocation;
  bool get isLoading => _state == LocationState.loading;
  bool get hasError => _state == LocationState.error;
  
  String get displayLocation {
    if (_currentLocation != null) {
      return _currentLocation!.displayName;
    }
    return 'Unknown Location';
  }

  Future<void> initialize() async {
    try {
      _setState(LocationState.loading);
      final settings = await _settingsService.loadSettings();
      
      _useCurrentLocation = settings.useCurrentLocation;
      
      if (_useCurrentLocation) {
        await detectCurrentLocation();
      } else {
        _currentLocation = Location(
          city: settings.customCity,
          state: settings.customState,
          country: settings.customCountry,
        );
        _setState(LocationState.success);
      }
    } catch (e) {
      // Fallback to default location if initialization completely fails
      _currentLocation = Location(
        city: kDefaultCity,
        state: kDefaultState, 
        country: kDefaultCountry,
      );
      _setState(LocationState.success);
      _setError('Failed to initialize location: ${e.toString()}. Using default location.');
    }
  }

  Future<void> detectCurrentLocation() async {
    try {
      _setState(LocationState.loading);
      final result = await _locationRepository.getCurrentLocation();
      
      if (result.isSuccess && result.location != null) {
        _currentLocation = result.location;
        
        // Update settings with detected location
        await _settingsService.updateLocationSettings(
          customCity: result.location!.city,
          customState: result.location!.state,
          customCountry: result.location!.country,
        );
        
        _setState(LocationState.success);
      } else {
        // If detection fails due to permissions, switch to manual mode
        if (result.error?.contains('permission') == true || 
            result.error?.contains('denied') == true) {
          // Automatically switch to manual location mode
          _useCurrentLocation = false;
          await _settingsService.updateLocationSettings(useCurrentLocation: false);
        }
        
        // Fall back to default/saved location
        await _loadDefaultLocation();
        _setState(LocationState.success);
        _setError(result.error ?? 'Failed to detect location. Using saved location.');
      }
    } catch (e) {
      // If detection fails completely, fall back to default location  
      await _loadDefaultLocation();
      _setState(LocationState.success);
      _setError('Location detection failed: ${e.toString()}. Using saved location.');
    }
  }

  Future<void> _loadDefaultLocation() async {
    final settings = await _settingsService.loadSettings();
    _currentLocation = Location(
      city: settings.customCity,
      state: settings.customState,
      country: settings.customCountry,
    );
  }

  Future<void> setCustomLocation(String city, {String? state, String? country}) async {
    if (city.isEmpty) {
      _setError('City name cannot be empty');
      return;
    }

    try {
      _setState(LocationState.loading);
      
      final location = Location(
        city: city.trim(),
        state: state?.trim() ?? '',
        country: country?.trim() ?? 'United States',
      );
      
      _currentLocation = location;
      
      // Update settings
      await _settingsService.updateLocationSettings(
        customCity: location.city,
        customState: location.state,
        customCountry: location.country,
        useCurrentLocation: false,
      );
      
      _useCurrentLocation = false;
      _setState(LocationState.success);
    } catch (e) {
      _setError('Failed to set custom location: ${e.toString()}');
    }
  }

  Future<void> toggleLocationMode(bool useCurrentLocation) async {
    try {
      _useCurrentLocation = useCurrentLocation;
      
      await _settingsService.updateLocationSettings(
        useCurrentLocation: useCurrentLocation,
      );
      
      if (useCurrentLocation) {
        await detectCurrentLocation();
      } else {
        // Load custom location from settings
        final settings = await _settingsService.loadSettings();
        _currentLocation = Location(
          city: settings.customCity,
          state: settings.customState,
          country: settings.customCountry,
        );
        _setState(LocationState.success);
      }
    } catch (e) {
      _setError('Failed to toggle location mode: ${e.toString()}');
    }
  }

  Future<void> refreshLocation() async {
    if (_useCurrentLocation) {
      await detectCurrentLocation();
    } else {
      await initialize();
    }
  }

  void clearError() {
    if (_state == LocationState.error) {
      _errorMessage = null;
      _setState(_currentLocation != null ? LocationState.success : LocationState.initial);
    }
  }

  void _setState(LocationState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(LocationState.error);
  }

}