import 'dart:ui';
import 'package:aspends_tracker/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

    final isLargeScreen = !ResponsiveUtils.isMobile(context);

    return Scaffold(
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.selected,
              backgroundColor: theme.scaffoldBackgroundColor,
              indicatorColor: theme.colorScheme.primary.withOpacity(0.2),
              selectedIconTheme:
                  IconThemeData(color: theme.colorScheme.primary),
              unselectedIconTheme: IconThemeData(color: Colors.grey.shade600),
              selectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.grey.shade600,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: Text('People'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_graph_outlined),
                  selectedIcon: Icon(Icons.auto_graph),
                  label: Text('Charts'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
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
                    height: 120,
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
                    left: 16,
                    right: 16,
                    bottom: 1,
                    child: SafeArea(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusXLarge),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                    ? Colors.white.withValues(alpha: 0.03)
                                    : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusXLarge),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.02),
                                width: 1.0,
                              ),
                            ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                      child: _buildBNBItem(Icons.home_rounded,
                                          0, 'Home', isDark)),
                                  Flexible(
                                      child: _buildBNBItem(Icons.group_rounded,
                                          1, 'People', isDark)),
                                  Flexible(
                                      child: _buildBNBItem(
                                          Icons.auto_graph_rounded,
                                          2,
                                          'Charts',
                                          isDark)),
                                  Flexible(
                                      child: _buildBNBItem(
                                          Icons.settings_rounded,
                                          3,
                                          'Setting',
                                          isDark)),
                                ],
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildBNBItem(IconData icon, int index, String label, bool isDark) {
    final isSelected = _selectedIndex == index;

    return ZoomTapAnimation(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
          color: isSelected
              // ? theme.colorScheme.primary.withValues(alpha: 0.4)
              ? AppColors.accentGreen.withOpacity(0.2)
              : Colors.transparent,
          // border: Border.all(
          //   color: isSelected
          //       //? theme.colorScheme.primary.withValues(alpha: 0.3)
          //       ? AppColors.accentGreen.withOpacity(0.3)
          //   : Colors.transparent,
          //   width: 1,
          // ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(
                        0.015), //theme.colorScheme.primary.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? AppColors.accentGreen
                    : (isDark ? Colors.white54 : Colors.black54),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.accentGreen
                    : (isDark ? Colors.white54 : Colors.black54),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: const TextScaler.linear(
                  1.0), // Prevent drastic layout breaks on extreme font scaling
            ),
          ],
        ),
      ),
    );
  }
}
