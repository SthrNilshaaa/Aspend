import 'dart:ui';
import 'package:aspends_tracker/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/services/native_bridge.dart';
import 'dart:async';
import 'home_page.dart';
import 'people_page.dart';
import 'chart_page.dart';
import 'settings_page.dart';
import '../core/utils/responsive_utils.dart';
import '../core/const/app_dimensions.dart';
import '../shared/widgets/native_glass_navbar.dart';

import '../core/view_models/liquid_navbar_view_model.dart';

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  StreamSubscription<String>? _uiEventSubscription;

  // Cache screens to avoid rebuilds and glitching
  final List<Widget> _screens = [
    const HomePage(),
    const PeopleTab(),
    const ChartPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();

    _uiEventSubscription = NativeBridge.uiEvents.listen((event) {
      if (event == 'SHOW_ADD_INCOME' || event == 'SHOW_ADD_EXPENSE') {
        _onItemTapped(0); // Switch to Home tab
      }
    });

    WidgetsBinding.instance.addObserver(this);
    // Initial check
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

    final isLargeScreen = !ResponsiveUtils.isMobile(context);

    return ChangeNotifierProvider(
      create: (_) => LiquidNavbarViewModel(),
      child: Scaffold(
        body: Row(
          children: [
            if (isLargeScreen)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.selected,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  indicatorColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  minWidth: 80,
                  selectedIconTheme: IconThemeData(
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 24,
                  ),
                  selectedLabelTextStyle: GoogleFonts.dmSans(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: GoogleFonts.dmSans(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 12,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.group_outlined),
                      selectedIcon: Icon(Icons.group_rounded),
                      label: Text('People'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.auto_graph_outlined),
                      selectedIcon: Icon(Icons.auto_graph_rounded),
                      label: Text('Charts'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_rounded),
                      label: Text('Settings'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                  if (!isLargeScreen) ...[
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isDark
                                  ? Colors.black.withOpacity(
                                      0.05) //theme.primaryColor.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            end: Alignment.topCenter,
                            begin: Alignment.bottomCenter,
                            stops: const [0.0, 0.6],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        child: Center(
                          child: NativeGlassNavBar(
                            currentIndex: _selectedIndex,
                            onTap: _onItemTapped,
                            tabs: const [
                              NativeGlassNavBarItem(
                                label: 'Home',
                                symbol: 'house',
                              ),
                              NativeGlassNavBarItem(
                                label: 'People',
                                symbol: 'person.2',
                              ),
                              NativeGlassNavBarItem(
                                label: 'Charts',
                                symbol: 'chart.xyaxis.line',
                              ),
                              NativeGlassNavBarItem(
                                label: 'Settings',
                                symbol: 'gear',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
