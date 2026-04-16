import 'dart:ui';
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../view_models/theme_view_model.dart';
import '../services/native_bridge.dart';
=======
import 'package:aspends_tracker/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/services/native_bridge.dart';
>>>>>>> master
import 'dart:async';
import 'home_page.dart';
import 'people_page.dart';
import 'chart_page.dart';
import 'settings_page.dart';
<<<<<<< HEAD
=======
import '../core/utils/responsive_utils.dart';
import '../core/const/app_dimensions.dart';
import '../shared/widgets/native_glass_navbar.dart';

import '../core/view_models/liquid_navbar_view_model.dart';
>>>>>>> master

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation>
<<<<<<< HEAD
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
=======
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
>>>>>>> master
  StreamSubscription<String>? _uiEventSubscription;

  // Cache screens to avoid rebuilds and glitching
  final List<Widget> _screens = [
<<<<<<< HEAD
    HomePage(),
    const PeopleTab(),
    ChartPage(),
=======
    const HomePage(),
    const PeopleTab(),
    const ChartPage(),
>>>>>>> master
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _pageController = PageController(initialPage: _selectedIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
=======
>>>>>>> master

    _uiEventSubscription = NativeBridge.uiEvents.listen((event) {
      if (event == 'SHOW_ADD_INCOME' || event == 'SHOW_ADD_EXPENSE') {
        _onItemTapped(0); // Switch to Home tab
      }
    });
<<<<<<< HEAD
=======

    WidgetsBinding.instance.addObserver(this);
    // Initial check
>>>>>>> master
  }

  @override
  void dispose() {
<<<<<<< HEAD
    _pageController.dispose();
    _animationController.dispose();
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      HapticFeedback.selectionClick();
    }
=======
    _uiEventSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
>>>>>>> master
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
<<<<<<< HEAD
      HapticFeedback.lightImpact();
      // Using jumpToPage for snappier, non-glitchy tab switching
      _pageController.jumpToPage(index);
=======
      // HapticFeedback.lightImpact();
>>>>>>> master
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

<<<<<<< HEAD
    return Scaffold(
        body: FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _screens,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            scrollBehavior: MaterialScrollBehavior(),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 22,
            right: 22,
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBNBItem(Icons.home_outlined, 0, "Home"),
                _buildBNBItem(Icons.person, 1, "Person"),
                _buildBNBItem(Icons.auto_graph, 2, "Chart"),
                _buildBNBItem(Icons.settings_outlined, 3, "Setting"),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBNBItem(IconData icon, int index, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    return AnimatedContainer(
      alignment: Alignment.center,
      padding:
          EdgeInsets.symmetric(vertical: 8, horizontal: isSelected ? 10 : 15),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ZoomTapAnimation(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 0.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade600,
                  size: isSelected ? 22 : 20,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(label),
                ),
              ],
            ],
          ),
=======
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
>>>>>>> master
        ),
      ),
    );
  }
}
