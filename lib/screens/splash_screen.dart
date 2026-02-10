import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'intro_page.dart';
import 'root_navigation.dart';
import '../utils/responsive_utils.dart';
import '../const/app_colors.dart';
import '../const/app_assets.dart';
import '../const/app_strings.dart';
import '../const/app_constants.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../view_models/theme_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entry Animation Controllers
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<double> _entryScale;
  late Animation<Offset> _entrySlide;

  // Exit Animation Controllers
  late AnimationController _exitController;
  late Animation<double> _exitScale;
  late Animation<double> _exitRotation;
  late Animation<double> _exitFade;

  bool _isNavigated = false;
  bool _showExitAnimation = false;
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();
    // Initialize Entry Animation
    _entryController = AnimationController(
      vsync: this,
      duration: AppConstants.splashEntryDuration,
    );
    _entryFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeInOut),
    );
    _entryScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _entrySlide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _entryController.forward();

    // Initialize Exit Animation
    _exitController = AnimationController(
      vsync: this,
      duration:
          AppConstants.splashExitDuration, // Slightly slower for better feel
    );
    _exitScale = Tween<double>(begin: 1.0, end: 50.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCirc),
    );
    _exitRotation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOutCubic),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOutCubic),
    );

    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeNavigation();
      }
    });

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
      _startExitAnimation(
          introCompleted ? const RootNavigation() : const IntroPage());
    }
  }

  void _startExitAnimation(Widget target) {
    if (_isNavigated) return;
    setState(() {
      _targetScreen = target;
      _showExitAnimation = true;
    });
    _exitController.forward();
  }

  void _completeNavigation() {
    if (_isNavigated) return;
    _isNavigated = true;
    if (_targetScreen != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => _targetScreen!,
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDarkMode = themeViewModel.isDarkMode;
    const launcherBackgroundColor = AppColors.launcherBackground;

    return Scaffold(
      backgroundColor: launcherBackgroundColor,
      body: Stack(
        children: [
          // Layer 1: The Target Screen (Revealed through the hole)
          if (_targetScreen != null)
            Positioned.fill(
              child: _targetScreen!,
            ),

          // Layer 2: The Splash Overlay
          AnimatedBuilder(
            animation: Listenable.merge([_entryController, _exitController]),
            builder: (context, child) {

              double currentFade =
                  _showExitAnimation ? _exitFade.value : _entryFade.value;

              return Stack(
                children: [
                  // Full screen background with hole reveal
                  Positioned.fill(
                    child: Opacity(
                      opacity: currentFade,
                      child: CustomPaint(
                        painter: HolePainter(
                          color: launcherBackgroundColor,
                          holeScale:
                              _showExitAnimation ? _exitScale.value : 0.0,
                          opacity:
                              1.0, // Control opacity via the Opacity widget wrapper
                        ),
                      ),
                    ),
                  ),

                  // Content Layer - centered icon and positioned text
                  Positioned.fill(
                    child: Opacity(
                      opacity: currentFade,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Icon perfectly centered
                          Center(
                            child: SlideTransition(
                              position: _entrySlide,
                              child: SvgPicture.asset(
                                // isDarkMode
                                //     ?
                                    SvgAppIcons.lightLogoIcon,
                                    // : SvgAppIcons.darkLogoIcon,
                                height:
                                    ResponsiveUtils.getResponsiveIconSize(
                                        context,
                                        mobile:
                                            AppDimensions.splashLogoMobile,
                                        tablet:
                                            AppDimensions.splashLogoTablet,
                                        desktop: AppDimensions
                                            .splashLogoDesktop),
                                width:
                                    ResponsiveUtils.getResponsiveIconSize(
                                        context,
                                        mobile:
                                            AppDimensions.splashLogoMobile,
                                        tablet:
                                            AppDimensions.splashLogoTablet,
                                        desktop: AppDimensions
                                            .splashLogoDesktop),
                              ),
                            ),
                          ),

                          // Text and Loader positioned below the icon
                          Positioned(
                            top: (MediaQuery.of(context).size.height / 2) +
                                (ResponsiveUtils.getResponsiveIconSize(context,
                                        mobile: AppDimensions
                                            .splashLogoOffsetMobile,
                                        tablet: AppDimensions
                                            .splashLogoOffsetTablet,
                                        desktop: AppDimensions
                                            .splashLogoOffsetDesktop) /
                                    2) +
                                AppDimensions.paddingLarge,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.appName,
                                  style: GoogleFonts.dmSans(
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            mobile: AppTypography
                                                    .fontSizeXLarge +
                                                8, // 32
                                            tablet:
                                                AppTypography
                                                    .fontSizeHuge, // 36
                                            desktop:
                                                AppTypography.fontSizeXXLarge +
                                                    12), // 40
                                    color: Colors.white,
                                    fontWeight: AppTypography.fontWeightBold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        ResponsiveUtils.getResponsiveSpacing(
                                            context,
                                            mobile: AppDimensions.paddingSmall,
                                            tablet:
                                                AppDimensions.borderRadiusSmall,
                                            desktop:
                                                AppDimensions.paddingStandard)),
                                Text(
                                  AppStrings.splashTagline,
                                  style: GoogleFonts.dmSans(
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            mobile:
                                                AppTypography.fontSizeMedium,
                                            tablet:
                                                AppTypography.fontSizeSmall + 4,
                                            desktop:
                                                AppTypography.fontSizeLarge),
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: AppTypography.fontWeightMedium,
                                  ),
                                ),
                                const SizedBox(
                                    height: AppDimensions.avatarSizeStandard),
                                SizedBox(
                                  width: AppDimensions.avatarSizeStandard,
                                  height: AppDimensions.avatarSizeStandard,
                                  child: LoadingAnimationWidget.halfTriangleDot(
                                    color: Colors.white.withValues(alpha: 0.8),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }
}

class HolePainter extends CustomPainter {
  final Color color;
  final Gradient? gradient;
  final double holeScale;
  final double opacity;

  HolePainter({
    required this.color,
    this.gradient,
    required this.holeScale,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    if (gradient != null) {
      paint.shader = gradient!.createShader(Offset.zero & size);
    }

    if (holeScale > 0) {
      final path = Path()
        ..addRect(Offset.zero & size)
        ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: 60 * holeScale,
        ))
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(path, paint);
    } else {
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HolePainter oldDelegate) {
    return oldDelegate.holeScale != holeScale || oldDelegate.opacity != opacity;
  }
}
