import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_azaan/constants.dart';
import 'package:simple_azaan/models/prayer.dart';
import 'package:simple_azaan/screens/home/date_display_widget.dart';
import 'package:simple_azaan/screens/home/location_display_widget.dart';
import 'package:simple_azaan/screens/home/go_to_today_widget.dart';
import 'package:simple_azaan/screens/home/menu_icon_widget.dart';
import 'package:simple_azaan/screens/welcome/welcome_screen.dart';
import 'package:simple_azaan/widgets/prayer_name_card.dart';
import 'package:simple_azaan/widgets/prayer_time_card.dart';
import 'package:simple_azaan/widgets/compact_prayer_view.dart';
import 'package:simple_azaan/widgets/sleek_loading_indicator.dart';
import 'package:simple_azaan/providers/location_provider.dart';
import 'package:simple_azaan/providers/prayer_times_provider.dart';
import 'package:simple_azaan/providers/theme_provider.dart';
import 'package:simple_azaan/debug/mock_prayer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  AppLifecycleState? _appLifecycleState = AppLifecycleState.resumed;
  bool _isInitialized = false;
  final PageController _pageController = PageController();
  int _currentViewIndex = 0;

  bool canShowWelcomeScreen() {
    if (_appLifecycleState != AppLifecycleState.resumed) {
      return true;
    }

    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    if (prayerTimesProvider.hasData) {
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    if (_isInitialized) return;

    final locationProvider = context.read<LocationProvider>();
    final prayerTimesProvider = context.read<PrayerTimesProvider>();

    await locationProvider.initialize();

    if (locationProvider.currentLocation != null) {
      await prayerTimesProvider
          .loadPrayerTimes(locationProvider.currentLocation!);
    }

    _isInitialized = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _appLifecycleState = state;
    });
    if (state == AppLifecycleState.resumed) {
      final prayerTimesProvider = context.read<PrayerTimesProvider>();
      if (!prayerTimesProvider.hasData) {
        _initializeProviders();
      } else {
        prayerTimesProvider.refreshPrayerTimes();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refreshPrayerTimes() {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    prayerTimesProvider.refreshPrayerTimes();
  }

  void _getCurrentDayPrayerTime() async {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    await prayerTimesProvider.goToToday();
  }

  void _getNextDayPrayerTime() {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    prayerTimesProvider.goToNextDay();
  }

  void _getPreviousDayPrayerTime() {
    final prayerTimesProvider = context.read<PrayerTimesProvider>();
    prayerTimesProvider.goToPreviousDay();
  }

  List<Prayer> _getPrayers(PrayerTimesProvider prayerTimesProvider) {
    return prayerTimesProvider.prayers;
  }

  Prayer? _getCurrentPrayer(List<Prayer> prayers) {
    for (Prayer prayer in prayers) {
      if (prayer.isCurrentPrayer) {
        return prayer;
      }
    }
    return null;
  }

  Widget _buildDebugStatusIndicator(ThemeProvider themeProvider) {
    if (!themeProvider.hasDebugOverride) return const SizedBox.shrink();
    
    final prayerType = themeProvider.debugOverridePrayer!;
    final displayName = MockPrayer.prayerDisplayNames[prayerType] ?? prayerType.name;
    
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'DEBUG: $displayName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getPrayerCards(List<Prayer> listOfPrayers) {
    return List.generate(listOfPrayers.length, (index) {
      return Column(
        children: [
          PrayerNameCard(prayer: listOfPrayers[index]),
          PrayerTimeCard(
            prayer: listOfPrayers[index],
            timeToDisplay: PrayerTimeDisplay.prayerTime,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showWelcomeScreen = canShowWelcomeScreen();
    if (showWelcomeScreen) {
      _refreshPrayerTimes();
    }

    return Consumer3<LocationProvider, PrayerTimesProvider, ThemeProvider>(
      builder: (context, locationProvider, prayerTimesProvider, themeProvider, child) {
        final prayers = _getPrayers(prayerTimesProvider);
        bool showGoToTodayWidget = prayerTimesProvider.isToday;
        
        // Update current prayer in theme provider
        final currentPrayer = _getCurrentPrayer(prayers);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          themeProvider.setCurrentPrayer(currentPrayer);
        });

        String dateDisplay = 'Current Date';
        if (prayers.isNotEmpty) {
          dateDisplay = prayers.first.getDateString();
        } else {
          dateDisplay =
              prayerTimesProvider.selectedDate.toString().split(' ')[0];
        }

        String locationDisplay = kLoadingLocation;
        if (locationProvider.hasError) {
          locationDisplay = 'Error: ${locationProvider.errorMessage}';
        } else if (locationProvider.currentLocation != null) {
          locationDisplay = locationProvider.displayLocation;
        }

        Widget mainContent = Stack(
          alignment: Alignment.center,
          children: [
                if (prayerTimesProvider.isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _getPreviousDayPrayerTime,
                        icon: const Icon(Icons.arrow_back_ios),
                        color: themeProvider.secondaryTextColor,
                        iconSize: 30,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: SleekLoadingIndicator(
                            width: 200,
                            height: 2,
                            primaryColor: themeProvider.secondaryTextColor,
                            backgroundColor: themeProvider.loadingBackgroundColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _getNextDayPrayerTime,
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: themeProvider.secondaryTextColor,
                        iconSize: 30,
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: _getPreviousDayPrayerTime,
                        icon: const Icon(Icons.arrow_back_ios),
                        color: themeProvider.secondaryTextColor,
                        iconSize: 30,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DateDisplayWidget(date: dateDisplay),
                            LocationDisplayWidget(location: locationDisplay),
                            const SizedBox(height: 10),
                            if (prayerTimesProvider.hasError)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Error loading prayer times',
                                      style: TextStyle(color: themeProvider.errorColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      prayerTimesProvider.errorMessage ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeProvider.secondaryTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _refreshPrayerTimes,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: _getPrayerCards(prayers),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _getNextDayPrayerTime,
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: themeProvider.secondaryTextColor,
                        iconSize: 30,
                      ),
                    ],
                  ),
                GoToTodayWidget(
                  offstage: showGoToTodayWidget,
                  tapHandler: _getCurrentDayPrayerTime,
                ),
            const MenuIconWidget(),
            _buildDebugStatusIndicator(themeProvider),
            WelcomeScreen(showWelcomeScreen: showWelcomeScreen),
          ],
        );

        Widget content;
        if (!showWelcomeScreen && prayers.isNotEmpty) {
          content = PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentViewIndex = index;
              });
            },
            children: [
              const CompactPrayerView(),
              mainContent,
            ],
          );
        } else {
          content = mainContent;
        }

        return Container(
          color: themeProvider.backgroundColor,
          child: SafeArea(
            child: Stack(
              children: [
                content,
                if (!showWelcomeScreen && prayers.isNotEmpty)
                  _buildViewIndicator(themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewIndicator(ThemeProvider themeProvider) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: themeProvider.secondaryTextColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Compact view indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentViewIndex == 0 ? 24 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentViewIndex == 0
                        ? themeProvider.primaryTextColor
                        : themeProvider.secondaryTextColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                // Detailed view indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentViewIndex == 1 ? 24 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentViewIndex == 1
                        ? themeProvider.primaryTextColor
                        : themeProvider.secondaryTextColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
