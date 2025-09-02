import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:simple_azaan/service/settings_service.dart';
import 'package:simple_azaan/service/notification_service.dart';
import 'package:simple_azaan/service/background_prayer_sync.dart';
import 'package:simple_azaan/providers/prayer_times_provider.dart';
import 'package:simple_azaan/providers/location_provider.dart';
import 'package:simple_azaan/providers/theme_provider.dart';
import 'package:simple_azaan/themes/app_theme.dart';
import 'package:simple_azaan/debug/mock_prayer.dart';
import 'package:simple_azaan/widgets/sleek_loading_indicator.dart';
import 'package:simple_azaan/constants.dart';

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
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.detectCurrentLocation();
      
      if (locationProvider.hasError) {
        if (mounted) {
          String message = locationProvider.errorMessage ?? kLocationDetectionFailed;
          bool isPermissionError = message.contains('permission') || message.contains('denied');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 6),
              action: isPermissionError 
                ? SnackBarAction(
                    label: 'OK', 
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }
                  )
                : null,
            ),
          );
          
          // If it's a permission error, refresh the UI to reflect manual mode
          if (isPermissionError && !locationProvider.useCurrentLocation) {
            setState(() {
              _currentSettings.useCurrentLocation = false;
            });
          }
        }
      } else if (locationProvider.currentLocation != null) {
        final location = locationProvider.currentLocation!;
        setState(() {
          _currentSettings.customCity = location.city;
          _currentSettings.customState = location.state;
          _currentSettings.customCountry = location.country;
          _cityController.text = location.city;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location detected: ${location.displayName}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kLocationDetectionFailed: ${e.toString()}')),
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
    return AppThemes.getThemeDisplayName(themeMode);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.watch<ThemeProvider>().primaryTextColor,
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
              
              final locationProvider = context.read<LocationProvider>();
              await locationProvider.toggleLocationMode(value);
              
              if (locationProvider.currentLocation != null) {
                final location = locationProvider.currentLocation!;
                setState(() {
                  _currentSettings.customCity = location.city;
                  _currentSettings.customState = location.state;
                  _currentSettings.customCountry = location.country;
                  if (!value) {
                    _cityController.text = location.city;
                  }
                });
              }
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
                  if (value.trim().isNotEmpty) {
                    final locationProvider = context.read<LocationProvider>();
                    await locationProvider.setCustomLocation(value.trim());
                    
                    if (locationProvider.currentLocation != null) {
                      final location = locationProvider.currentLocation!;
                      setState(() {
                        _currentSettings.customCity = location.city;
                        _currentSettings.customState = location.state;
                        _currentSettings.customCountry = location.country;
                      });
                    }
                    
                    if (locationProvider.hasError) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(locationProvider.errorMessage ?? 'Failed to set location')),
                        );
                      }
                    }
                  }
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
              subtitle: _isDetectingLocation 
                  ? SleekLoadingIndicator(
                      height: 2,
                      primaryColor: context.watch<ThemeProvider>().primaryTextColor,
                      backgroundColor: context.watch<ThemeProvider>().loadingBackgroundColor,
                    )
                  : const Text('Use GPS to find your current city'),
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

              // Immediately reschedule notifications to reflect the change
              final prayerTimesProvider = context.read<PrayerTimesProvider>();
              final prayerData = prayerTimesProvider.prayerData;
              final locProvider = context.read<LocationProvider>();
              final location = locProvider.currentLocation;
              if (prayerData != null && location != null) {
                // Schedules only the enabled prayers (filtering inside service)
                await NotificationService().scheduleForPrayerData(
                  prayerData,
                  cityLabel: location.displayName,
                );
              }
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
                          if (value != null && mounted) {
                            setState(() {
                              _currentSettings.themeMode = value;
                            });
                            await _settingsService.updateThemeMode(value);
                            // Update the theme provider to apply theme immediately
                            if (mounted) {
                              final themeProvider = context.read<ThemeProvider>();
                              await themeProvider.setTheme(value);
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            }
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

  Widget _buildDebugSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prayer Color Tester Section
            _buildPrayerColorTesterSection(),
            const SizedBox(height: 24),
            
            // Widget Sync Testing Section
            const Text(
              'Widget Sync Testing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test automatic widget sync functionality',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Testing widget sync...')),
                  );
                  await BackgroundPrayerSync.syncNow();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Widget sync test completed successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Widget sync test failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Test Widget Sync'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerColorTesterSection() {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Prayer Color Tester',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (themeProvider.hasDebugOverride) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DEBUG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          themeProvider.hasDebugOverride 
            ? 'Override active - UI shows ${MockPrayer.prayerDisplayNames[themeProvider.debugOverridePrayer]} colors'
            : 'Test different prayer time color schemes',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        
        // Prayer Type Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PrayerType.values.map((prayerType) {
            final isSelected = themeProvider.debugOverridePrayer == prayerType;
            final displayName = MockPrayer.prayerDisplayNames[prayerType] ?? prayerType.name;
            final colorDesc = MockPrayer.prayerColorDescriptions[prayerType] ?? '';
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    themeProvider.setDebugPrayer(prayerType);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? themeProvider.primaryColor : null,
                    foregroundColor: isSelected ? Colors.white : null,
                  ),
                  child: Text(displayName.split(' ')[0]), // Just prayer name
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Text(
                    colorDesc,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        
        // Reset Button
        if (themeProvider.hasDebugOverride) ...[
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                themeProvider.clearDebugOverride();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset to Auto'),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: themeProvider.primaryTextColor,
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
            if (kDebugMode) ...[
              _buildSectionTitle('Debug'),
              _buildDebugSection(),
            ],
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
