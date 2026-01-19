import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../view_models/theme_view_model.dart';
import '../services/native_bridge.dart';
import 'dart:async';
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

    return Scaffold(
        body: FadeTransition(
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
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.1),
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
                _buildBNBItem(Icons.home_outlined, 0, 'Home'),
                _buildBNBItem(Icons.person, 1, 'Person'),
                _buildBNBItem(Icons.auto_graph, 2, 'Chart'),
                _buildBNBItem(Icons.settings_outlined, 3, 'Setting'),
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
        ),
      ),
    );
  }
}
