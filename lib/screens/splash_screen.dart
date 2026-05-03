import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'intro_page.dart';
import 'root_navigation.dart';
import '../core/utils/responsive_utils.dart';
import '../core/const/app_assets.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_constants.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';

class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  const SplashScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entry Animation Controllers
  late AnimationController _entryController;
  late Animation<double> _entryFade;

  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    // Initialize Entry Animation
    _entryController = AnimationController(
      vsync: this,
      duration: AppConstants.splashEntryDuration,
    );
    _entryFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );
    _entryController.forward();

    _checkInitialLaunch();
  }

  Future<void> _checkInitialLaunch() async {
    Uri? uri;
    try {
      uri = await HomeWidget.initiallyLaunchedFromHomeWidget()
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('SplashScreen: HomeWidget init error: $e');
    }
    bool isWidgetLaunch = uri != null && uri.host == 'addTransaction';

    final box = await Hive.openBox(AppConstants.settingsBox);
    final introCompleted = box.get('introCompleted', defaultValue: false);
    final appLockEnabled = box.get('appLockEnabled', defaultValue: false);

    // Minimum wait for entry animation partial completion + loading feel
    await Future.delayed(isWidgetLaunch
        ? AppConstants.widgetWaitDuration
        : AppConstants.splashWaitDuration);

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

      if (mounted) {
        _navigateToTarget(
            introCompleted ? const RootNavigation() : const IntroPage());
      }
    }
  }

    void _navigateToTarget(Widget target) {
    if (_isNavigated) return;
    _isNavigated = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionDuration: AppConstants.splashExitDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBackgroundColor =
        widget.isDarkMode ? const Color(0xFF0D0D0D) : const Color(0xFFFDFFFD);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: scaffoldBackgroundColor),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: _entryFade.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          SvgAppIcons.darkLogoIconSplash,
                          height: ResponsiveUtils.getResponsiveIconSize(
                              context,
                              mobile: AppDimensions.splashLogoMobile,
                              tablet: AppDimensions.splashLogoTablet,
                              desktop: AppDimensions.splashLogoDesktop),
                          width: ResponsiveUtils.getResponsiveIconSize(
                              context,
                              mobile: AppDimensions.splashLogoMobile,
                              tablet: AppDimensions.splashLogoTablet,
                              desktop: AppDimensions.splashLogoDesktop),
                        ),
                      ),
                      Positioned(
                        top: (MediaQuery.of(context).size.height / 2) +
                            (ResponsiveUtils.getResponsiveIconSize(context,
                                    mobile:
                                        AppDimensions.splashLogoOffsetMobile,
                                    tablet:
                                        AppDimensions.splashLogoOffsetTablet,
                                    desktop:
                                        AppDimensions.splashLogoOffsetDesktop) /
                                2) +
                            AppDimensions.paddingLarge,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.appName,
                              style: GoogleFonts.dmSans(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    mobile: AppTypography.fontSizeXLarge + 8,
                                    tablet: AppTypography.fontSizeHuge,
                                    desktop:
                                        AppTypography.fontSizeXXLarge + 12),
                                color: widget.isDarkMode ? Colors.white : Colors.black,
                                fontWeight: AppTypography.fontWeightBold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                    mobile: AppDimensions.paddingSmall,
                                    tablet: AppDimensions.borderRadiusSmall,
                                    desktop: AppDimensions.paddingStandard)),
                            Text(
                              AppStrings.splashTagline,
                              style: GoogleFonts.dmSans(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    mobile: AppTypography.fontSizeMedium,
                                    tablet: AppTypography.fontSizeSmall + 4,
                                    desktop: AppTypography.fontSizeLarge),
                                color: (widget.isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.9),
                                fontWeight: AppTypography.fontWeightMedium,
                              ),
                            ),
                            const SizedBox(
                                height: AppDimensions.avatarSizeStandard),
                            SizedBox(
                              width: AppDimensions.avatarSizeStandard,
                              height: AppDimensions.avatarSizeStandard,
                              child: LoadingAnimationWidget.halfTriangleDot(
                                color: (widget.isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.8),
                                size: AppDimensions.avatarSizeStandard,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }
}

