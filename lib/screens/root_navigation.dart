import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../view_models/theme_view_model.dart';
import '../services/native_bridge.dart';
import 'dart:async';
import 'home_page.dart';
import 'people_page.dart';
import 'chart_page.dart';
import 'settings_page.dart';
import '../utils/responsive_utils.dart';

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  StreamSubscription<String>? _uiEventSubscription;

  // Cache screens to avoid rebuilds and glitching
  final List<Widget> _screens = [
    const HomePage(),
    const PeopleTab(),
    ChartPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _uiEventSubscription = NativeBridge.uiEvents.listen((event) {
      if (event == 'SHOW_ADD_INCOME' || event == 'SHOW_ADD_EXPENSE') {
        _onItemTapped(0); // Switch to Home tab
      }
    });
  }

  @override
  void dispose() {
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
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      HapticFeedback.lightImpact();
      // Using jumpToPage for snappier, non-glitchy tab switching
      _pageController.jumpToPage(index);
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
              indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    scrollBehavior: const MaterialScrollBehavior(),
                    children: _screens,
                  ),
                  if (!isLargeScreen) ...[

                    Positioned(
                      bottom: 30,
                      left: 60,
                      right: 60,
                      height: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(

                            decoration: BoxDecoration(
                              color: theme.primaryColor
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: theme.primaryColor.withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 65,
                      right: 60,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBNBItem(Icons.home, 0, 'Home'),
                          _buildBNBItem(Icons.person, 1, 'People'),
                          _buildBNBItem(Icons.auto_graph, 2, 'Charts'),
                          _buildBNBItem(Icons.settings_outlined, 3, 'Settings'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Widget _buildBNBItem(IconData icon, int index, String label) {
  //   final isSelected = _selectedIndex == index;
  //   final theme = Theme.of(context);
  //
  //   return ZoomTapAnimation(
  //     onTap: () => _onItemTapped(index),
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 300),
  //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(32),
  //       ),
  //       child: isSelected
  //           ? LiquidGlassLayer(
  //         settings:const LiquidGlassSettings(
  //           thickness: 50,
  //           blur: 2,
  //           lightAngle: 4
  //         ),
  //             child: LiquidGlass(
  //                       shape:const LiquidRoundedSuperellipse(
  //               borderRadius: 32),
  //                       child: Container(
  //             padding:
  //             const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //             decoration: BoxDecoration(
  //               color:
  //               theme.colorScheme.primary.withValues(alpha: 0.11),
  //               // borderRadius: BorderRadius.circular(32),
  //               // border: Border.all(
  //               //   color: theme.colorScheme.primary.withValues(alpha: 0.4),
  //               //   width: 0.6,
  //               // ),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 AnimatedSwitcher(
  //                   duration: const Duration(milliseconds: 300),
  //                   child: Icon(
  //                     icon,
  //                     key: ValueKey(isSelected),
  //                     color: isSelected
  //                         ? theme.colorScheme.primary
  //                         : Colors.grey.shade500,
  //                     size: isSelected ? 22 : 20,
  //                   ),
  //                 ),
  //                 SizedBox(height: 4),
  //                 AnimatedDefaultTextStyle(
  //                   duration: const Duration(milliseconds: 300),
  //                   style: TextStyle(
  //                     color: isSelected
  //                         ? theme.colorScheme.primary
  //                         : Colors.grey.shade600,
  //                     fontSize: isSelected
  //                         ?12
  //                         :10,
  //                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //                   ),
  //                   child: Text(label),
  //                 ),
  //
  //               ],
  //             ),
  //                       ),
  //                     ),
  //           )
  //           : Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           AnimatedSwitcher(
  //             duration: const Duration(milliseconds: 400),
  //             child: Icon(
  //               icon,
  //               key: ValueKey(isSelected),
  //               color: isSelected
  //                   ? theme.colorScheme.primary
  //                   : Colors.grey.shade500,
  //               size: isSelected ? 22 : 20,
  //             ),
  //           ),
  //           SizedBox(height: 4),
  //           AnimatedDefaultTextStyle(
  //             duration: const Duration(milliseconds: 400),
  //             style: TextStyle(
  //               color: isSelected
  //                   ? theme.colorScheme.primary
  //                   : Colors.grey.shade600,
  //               fontSize: isSelected
  //                   ?12
  //                   :10,
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //             ),
  //             child: Text(label),
  //           ),
  //
  //         ],
  //       ),
  //     ),
  //   );
  // }

//
  Widget _buildBNBItem(IconData icon, int index, String label) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    return AnimatedContainer(
      alignment: Alignment.center,
      padding:
          EdgeInsets.symmetric(vertical: 6, horizontal:2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ZoomTapAnimation(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(36),
            // shape: BoxShape.circle,
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade500,
                  size: isSelected ? 22 : 22,
                ),
              ),
                SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade600,
                    fontSize: isSelected
                    ?12
                    :12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text(label),
                ),

            ],
          ),
      ),
    ),
  );
}
}
