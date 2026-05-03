import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'dart:async';

import '../core/view_models/theme_view_model.dart';
import '../core/services/native_bridge.dart';
import '../core/utils/responsive_utils.dart';
import '../core/const/app_dimensions.dart';
import '../core/view_models/liquid_navbar_view_model.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'home_page.dart';
import 'people_page.dart';
import 'chart_page.dart';
import 'settings_page.dart';

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
      HapticFeedback.selectionClick();
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
                  GlassBackdropScope(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
                  ),
                  if (!isLargeScreen) ...[
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        child: Center(
                          child: GlassBottomBar(
                            selectedIndex: _selectedIndex,
                            onTabSelected: _onItemTapped,
                            quality: GlassQuality.premium,
                            tabs: const [
                              GlassBottomBarTab(
                                label: 'Home',
                                icon: Icon(Icons.home_rounded),
                              ),
                              GlassBottomBarTab(
                                label: 'People',
                                icon: Icon(Icons.group_rounded),
                              ),
                              GlassBottomBarTab(
                                label: 'Charts',
                                icon: Icon(Icons.auto_graph_rounded),
                              ),
                              GlassBottomBarTab(
                                label: 'Settings',
                                icon: Icon(Icons.settings_rounded),
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
