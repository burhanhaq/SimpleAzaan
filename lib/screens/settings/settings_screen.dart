import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:simple_azaan/service/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService.instance;
  late AppSettings _currentSettings;
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = true;
  bool _isDetectingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _currentSettings = await _settingsService.loadSettings();
      _cityController.text = _currentSettings.customCity;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _isDetectingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final city = placemark.locality ?? placemark.subAdministrativeArea ?? '';
        final state = placemark.administrativeArea ?? '';
        final country = placemark.country ?? '';

        if (city.isNotEmpty) {
          setState(() {
            _currentSettings.customCity = city;
            _currentSettings.customState = state;
            _currentSettings.customCountry = country;
            _cityController.text = city;
          });

          await _settingsService.updateLocationSettings(
            customCity: city,
            customState: state,
            customCountry: country,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Location detected: $city, $state')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to detect location')),
        );
      }
    } finally {
      setState(() {
        _isDetectingLocation = false;
      });
    }
  }

  String _getPrayerDisplayName(PrayerType prayerType) {
    switch (prayerType) {
      case PrayerType.fajr:
        return 'Fajr';
      case PrayerType.sunrise:
        return 'Sunrise';
      case PrayerType.zuhr:
        return 'Zuhr';
      case PrayerType.asr:
        return 'Asr';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isha';
    }
  }

  String _getThemeDisplayName(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.dual:
        return 'Dual';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Use Current Location'),
            subtitle: const Text('Automatically detect your location for prayer times'),
            value: _currentSettings.useCurrentLocation,
            onChanged: (value) async {
              setState(() {
                _currentSettings.useCurrentLocation = value;
              });
              await _settingsService.updateLocationSettings(
                useCurrentLocation: value,
              );
            },
          ),
          if (!_currentSettings.useCurrentLocation) ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Custom City'),
              subtitle: TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  hintText: 'Enter city name',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) async {
                  setState(() {
                    _currentSettings.customCity = value;
                  });
                  await _settingsService.updateLocationSettings(
                    customCity: value,
                  );
                },
              ),
            ),
          ],
          if (_currentSettings.useCurrentLocation) ...[
            const Divider(height: 1),
            ListTile(
              leading: _isDetectingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.location_searching),
              title: const Text('Detect Location'),
              subtitle: const Text('Use GPS to find your current city'),
              onTap: _isDetectingLocation ? null : _detectCurrentLocation,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: PrayerType.values.map((prayerType) {
          return SwitchListTile(
            title: Text(_getPrayerDisplayName(prayerType)),
            subtitle: Text('Receive notifications for ${_getPrayerDisplayName(prayerType).toLowerCase()}'),
            value: _currentSettings.notificationSettings[prayerType] ?? false,
            onChanged: (value) async {
              setState(() {
                _currentSettings.notificationSettings[prayerType] = value;
              });
              await _settingsService.updateNotificationSetting(prayerType, value);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: const Text('App Theme'),
            subtitle: Text('Current: ${_getThemeDisplayName(_currentSettings.themeMode)}'),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Theme'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AppThemeMode.values.map((themeMode) {
                      return RadioListTile<AppThemeMode>(
                        title: Text(_getThemeDisplayName(themeMode)),
                        value: themeMode,
                        groupValue: _currentSettings.themeMode,
                        onChanged: (AppThemeMode? value) async {
                          if (value != null) {
                            setState(() {
                              _currentSettings.themeMode = value;
                            });
                            await _settingsService.updateThemeMode(value);
                            if (mounted) Navigator.of(context).pop();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Location'),
            _buildLocationSection(),
            _buildSectionTitle('Prayer Notifications'),
            _buildNotificationSection(),
            _buildSectionTitle('Appearance'),
            _buildThemeSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}