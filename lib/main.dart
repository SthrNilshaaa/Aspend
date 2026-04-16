import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'core/models/person.dart';
import 'core/models/person_transaction.dart';
import 'core/models/theme.dart';
import 'core/models/transaction.dart';
import 'core/models/detection_history.dart';
import 'core/repositories/transaction_repository.dart';
import 'core/repositories/person_repository.dart';
import 'core/repositories/settings_repository.dart';
import 'core/view_models/transaction_view_model.dart';
import 'core/view_models/theme_view_model.dart';
import 'core/view_models/person_view_model.dart';
import 'screens/splash_screen.dart';
import 'core/services/transaction_detection_service.dart';
import 'core/services/native_bridge.dart';
import 'core/const/app_colors.dart';
import 'core/const/app_strings.dart';
import 'core/const/app_typography.dart';
import 'core/const/app_dimensions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(AppThemeAdapter());
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(PersonTransactionAdapter());
  Hive.registerAdapter(DetectionHistoryAdapter());

  try {
    await Future.wait([
      if (!Hive.isBoxOpen('transactions'))
        Hive.openBox<Transaction>('transactions'),
      if (!Hive.isBoxOpen('balanceBox')) Hive.openBox<double>('balanceBox'),
      if (!Hive.isBoxOpen('settings')) Hive.openBox('settings'),
      if (!Hive.isBoxOpen('people')) Hive.openBox<Person>('people'),
      if (!Hive.isBoxOpen('personTransactions'))
        Hive.openBox<PersonTransaction>('personTransactions'),
      if (!Hive.isBoxOpen('detection_history'))
        Hive.openBox<DetectionHistory>('detection_history'),
    ]);
  } catch (e) {
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize local storage: \n\n$e',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
    return;
  }

  // Ensure 120Hz or highest available refresh rate
  try {
    final List<DisplayMode> modes = await FlutterDisplayMode.supported;
    if (modes.isNotEmpty) {
      // Find the mode with the highest refresh rate
      DisplayMode highestMode = modes.first;
      for (var mode in modes) {
        if (mode.refreshRate > highestMode.refreshRate) {
          highestMode = mode;
        }
      }
      
      // Only set if it's better than 60Hz and not already set
      if (highestMode.refreshRate > 60) {
        await FlutterDisplayMode.setPreferredMode(highestMode);
        debugPrint('Set display mode to: ${highestMode.refreshRate}Hz');
      } else {
        await FlutterDisplayMode.setHighRefreshRate();
      }
    } else {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  } catch (e) {
    debugPrint('Error setting high refresh rate: $e');
    // Fallback to basic high refresh rate if something goes wrong
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {}
  }

  try {
    await NativeBridge.initialize();
    await TransactionDetectionService.initialize();
  } catch (e) {
    debugPrint('Error initializing transaction detection services: $e');
  }

  HomeWidget.registerInteractivityCallback(backgroundCallback);

  final transactionRepo = TransactionRepository();
  final personRepo = PersonRepository();
  final settingsRepo = SettingsRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel(settingsRepo)),
        ChangeNotifierProvider(
            create: (_) => TransactionViewModel(transactionRepo, settingsRepo)),
        ChangeNotifierProvider(create: (_) => PersonViewModel(personRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  if (uri != null && uri.host == 'addTransaction') {
    // Handle background widget actions if needed
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final themeViewModel = context.watch<ThemeViewModel>();

        final useAdaptive = themeViewModel.useAdaptiveColor;
        final customSeedColor =
            themeViewModel.customSeedColor ?? AppColors.primaryGreen;
        final scaffoldBackgroundColor = themeViewModel.isDarkMode
            ? const Color(0xFF0D0D0D)
            : const Color(0xFFFDFFFD);
        final lightSchemeFinal = useAdaptive
            ? (lightDynamic ??
                ColorScheme.fromSeed(
                    seedColor: customSeedColor, brightness: Brightness.light))
            : ColorScheme.fromSeed(
                seedColor: customSeedColor, brightness: Brightness.light);
        final darkSchemeFinal = useAdaptive
            ? (darkDynamic ??
                ColorScheme.fromSeed(
                    seedColor: customSeedColor, brightness: Brightness.dark))
            : ColorScheme.fromSeed(
                seedColor: customSeedColor, brightness: Brightness.dark);

        ThemeData createTheme(ColorScheme scheme) {
          return ThemeData(
            colorScheme: scheme,
            useMaterial3: true,
            scaffoldBackgroundColor: scaffoldBackgroundColor,
            fontFamily: AppTypography.fontFamily, // Move completely to DM Sans
            textTheme: GoogleFonts.dmSansTextTheme(
              scheme.brightness == Brightness.dark
                  ? ThemeData.dark().textTheme
                  : ThemeData.light().textTheme,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMedium)),
              color: scheme.surface,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
                borderSide: BorderSide(color: scheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
                borderSide:
                    BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
              filled: true,
              fillColor: scheme.surface,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSmall)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          );
        }

        // Apply System UI Style for Android status bar icons
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                themeViewModel.isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: scaffoldBackgroundColor,
            systemNavigationBarIconBrightness:
                themeViewModel.isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          themeMode: themeViewModel.themeMode,
          theme: createTheme(lightSchemeFinal),
          darkTheme: createTheme(darkSchemeFinal),
          home: SplashScreen(
            isDarkMode: themeViewModel.isDarkMode,
          ),
        );
      },
    );
  }
}
