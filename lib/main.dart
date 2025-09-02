import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_azaan/screens/home/home_screen.dart';
import 'package:simple_azaan/service/notification_service.dart';
import 'package:simple_azaan/service/background_prayer_sync.dart';
import 'package:simple_azaan/providers/location_provider.dart';
import 'package:simple_azaan/providers/prayer_times_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize iOS local notifications and request permissions
  await NotificationService().init();
  
  // Initialize background prayer sync for automatic widget updates
  await BackgroundPrayerSync.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProxyProvider<LocationProvider, PrayerTimesProvider>(
          create: (_) => PrayerTimesProvider(),
          update: (context, locationProvider, prayerTimesProvider) {
            // When location changes, load new prayer times
            if (locationProvider.currentLocation != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                prayerTimesProvider
                    ?.loadPrayerTimes(locationProvider.currentLocation!);
              });
            }
            return prayerTimesProvider ?? PrayerTimesProvider();
          },
        ),
      ],
      child: Material(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Simple Azaan',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
