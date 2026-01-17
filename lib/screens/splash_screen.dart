import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../view_models/theme_view_model.dart';
import '../utils/responsive_utils.dart';
import 'intro_page.dart';
import 'root_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    _checkInitialLaunch();
  }

  Future<void> _checkInitialLaunch() async {
    final Uri? uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    bool isWidgetLaunch = uri != null && uri.host == 'addTransaction';

    final box = await Hive.openBox('settings');
    final introCompleted = box.get('introCompleted', defaultValue: false);
    final appLockEnabled = box.get('appLockEnabled', defaultValue: false);

    // Minimum splash duration - always show the splash screen so the user feels the "app opening"
    // For widget launch, we can make it slightly faster (1s) but not instant.
    await Future.delayed(Duration(seconds: isWidgetLaunch ? 1 : 2));

    // If widget launch, we might want to skip app lock for convenience,
    // but the user's flow says Splash > Home > Sheet, so standard auth is safer.
    if (appLockEnabled && !isWidgetLaunch) {
      try {
        final localAuth = LocalAuthentication();
        final canCheckDeviceSupport = await localAuth.isDeviceSupported();

        if (canCheckDeviceSupport) {
          final didAuthenticate = await localAuth.authenticate(
            localizedReason: 'Authenticate to access Aspends Tracker',
            biometricOnly: false,
            persistAcrossBackgrounding: true,
          );
          if (!didAuthenticate) {
            return;
          }
        }
      } catch (e) {
        debugPrint('SplashScreen: Authentication error: $e');
      }
    }

    if (mounted) {
      _navigateToTarget(
          introCompleted ? const RootNavigation() : const IntroPage());
    }
  }

  void _navigateToTarget(Widget target) {
    if (_isNavigated) return;
    _isNavigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final useAdaptive = themeViewModel.useAdaptiveColor;

    return Scaffold(
      backgroundColor: useAdaptive ? theme.colorScheme.primary : Colors.teal,
      body: Container(
        decoration: BoxDecoration(
          gradient: useAdaptive
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondary
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade400,
                    Colors.teal.shade700,
                    Colors.teal.shade900,
                  ],
                ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ResponsiveUtils.getResponsiveIconSize(context,
                          mobile: 120, tablet: 140, desktop: 160),
                      height: ResponsiveUtils.getResponsiveIconSize(context,
                          mobile: 120, tablet: 140, desktop: 160),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: ResponsiveUtils.getResponsiveIconSize(context,
                            mobile: 60, tablet: 70, desktop: 80),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aspends Tracker',
                      style: GoogleFonts.nunito(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 32, tablet: 36, desktop: 40),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(context,
                            mobile: 8, tablet: 12, desktop: 16)),
                    Text(
                      'Smart Money Management',
                      style: GoogleFonts.nunito(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 16, tablet: 18, desktop: 20),
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: LoadingAnimationWidget.halfTriangleDot(
                        color: Colors.white.withOpacity(0.8),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
