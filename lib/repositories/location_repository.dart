import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:simple_azaan/models/location.dart' as app_location;
import 'package:simple_azaan/constants.dart';

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  notDetermined,
}

class LocationResult {
  final app_location.Location? location;
  final String? error;
  final bool isSuccess;

  LocationResult.success(this.location) : error = null, isSuccess = true;
  LocationResult.error(this.error) : location = null, isSuccess = false;
}

class LocationRepository {
  static LocationRepository? _instance;
  static LocationRepository get instance {
    _instance ??= LocationRepository._internal();
    return _instance!;
  }

  LocationRepository._internal();

  Future<LocationPermissionState> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionState.granted;
        case LocationPermission.denied:
          return LocationPermissionState.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionState.deniedForever;
        case LocationPermission.unableToDetermine:
          return LocationPermissionState.notDetermined;
      }
    } catch (e) {
      return LocationPermissionState.notDetermined;
    }
  }

  Future<LocationPermissionState> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionState.granted;
        case LocationPermission.denied:
          return LocationPermissionState.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionState.deniedForever;
        case LocationPermission.unableToDetermine:
          return LocationPermissionState.notDetermined;
      }
    } catch (e) {
      return LocationPermissionState.notDetermined;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.error('$kLocationServicesDisabled. Please enable them in settings.');
      }

      // Check and request permissions with better handling
      LocationPermissionState permission = await checkPermission();
      
      if (permission == LocationPermissionState.denied || 
          permission == LocationPermissionState.notDetermined) {
        permission = await requestPermission();
      }

      if (permission != LocationPermissionState.granted) {
        switch (permission) {
          case LocationPermissionState.denied:
            return LocationResult.error('Location access was denied. To use automatic location detection, please enable location permissions for this app in your device settings.');
          case LocationPermissionState.deniedForever:
            return LocationResult.error('Location access is permanently disabled. Please go to your device settings > Apps > Simple Azaan > Permissions and enable Location.');
          case LocationPermissionState.notDetermined:
            return LocationResult.error('Location permission could not be determined. Please check your device location settings.');
          default:
            return LocationResult.error('Location access is required for automatic location detection.');
        }
      }

      // Get position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address from coordinates
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return LocationResult.error('Unable to determine address from location.');
      }

      final placemark = placemarks.first;
      final city = placemark.locality ?? 
                  placemark.subAdministrativeArea ?? 
                  placemark.administrativeArea ?? '';
      final state = placemark.administrativeArea ?? '';
      final country = placemark.country ?? kDefaultCountry;

      if (city.isEmpty) {
        return LocationResult.error('Unable to determine city from location.');
      }

      final location = app_location.Location(
        city: city,
        state: state,
        country: country,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return LocationResult.success(location);
    } catch (e) {
      if (e is LocationServiceDisabledException) {
        return LocationResult.error('Location services are disabled. Please enable them in settings.');
      } else if (e is PermissionDeniedException) {
        return LocationResult.error('Location permission denied.');
      } else if (e.toString().contains('timeout')) {
        return LocationResult.error('$kLocationDetectionTimeout. Please try again.');
      } else {
        return LocationResult.error('$kLocationDetectionFailed: ${e.toString()}');
      }
    }
  }

  Future<LocationResult> getLocationFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        return LocationResult.error('Address not found.');
      }

      final location = locations.first;
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) {
        return LocationResult.error('Unable to resolve address details.');
      }

      final placemark = placemarks.first;
      final city = placemark.locality ?? 
                  placemark.subAdministrativeArea ?? 
                  placemark.administrativeArea ?? '';
      final state = placemark.administrativeArea ?? '';
      final country = placemark.country ?? kDefaultCountry;

      final locationModel = app_location.Location(
        city: city.isNotEmpty ? city : address,
        state: state,
        country: country,
        latitude: location.latitude,
        longitude: location.longitude,
      );

      return LocationResult.success(locationModel);
    } catch (e) {
      return LocationResult.error('Failed to resolve address: ${e.toString()}');
    }
  }
}