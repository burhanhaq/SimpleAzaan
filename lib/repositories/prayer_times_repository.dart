import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:simple_azaan/service/http_request.dart';
import 'package:simple_azaan/models/location.dart';
import 'package:simple_azaan/models/prayer_data.dart';
import 'package:simple_azaan/constants.dart';
import 'package:http/http.dart' as http;

enum PrayerTimesMethod {
  isna, // Islamic Society of North America (method 2)
  muslimWorldLeague, // Muslim World League (method 3)
  ummAlQura, // Umm Al-Qura University, Makkah (method 4)
  egyptianGeneral, // Egyptian General Authority of Survey (method 5)
}

extension PrayerTimesMethodExtension on PrayerTimesMethod {
  String get methodNumber {
    switch (this) {
      case PrayerTimesMethod.isna:
        return '2';
      case PrayerTimesMethod.muslimWorldLeague:
        return '3';
      case PrayerTimesMethod.ummAlQura:
        return '4';
      case PrayerTimesMethod.egyptianGeneral:
        return '5';
    }
  }

  String get displayName {
    switch (this) {
      case PrayerTimesMethod.isna:
        return 'ISNA (Islamic Society of North America)';
      case PrayerTimesMethod.muslimWorldLeague:
        return 'Muslim World League';
      case PrayerTimesMethod.ummAlQura:
        return 'Umm Al-Qura University, Makkah';
      case PrayerTimesMethod.egyptianGeneral:
        return 'Egyptian General Authority of Survey';
    }
  }
}

class PrayerTimesResult {
  final PrayerData? prayerData;
  final String? error;
  final bool isSuccess;
  final Location location;

  PrayerTimesResult.success(this.prayerData, this.location) 
    : error = null, isSuccess = true;
  PrayerTimesResult.error(this.error, this.location) 
    : prayerData = null, isSuccess = false;
}

class PrayerTimesRepository {
  static const String _apiUrl = kAladhanApiBaseUrl;
  static const String _timingsByCityEndpoint = kTimingsByCityEndpoint;
  
  final HttpRequest _httpRequest = HttpRequest();

  static PrayerTimesRepository? _instance;
  static PrayerTimesRepository get instance {
    _instance ??= PrayerTimesRepository._internal();
    return _instance!;
  }

  PrayerTimesRepository._internal();

  Future<PrayerTimesResult> getPrayerTimes({
    required Location location,
    DateTime? date,
    PrayerTimesMethod method = PrayerTimesMethod.isna,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final formattedDate = DateFormat('dd-MM-yyyy').format(targetDate);
      final url = '$_apiUrl$_timingsByCityEndpoint/$formattedDate';
      
      final params = _buildQueryParams(location, method);
      final fullUrl = '$url?$params';

      final headers = {
        'Content-type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      final response = await _httpRequest.getRequest(fullUrl, headers);
      final jsonResponse = _parseResponse(response);
      
      final prayerData = PrayerData.fromAlAdhanApi(jsonResponse);
      return PrayerTimesResult.success(prayerData, location);
      
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = '$kNoInternetConnection. Please check your network.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('Error 404')) {
        errorMessage = '$kLocationNotFound. Please check the city name.';
      } else if (e.toString().contains('Error 500')) {
        errorMessage = kServerError;
      } else {
        errorMessage = 'Failed to fetch prayer times: ${e.toString()}';
      }
      return PrayerTimesResult.error(errorMessage, location);
    }
  }

  Future<PrayerTimesResult> getTodayPrayerTimes({
    required Location location,
    PrayerTimesMethod method = PrayerTimesMethod.isna,
  }) async {
    return getPrayerTimes(
      location: location,
      date: DateTime.now(),
      method: method,
    );
  }

  String _buildQueryParams(Location location, PrayerTimesMethod method) {
    final params = <String>[];
    
    params.add('iso8601=true');
    
    if (location.city.isNotEmpty) {
      params.add('city=${Uri.encodeComponent(location.city)}');
    }
    
    if (location.state.isNotEmpty) {
      params.add('state=${Uri.encodeComponent(location.state)}');
    }
    
    if (location.country.isNotEmpty) {
      params.add('country=${Uri.encodeComponent(location.country)}');
    }
    
    params.add('method=${method.methodNumber}');
    
    return params.join('&');
  }

  dynamic _parseResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body.toString());
      case 400:
        throw Exception('Error 400: Bad request - Invalid location parameters');
      case 404:
        throw Exception('Error 404: $kLocationNotFound');
      case 500:
        throw Exception('Error 500: $kServerError');
      default:
        throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  // Cache management methods for future enhancement
  static const Duration _cacheTimeout = Duration(hours: 1);
  final Map<String, CacheEntry> _cache = {};

  String _getCacheKey(Location location, DateTime date, PrayerTimesMethod method) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return '${location.city}_${location.state}_${location.country}_${dateStr}_${method.methodNumber}';
  }

  Future<PrayerTimesResult> getPrayerTimesWithCache({
    required Location location,
    DateTime? date,
    PrayerTimesMethod method = PrayerTimesMethod.isna,
  }) async {
    final targetDate = date ?? DateTime.now();
    final cacheKey = _getCacheKey(location, targetDate, method);
    final cacheEntry = _cache[cacheKey];

    // Check if cache is valid
    if (cacheEntry != null && 
        DateTime.now().difference(cacheEntry.timestamp) < _cacheTimeout) {
      return PrayerTimesResult.success(cacheEntry.prayerData, location);
    }

    // Fetch new data
    final result = await getPrayerTimes(
      location: location,
      date: targetDate,
      method: method,
    );

    // Cache successful results
    if (result.isSuccess && result.prayerData != null) {
      _cache[cacheKey] = CacheEntry(result.prayerData!, DateTime.now());
    }

    return result;
  }

  void clearCache() {
    _cache.clear();
  }
}

class CacheEntry {
  final PrayerData prayerData;
  final DateTime timestamp;

  CacheEntry(this.prayerData, this.timestamp);
}