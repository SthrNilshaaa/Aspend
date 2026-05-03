import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import 'root_navigation.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/services/transaction_detection_service.dart';
import '../core/services/native_bridge.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_constants.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<IntroSlide> _slides = [
    IntroSlide(
      title: AppStrings.welcomeTitle,
      subtitle: AppStrings.welcomeSubtitle,
      description: AppStrings.welcomeDesc,
      icon: Icons.account_balance_wallet,
      color: Colors.green,
    ),
    IntroSlide(
      title: AppStrings.smartTrackingTitle,
      subtitle: AppStrings.smartTrackingSubtitle,
      description: AppStrings.smartTrackingDesc,
      icon: Icons.analytics,
      color: Colors.blue,
    ),
    IntroSlide(
      title: AppStrings.peopleTrackingTitle,
      subtitle: AppStrings.peopleTrackingSubtitle,
      description: AppStrings.peopleTrackingDesc,
      icon: Icons.people,
      color: Colors.green,
    ),
    IntroSlide(
      title: AppStrings.analyticsTitle,
      subtitle: AppStrings.analyticsSubtitle,
      description: AppStrings.analyticsDesc,
      icon: Icons.pie_chart,
      color: Colors.orange,
    ),
    IntroSlide(
      title: AppStrings.offlineTitle,
      subtitle: AppStrings.offlineSubtitle,
      description: AppStrings.offlineDesc,
      icon: Icons.security,
      color: Colors.purple,
    ),
    IntroSlide(
      title: AppStrings.autoDetectTitle,
      subtitle: AppStrings.autoDetectSubtitle,
      description: AppStrings.autoDetectDesc,
      icon: Icons.auto_awesome,
      color: Colors.amber,
    ),
    IntroSlide(
      title: AppStrings.readyTitle,
      subtitle: AppStrings.readySubtitle,
      description: AppStrings.readyDesc,
      icon: Icons.rocket_launch,
      color: Colors.indigo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentPage = page;
    });
  }

  void _completeIntro() async {
    HapticFeedback.lightImpact();
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                quality: GlassQuality.premium,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.settingUpApp,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Use Hive to mark intro as completed
      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put(AppConstants.introCompletedKey, true);
      await box.put('introCompletedAt', DateTime.now().millisecondsSinceEpoch);

      // Show auto-detection setup dialog
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        await _showAutoDetectionSetup(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Error',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Failed to complete setup. Please try again.',
                style: GoogleFonts.dmSans(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _completeIntro(); // Retry
                  },
                  child: Text(
                    'Retry',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _showAutoDetectionSetup(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = context.read<ThemeViewModel>().isDarkMode;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          quality: GlassQuality.premium,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enable Auto Detection?',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Would you like to enable automatic transaction detection?',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureItem('🔔 Monitor notifications',
                  'Detects banking transactions automatically'),
              _buildFeatureItem('💰 Smart categorization',
                  'Categorizes transactions based on bank keywords'),
              _buildFeatureItem('⚡ Real-time detection',
                  'Captures transactions as they happen'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can enable this later in Settings if you skip now.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(
                      'Skip for now',
                      style: GoogleFonts.dmSans(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      _navigateToMainApp();
                    },
                  ),
                  const SizedBox(width: 12),
                  ZoomTapAnimation(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      try {
                        await NativeBridge.requestBatteryOptimization();
                        await NativeBridge.requestNotificationPermission();
                        await TransactionDetectionService.setEnabled(true);

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        _navigateToMainApp();
                      } catch (e) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        _navigateToMainApp();
                      }
                    },
                    child: GlassCard(
                      width: 100,
                      height: 44,
                      padding: EdgeInsets.zero,
                      child: Container(
                        color: Colors.amber.withValues(alpha: 0.8),
                        child: Center(
                          child: Text(
                            "Enable",
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMainApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RootNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 50, right: 20),
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _completeIntro();
                  },
                  child: Text(
                    AppStrings.skip,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _buildSlide(slide, theme);
                },
              ),
            ),

            // Page indicator and buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _slides[index].color
                              : theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Back',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),

                      // Next/Get Started button
                      ZoomTapAnimation(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeIntro();
                          }
                        },
                        child: GlassCard(
                          width: 160,
                          height: 56,
                          padding: EdgeInsets.zero,
                          child: Container(
                            color: _slides[_currentPage].color.withValues(alpha: 0.8),
                            child: Center(
                              child: Text(
                                _currentPage < _slides.length - 1
                                    ? AppStrings.next
                                    : AppStrings.getStarted,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(IntroSlide slide, ThemeData theme) {
    final useAdaptive = context.watch<ThemeViewModel>().useAdaptiveColor;
    final primary = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with glass effect
          // Icon container with glass effect
          GlassContainer(
            width: 120,
            height: 120,
            shape: const LiquidOval(),
            quality: GlassQuality.premium,
            child: Center(
              child: Icon(
                slide.icon,
                size: 60,
                color: useAdaptive ? primary : slide.color,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            slide.title,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            slide.subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: slide.color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            slide.description,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class IntroSlide {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  IntroSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
