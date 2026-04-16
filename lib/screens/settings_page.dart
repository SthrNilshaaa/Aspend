import 'dart:ui';

import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../view_models/theme_view_model.dart';
=======
import 'package:flutter_svg/svg.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:local_auth/local_auth.dart';
import '../core/view_models/theme_view_model.dart';
>>>>>>> master
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
//import 'dart:io';

<<<<<<< HEAD
import '../backup/export_csv.dart';
import '../backup/import_csv.dart';
import '../backup/person_backup_helper.dart';
//import '../models/person.dart';
import '../models/theme.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/person_view_model.dart';
import '../services/pdf_service.dart';
import '../services/transaction_detection_service.dart';
import '../services/native_bridge.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/responsive_utils.dart';
import '../utils/error_handler.dart';
=======
import '../core/services/backup_service.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/view_models/person_view_model.dart';
import '../core/services/pdf_service.dart';
import '../core/services/transaction_detection_service.dart';
import '../core/services/native_bridge.dart';
import '../core/utils/transaction_parser.dart';
import '../core/utils/responsive_utils.dart';
import '../core/utils/error_handler.dart';
import 'detection_history_page.dart';
import 'app_selection_page.dart';
import 'about_page.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/monitoring_setup_dialog.dart';
import '../core/utils/blur_utils.dart';
import '../core/utils/transaction_utils.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_constants.dart';
>>>>>>> master

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _appLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAppLockSetting();
  }

  Future<void> _loadAppLockSetting() async {
<<<<<<< HEAD
    final box = await Hive.openBox('settings');
=======
    final box = await Hive.openBox(AppConstants.settingsBox);
    if (!mounted) return;
>>>>>>> master
    setState(() {
      _appLockEnabled = box.get('appLockEnabled', defaultValue: false);
    });
  }

  Future<void> _setAppLockEnabled(bool enabled) async {
    try {
      if (enabled) {
        final localAuth = LocalAuthentication();
        final canCheckBiometrics = await localAuth.canCheckBiometrics;
        final canCheckDeviceSupport = await localAuth.isDeviceSupported();

        if (!canCheckDeviceSupport) {
<<<<<<< HEAD
=======
          if (!mounted) return;
>>>>>>> master
          ErrorHandler.showErrorSnackBar(context,
              'Biometric authentication is not supported on this device');
          return;
        }

        if (!canCheckBiometrics) {
<<<<<<< HEAD
=======
          if (!mounted) return;
>>>>>>> master
          ErrorHandler.showErrorSnackBar(
              context, 'No biometric authentication methods available');
          return;
        }

        final didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Authenticate to enable app lock',
<<<<<<< HEAD
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );

        if (!didAuthenticate) {
=======
          biometricOnly: false,
          persistAcrossBackgrounding: true,
        );

        if (!didAuthenticate) {
          if (!mounted) return;
>>>>>>> master
          ErrorHandler.showErrorSnackBar(
              context, 'Authentication failed. App lock not enabled.');
          return;
        }
      }

<<<<<<< HEAD
      final box = await Hive.openBox('settings');
      await box.put('appLockEnabled', enabled);
=======
      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put('appLockEnabled', enabled);
      if (!mounted) return;
>>>>>>> master
      setState(() {
        _appLockEnabled = enabled;
      });

<<<<<<< HEAD
=======
      if (!mounted) return;
>>>>>>> master
      ErrorHandler.showSuccessSnackBar(
          context,
          enabled
              ? 'App lock enabled successfully'
              : 'App lock disabled successfully');
    } catch (e) {
<<<<<<< HEAD
=======
      if (!mounted) return;
>>>>>>> master
      ErrorHandler.handleError(context, e,
          customMessage:
              'Failed to ${enabled ? 'enable' : 'disable'} app lock');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final theme = Theme.of(context);
    final isDark = themeViewModel.isDarkMode;
    final useAdaptive = themeViewModel.useAdaptiveColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        //controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
<<<<<<< HEAD
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveAppBarHeight(context),
            floating: true,
            pinned: true,
            elevation: 1,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Settings',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              background: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: useAdaptive
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primaryContainer
                              ],
                            )
                          : isDark
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primaryContainer
                                        .withOpacity(0.8)
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primaryContainer
                                        .withOpacity(0.8)
                                  ],
                                ),
                    ),
                  ),
                ),
              ),
            ),
=======
          const GlassAppBar(
            title: AppStrings.settings,
>>>>>>> master
            centerTitle: true,
          ),

          // Settings Content
          SliverToBoxAdapter(
<<<<<<< HEAD
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme Section
                  _buildSectionHeader("Appearance", Icons.palette),
                  const SizedBox(height: 10),
                  _buildThemeCard(context, isDark),
                  if (!useAdaptive) ...[
                    const SizedBox(height: 12),
                    _buildColorPickerTile(context),
                  ],
                  const SizedBox(height: 12),
                  _buildAdaptiveColorSwitch(context),
                  const SizedBox(height: 18),
                  _buildAppLockSection(context),
                  const SizedBox(height: 18),
                  // Auto Detection Section
                  _buildSectionHeader(
                      "Auto Transaction Detection", Icons.auto_awesome),
                  const SizedBox(height: 10),
                  _buildAutoDetectionSection(context),
                  const SizedBox(height: 18),
                  // Backup & Export Section
                  _buildSectionHeader("Backup & Export", Icons.backup),
                  const SizedBox(height: 10),
                  _buildBackupSection(context, isDark),
                  const SizedBox(height: 18),
                  // Data Management Section
                  _buildSectionHeader("Data Management", Icons.storage),
                  const SizedBox(height: 10),
                  _buildDataManagementSection(context, isDark),
                  const SizedBox(height: 18),
                  // App Info Section
                  _buildSectionHeader("App Information", Icons.info),
                  const SizedBox(height: 10),
                  _buildAppInfoSection(context, isDark),
                  const SizedBox(height: 8),
                  // Add developer credit at the very bottom
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        'Developed with ❤️ by Sthrnilshaa',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
=======
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                      horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Theme Section
                      TitledSection(
                        title: AppStrings.appearance,
                        icon: Icons.palette,
                        children: [
                          _buildThemeCard(context, isDark),
                          // if (!useAdaptive) ...[
                          //   const SizedBox(height: 12),
                          //   _buildColorPickerTile(context),
                          // ],
                          // const SizedBox(height: 12),
                          // _buildAdaptiveColorSwitch(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                       TitledSection(
                        title: AppStrings.security,
                        icon: Icons.security,
                        children: [
                          _buildAppLockSection(context),
                          _buildUpiSettingsTile(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Auto Detection Section
                      TitledSection(
                        title: AppStrings.autoDetection,
                        icon: Icons.auto_awesome,
                        children: [
                          _buildAutoDetectionSection(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Backup & Export Section
                      TitledSection(
                        title: AppStrings.backupExport,
                        icon: Icons.backup,
                        children: [
                          _buildBackupSection(context, isDark),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Data Management Section
                      TitledSection(
                        title: AppStrings.dataManagement,
                        icon: Icons.storage,
                        children: [
                          _buildDataManagementSection(context, isDark),
                        ],
                      ),
                      const SizedBox(height: 24),

                      TitledSection(
                        title: AppStrings.budgetingBalance,
                        icon: Icons.wallet_membership,
                        children: [
                          _buildBudgetSection(context),
                          const SizedBox(height: 12),
                          _buildBalanceCalculationTile(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Custom Dropdown Items Section
                      TitledSection(
                        title: AppStrings.customDropdowns,
                        icon: Icons.list_alt,
                        children: [
                          _buildCustomOptionsSection(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // App Info Section
                      TitledSection(
                        title: AppStrings.appInformation,
                        icon: Icons.info,
                        children: [
                          _buildAppInfoSection(context, isDark),
                        ],
                      ),
                      // const SizedBox(height: 8),
                      // // Add developer credit at the very bottom
                      // Center(
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(top: 16, bottom: 8),
                      //     child: Text(
                      //       AppStrings.developedBy,
                      //       style: GoogleFonts.dmSans(
                      //         fontSize: 12,
                      //         color: Colors.grey,
                      //         fontWeight: FontWeight.w500,
                      //         letterSpacing: 0.2,
                      //       ),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
            ),
          ),
>>>>>>> master
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = Theme.of(context);
    final useAdaptive = context.watch<ThemeViewModel>().useAdaptiveColor;
    return Row(
      children: [
        Icon(
          icon,
          color: useAdaptive ? theme.colorScheme.primary : Colors.teal.shade600,
          size: ResponsiveUtils.getResponsiveIconSize(context,
              mobile: 20, tablet: 24, desktop: 28),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.bold,
            color:
                useAdaptive ? theme.colorScheme.primary : Colors.teal.shade700,
          ),
        ),
      ],
    );
  }

=======
>>>>>>> master
  Widget _buildThemeCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final useAdaptive = context.watch<ThemeViewModel>().useAdaptiveColor;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.palette,
                    size: 24,
                    color: useAdaptive
                        ? theme.colorScheme.primary
                        : Colors.teal.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
<<<<<<< HEAD
                        "Theme",
                        style: GoogleFonts.nunito(
=======
                        AppStrings.theme,
                        style: GoogleFonts.dmSans(
>>>>>>> master
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
<<<<<<< HEAD
                        "Choose your preferred theme",
                        style: GoogleFonts.nunito(
=======
                        AppStrings.chooseTheme,
                        style: GoogleFonts.dmSans(
>>>>>>> master
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
<<<<<<< HEAD
            DropdownButtonHideUnderline(
              child: DropdownButton<AppTheme>(
                value: context.watch<ThemeViewModel>().appTheme,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (theme) {
                  HapticFeedback.lightImpact();
                  if (theme != null) {
                    context.read<ThemeViewModel>().setTheme(theme);
                  }
                },
                items: AppTheme.values.map((theme) {
                  final label = theme.toString().split('.').last.capitalize();
                  return DropdownMenuItem(
                    value: theme,
                    child: Text(label),
                  );
                }).toList(),
              ),
            ),
=======
            _buildThemeSegmentedControl(context),
>>>>>>> master
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
=======
  Widget _buildThemeSegmentedControl(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildThemeOption(context, ThemeMode.system, Icons.settings_suggest_rounded, 'System'),
          _buildThemeOption(context, ThemeMode.light, Icons.light_mode_rounded, 'Light'),
          _buildThemeOption(context, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode mode, IconData icon, String label) {
    final viewModel = context.watch<ThemeViewModel>();
    final isSelected = viewModel.themeMode == mode;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          viewModel.setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

>>>>>>> master
  Widget _buildAdaptiveColorSwitch(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.color_lens, color: Colors.teal.shade600, size: 24),
            const SizedBox(width: 12),
            Text(
<<<<<<< HEAD
              "Adaptive Android Color",
              style: GoogleFonts.nunito(
=======
              AppStrings.adaptiveColor,
              style: GoogleFonts.dmSans(
>>>>>>> master
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Switch(
          value: viewModel.useAdaptiveColor,
          onChanged: (value) {
            HapticFeedback.lightImpact();
<<<<<<< HEAD
            viewModel.setAdaptiveColor(value);
=======
            viewModel.setUseAdaptiveColor(value);
>>>>>>> master
          },
        ),
      ],
    );
  }

  Widget _buildColorPickerTile(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
<<<<<<< HEAD
    final currentColor = viewModel.customSeedColor ?? Colors.teal;
    return _buildSettingsTile(
      icon: Icons.color_lens,
      title: "App Color",
      subtitle: "Select a custom app color",
      onTap: () async {
        Color selectedColor = currentColor;
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pick App Color'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    selectedColor = color;
                  },
                  //enableAlpha: false,
                  //showLabel: false,
                  //pickerAreaHeightPercent: 0.7,
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Reset'),
                  onPressed: () {
                    viewModel.setCustomSeedColor(null);
                    Navigator.of(context).pop();
                    _showSnackBar(context, 'App color reset to default!');
                  },
                ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Select'),
                  onPressed: () {
                    viewModel.setCustomSeedColor(selectedColor);
                    Navigator.of(context).pop();
                    _showSnackBar(context, 'App color updated!');
                  },
                ),
              ],
            );
          },
=======
    final currentColor = viewModel.customSeedColor ?? Colors.green;
    return SettingTile(
      icon: Icons.color_lens,
      title: AppStrings.appColor,
      subtitle: AppStrings.selectColor,
      onTap: () async {
        Color selectedColor = currentColor;
        BlurUtils.showBlurredDialog(
          context: context,
          child: AlertDialog(
            title: const Text('Pick App Color'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  selectedColor = color;
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Reset'),
                onPressed: () {
                  viewModel.setCustomSeedColor(null);
                  Navigator.of(context).pop();
                  _showSnackBar(context, 'App color reset to default!');
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('Select'),
                onPressed: () {
                  viewModel.setCustomSeedColor(selectedColor);
                  Navigator.of(context).pop();
                  // Removed snackbar as it might trigger lint and is redundant with the UI update
                },
              ),
            ],
          ),
>>>>>>> master
        );
      },
    );
  }

  Widget _buildAppLockSection(BuildContext context) {
<<<<<<< HEAD
    return _buildSettingsTile(
      icon: Icons.lock,
      title: "App Lock",
      subtitle: "Require device authentication to open app",
      onTap: null,
=======
    return SettingTile(
      icon: Icons.lock,
      title: AppStrings.appLock,
      subtitle: AppStrings.appLockDesc,
>>>>>>> master
      trailing: Switch(
        value: _appLockEnabled,
        onChanged: (value) async {
          final localAuth = LocalAuthentication();
          try {
            if (value) {
              final canCheck = await localAuth.canCheckBiometrics ||
                  await localAuth.isDeviceSupported();
<<<<<<< HEAD
=======
              if (!mounted) return;
>>>>>>> master
              if (!canCheck) {
                _showSnackBar(context,
                    'Device does not support biometrics or device authentication.');
                return;
              }
              final didAuthenticate = await localAuth.authenticate(
<<<<<<< HEAD
                localizedReason: 'Enable app lock',
                options: const AuthenticationOptions(
                    biometricOnly: false, stickyAuth: true),
              );
=======
                localizedReason: 'Authenticate to enable app lock',
                biometricOnly: false,
                persistAcrossBackgrounding: true,
              );
              if (!mounted) return;
>>>>>>> master
              if (!didAuthenticate) {
                _showSnackBar(
                    context, 'Authentication failed. App lock not enabled.');
                return;
              }
            }
            await _setAppLockEnabled(value);
<<<<<<< HEAD
            _showSnackBar(
                context, value ? 'App lock enabled.' : 'App lock disabled.');
          } catch (e) {
=======
            if (!mounted) return;
            _showSnackBar(
                context, value ? 'App lock enabled.' : 'App lock disabled.');
          } catch (e) {
            if (!mounted) return;
>>>>>>> master
            _showSnackBar(context, 'Error: \n$e');
          }
        },
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildAutoDetectionSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.auto_awesome,
          title: "Auto Transaction Detection",
          subtitle: "Automatically detect transactions from notifications",
          onTap: null,
          trailing: FutureBuilder<bool>(
            future: TransactionDetectionService.isEnabled(),
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? false;
              return Switch(
                value: isEnabled,
                onChanged: (value) async {
                  HapticFeedback.lightImpact();
                  try {
                    if (value) {
                      // Show info dialog first
                      await _showAutoDetectionInfoDialog(context);

                      // Request notification permission
                      final notificationPermission =
                          await NativeBridge.requestNotificationPermission();
                      if (!notificationPermission) {
                        _showSnackBar(context,
                            'Notification permission is required for auto-detection');
                        return;
                      }

                      // Check if notification access is enabled
                      final notificationAccess =
                          await NativeBridge.checkNotificationPermission();
                      if (!notificationAccess) {
                        _showSnackBar(context,
                            'Please enable notification access in system settings');
                        return;
                      }

                      // Request battery optimization exemption
                      await NativeBridge.requestBatteryOptimization();
                    }

                    await TransactionDetectionService.setEnabled(value);
                    _showSnackBar(
                        context,
                        value
                            ? 'Auto-detection enabled!'
                            : 'Auto-detection disabled!');

                    // Refresh the UI
                    setState(() {});
                  } catch (e) {
                    _showSnackBar(context, 'Error: $e');
                  }
                },
              );
            },
          ),
        ),
        _buildSettingsTile(
          icon: Icons.history,
          title: "Process Recent Data",
          subtitle: "Scan recent notifications for transactions",
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await TransactionDetectionService.processRecentSms();
              _showSnackBar(context, 'Recent data processed successfully!');
            } catch (e) {
              _showSnackBar(context, 'Error processing data: $e');
            }
          },
=======
  Widget _buildUpiSettingsTile(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    return Column(
      children: [
        SettingTile(
          icon: Icons.qr_code_2_rounded,
          title: AppStrings.upiId,
          subtitle: viewModel.upiId ?? AppStrings.upiIdDesc,
          onTap: () => _showUpiInputDialog(context, 'UPI ID', viewModel.upiId,
              (val) => viewModel.setUpiId(val)),
        ),
        SettingTile(
          icon: Icons.person_pin_outlined,
          title: AppStrings.upiName,
          subtitle: viewModel.upiName ?? AppStrings.upiNameDesc,
          onTap: () => _showUpiInputDialog(context, 'Display Name',
              viewModel.upiName, (val) => viewModel.setUpiName(val)),
>>>>>>> master
        ),
      ],
    );
  }

<<<<<<< HEAD
  Future<void> _showAutoDetectionInfoDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Text(
              "Auto Transaction Detection",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This feature will automatically detect transactions from:",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
                "🔔 App notifications", "Monitors payment app notifications"),
            _buildInfoItem("📱 Banking notifications",
                "Detects UPI, ATM, and banking transactions"),
            _buildInfoItem("💰 Automatic categorization",
                "Categorizes transactions based on bank keywords"),
            const SizedBox(height: 12),
            Text(
              "Required permissions:",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
                "🔔 Notification access", "To monitor payment notifications"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                "💡 Tip: The app will only process messages that contain transaction amounts and keywords like 'credited', 'debited', 'paid', etc.",
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text("Enable"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
=======
  void _showUpiInputDialog(BuildContext context, String title,
      String? currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    BlurUtils.showBlurredDialog(
      context: context,
      child: AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $title',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              onSave(controller.text.trim());
>>>>>>> master
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildInfoItem(String title, String subtitle) {
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
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
=======
  Widget _buildAutoDetectionSection(BuildContext context) {
    return Column(
      children: [
        SettingTile(
          icon: Icons.auto_awesome,
          title: 'Auto Transaction Detection',
          subtitle: 'Automatically detect transactions from notifications',
          trailing: FutureBuilder<bool>(
            future: TransactionDetectionService.isEnabled(),
            builder: (context, snapshot) {
              final isEnabled = snapshot.data ?? false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEnabled)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Switch(
                    value: isEnabled,
                    onChanged: (value) async {
                      HapticFeedback.lightImpact();
                      try {
                        if (value) {
                          final hasPermission =
                              await NativeBridge.checkNotificationPermission();

                          if (!hasPermission) {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: const MonitoringSetupDialog(),
                              ),
                            );
                            if (confirmed != true) {
                              if (mounted) setState(() {});
                              return;
                            }
                          }

                          final notificationAccess =
                              await NativeBridge.checkNotificationPermission();
                          final smsAccess = await NativeBridge.checkSmsPermission();

                          if (!notificationAccess && !smsAccess) {
                            if (mounted) {
                              ErrorHandler.showErrorSnackBar(context,
                                  'Permissions required: No notification or SMS access granted. Auto-detection cannot be enabled.');
                              setState(() {});
                            }
                            return;
                          }

                          if (!notificationAccess && mounted) {
                            ErrorHandler.showWarningSnackBar(context,
                                'Note: Notification access is missing. Only SMS detection will work.');
                          } else if (!smsAccess && mounted) {
                            ErrorHandler.showWarningSnackBar(context,
                                'Note: SMS permission is missing. Only Notification detection will work.');
                          }

                          await NativeBridge.requestBatteryOptimization();
                        }

                        await TransactionDetectionService.setEnabled(value);

                        if (!mounted) return;

                        if (!mounted) return;

                        ErrorHandler.showSuccessSnackBar(
                            context,
                            value
                                ? 'Auto-detection enabled!'
                                : 'Auto-detection disabled!');

                        setState(() {});
                      } catch (e) {
                        if (mounted) {
                          ErrorHandler.handleError(context, e,
                              customMessage: 'Failed to update auto-detection');
                        }
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
        SettingTile(
          icon: Icons.history,
          title: 'Process Recent Data',
          subtitle: 'Scan recent notifications for transactions',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await TransactionDetectionService.processRecentSms();
              if (mounted) {
                ErrorHandler.showSuccessSnackBar(
                    context, 'Recent data processed successfully!');
              }
            } catch (e) {
              if (!mounted) return;
              ErrorHandler.handleError(context, e,
                  customMessage: 'Error processing data');
            }
          },
        ),
        SettingTile(
          icon: Icons.bug_report_outlined,
          title: 'Test Detection Logic',
          subtitle: 'Simulate a notification to verify parsing',
          onTap: () => _showTestDetectionDialog(context),
        ),
        SettingTile(
          icon: Icons.app_registration_rounded,
          title: 'Monitored Apps',
          subtitle: 'Choose which apps to monitor for transactions',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppSelectionPage()),
            );
          },
        ),
        SettingTile(
          icon: Icons.manage_history,
          title: 'Show Detection History',
          subtitle: 'View detailed logs of detected transactions',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DetectionHistoryPage()),
            );
          },
        ),
        SettingTile(
          icon: Icons.auto_delete_outlined,
          title: 'Auto-delete undetected history',
          subtitle: 'Delete undetected items after 12 hours',
          trailing: Switch(
            value: context.watch<ThemeViewModel>().autoDeleteUndetected,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              context.read<ThemeViewModel>().setAutoDeleteUndetected(value);
            },
          ),
        ),
      ],
    );
  }

  void _showTestDetectionDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text:
          'Alert: Your account XX1234 has been debited by Rs. 500.00 for a purchase at AMAZON. Ref: 12345678.',
    );
    
    ParsedTransaction? result;

    BlurUtils.showBlurredDialog(
      context: context,
      child: StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Test Parser Diagnostic'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter a sample notification message to see how our parser handles it.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Paste notification text here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (result != null) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                      'Status: ${result!.isBalanceUpdate ? 'Balance Sync' : result!.amount > 0 ? 'Transaction Detected' : 'No Action Detected'}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: result!.amount > 0 || result!.isBalanceUpdate
                              ? Colors.green
                              : Colors.orange)),
                  const SizedBox(height: 8),
                  _resultItem(
                      'Amount', '₹${result!.amount.toStringAsFixed(2)}'),
                  _resultItem(
                      'Type', result!.isIncome ? 'Income' : 'Expense'),
                  _resultItem('Merchant', result!.merchant ?? 'Unknown'),
                  _resultItem('Category', result!.category ?? 'General'),
                  _resultItem('Bank', result!.bank ?? 'Unknown'),
                  _resultItem('Account', result!.account ?? 'N/A'),
                  _resultItem('Balance',
                      result!.balance != null ? '₹${result!.balance}' : 'N/A'),
                  _resultItem(
                      'Confidence', '${(result!.confidence * 100).toInt()}%'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text;
                final parsed = TransactionParser.parse(text,
                    packageName: 'com.test.bank');
                setDialogState(() {
                  result = parsed;
                });

                if (parsed == null) {
                  ErrorHandler.showErrorSnackBar(
                      context, 'Pattern not recognized');
                }
              },
              child: const Text('Parse Text'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
>>>>>>> master
        ],
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context, bool isDark) {
    return Column(
      children: [
<<<<<<< HEAD
        _buildSettingsTile(
          icon: Icons.upload_file,
          title: "Export Transactions",
          subtitle: "Backup your data to CSV",
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await DataExporter.shareBackupFile();
              _showSnackBar(context, "Export completed successfully!");
            } catch (e) {
              _showSnackBar(context, "Export failed: $e");
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.download,
          title: "Import Transactions",
          subtitle: "Restore data from backup",
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await DataImporter.importFromJson(context);
              _showSnackBar(context, "Import completed successfully!");
            } catch (e) {
              _showSnackBar(context, "Import failed: $e");
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.picture_as_pdf,
          title: "Export as PDF",
          subtitle: "Generate PDF reports",
=======
        SettingTile(
          icon: Icons.upload_file,
          title: 'Export Transactions (CSV)',
          subtitle: 'Export your transactions to CSV',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await BackupService.exportToCsvAndShare();
              if (!mounted) return;
              _showSnackBar(context, 'Export completed successfully!');
            } catch (e) {
              if (!mounted) return;
              _showSnackBar(context, 'Export failed: $e');
            }
          },
        ),
        SettingTile(
          icon: Icons.backup,
          title: 'Full Backup (JSON)',
          subtitle: 'Backup all data to JSON',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await BackupService.exportAllDataJsonAndShare();
              if (!mounted) return;
              _showSnackBar(context, 'Backup completed!');
            } catch (e) {
              if (!mounted) return;
              _showSnackBar(context, 'Backup failed: $e');
            }
          },
        ),
        SettingTile(
          icon: Icons.restore,
          title: 'Restore Backup (JSON)',
          subtitle: 'Restore all data from JSON backup',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              final success = await BackupService.importDataFromJson(context);
              if (!mounted) return;
              if (success) {
                _showSnackBar(context, 'Data restored successfully!');
                // Restart app or reload all data might be needed,
                // but since we are using reactive Hive watchers, it should work.
              } else {
                _showSnackBar(context, 'Restore failed or cancelled');
              }
            } catch (e) {
              if (!mounted) return;
              _showSnackBar(context, 'Restore failed: $e');
            }
          },
        ),
        SettingTile(
          icon: Icons.picture_as_pdf,
          title: 'Export as PDF',
          subtitle: 'Generate PDF reports',
>>>>>>> master
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              final file = await PDFService.generateHomeTransactionPDF();
<<<<<<< HEAD
              await Printing.sharePdf(
                  bytes: await file.readAsBytes(),
                  filename: 'home_transactions.pdf');
              _showSnackBar(context, "PDF exported successfully!");
            } catch (e) {
              _showSnackBar(context, "PDF export failed: $e");
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.groups,
          title: "Export People Data",
          subtitle: "Backup people transactions",
=======
              if (!mounted) return;
              await Printing.sharePdf(
                  bytes: await file.readAsBytes(),
                  filename: 'home_transactions.pdf');
              if (!mounted) return;
              _showSnackBar(context, 'PDF exported successfully!');
            } catch (e) {
              if (!mounted) return;
              _showSnackBar(context, 'PDF export failed: $e');
            }
          },
        ),
        SettingTile(
          icon: Icons.groups,
          title: 'Export People Data',
          subtitle: 'Backup people transactions',
>>>>>>> master
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              final file = await PDFService.generatePeopleTransactionPDF();
<<<<<<< HEAD
              await Printing.sharePdf(
                  bytes: await file.readAsBytes(),
                  filename: 'person_transactions.pdf');
              _showSnackBar(context, "People data exported!");
            } catch (e) {
              _showSnackBar(context, "People data export failed: $e");
=======
              if (!mounted) return;
              await Printing.sharePdf(
                  bytes: await file.readAsBytes(),
                  filename: 'person_transactions.pdf');
              if (!mounted) return;
              _showSnackBar(context, 'People data exported!');
            } catch (e) {
              if (!mounted) return;
              _showSnackBar(context, 'People data export failed: $e');
>>>>>>> master
            }
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context, bool isDark) {
    return Column(
      children: [
<<<<<<< HEAD
        _buildSettingsTile(
          icon: Icons.ios_share,
          title: "Export People Data (JSON)",
          subtitle: "Backup people and transactions",
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await PersonBackupHelper.exportToJsonAndShare();
              _showSnackBar(context, "People data exported!");
            } catch (e) {
              _showSnackBar(context, "People data export failed: $e");
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.import_export,
          title: "Import People Data (JSON)",
          subtitle: "Restore people data from backup",
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await PersonBackupHelper.importFromJson(context);
              _showSnackBar(context, "People data imported successfully!");
            } catch (e) {
              _showSnackBar(context, "People data import failed: $e");
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.delete_forever,
          title: "Delete All Data",
          subtitle: "⚠️ This action cannot be undone",
=======
        SettingTile(
          icon: Icons.delete_forever,
          title: 'Delete All Data',
          subtitle: '⚠️ This action cannot be undone',
>>>>>>> master
          isDestructive: true,
          onTap: () {
            HapticFeedback.lightImpact();
            _confirmDeleteAll(context);
          },
        ),
<<<<<<< HEAD
        _buildSettingsTile(
          icon: Icons.refresh,
          title: "Reset Intro",
          subtitle: "Show intro screens again",
=======
        SettingTile(
          icon: Icons.refresh,
          title: 'Reset Intro',
          subtitle: 'Show intro screens again',
>>>>>>> master
          onTap: () {
            HapticFeedback.lightImpact();
            _confirmResetIntro(context);
          },
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildAppInfoSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: "Version",
          subtitle: "5.8.0",
          onTap: null,
        ),
        _buildSettingsTile(
          icon: Icons.description,
          title: "Privacy Policy",
          subtitle: "Read our privacy policy",
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnackBar(context, "Privacy policy coming soon!");
          },
        ),
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: "Help & Support",
          subtitle: "Get help and contact support",
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnackBar(context, "Help section coming soon!");
=======
  Widget _buildCustomOptionsSection(BuildContext context) {
    return Column(
      children: [
        SettingTile(
          icon: Icons.category_outlined,
          title: 'Income Categories',
          subtitle: 'Manage categories for income',
          onTap: () => _showManageItemsDialog(context, 'Income'),
        ),
        SettingTile(
          icon: Icons.category_outlined,
          title: 'Expense Categories',
          subtitle: 'Manage categories for expenses',
          onTap: () => _showManageItemsDialog(context, 'Expense'),
        ),
        SettingTile(
          icon: Icons.account_balance_outlined,
          title: 'Accounts',
          subtitle: 'Manage your accounts',
          onTap: () => _showManageItemsDialog(context, 'Account'),
        ),
      ],
    );
  }

  void _showManageItemsDialog(BuildContext context, String type) {
    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setStateDialog) {
          final themeViewModel = context.watch<ThemeViewModel>();
          final items = (type == 'Income')
              ? themeViewModel.incomeCategories
              : (type == 'Expense')
                  ? themeViewModel.expenseCategories
                  : themeViewModel.accounts;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Text('Manage ${type}s',
                    style: GoogleFonts.dmSans(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'No ${type.toLowerCase()}s found.',
                            style: GoogleFonts.dmSans(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              leading: (type == 'Income' || type == 'Expense')
                                  ? Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            TransactionUtils.getCategoryColor(
                                                    item)
                                                .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        TransactionUtils.getCategorySvg(item),
                                        colorFilter: ColorFilter.mode(
                                            TransactionUtils.getCategoryColor(
                                                item),
                                            BlendMode.srcIn),
                                        width: 18,
                                        height: 18,
                                      ),
                                    )
                                  : null,
                              title: Text(item, style: GoogleFonts.dmSans()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 20),
                                    onPressed: () => _showEditItemDialog(
                                        context,
                                        item,
                                        type,
                                        (n) => setStateDialog(() {})),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 20),
                                    onPressed: () {
                                      themeViewModel.removeItem(item, type);
                                      setStateDialog(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text('Add $type',
                        style:
                            GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                    onPressed: () => _showEditItemDialog(
                        context, null, type, (n) => setStateDialog(() {})),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditItemDialog(
      BuildContext context, String? old, String type, Function(String) onDone) {
    final controller = TextEditingController(text: old);

    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${old == null ? 'Add' : 'Edit'} $type',
                  style: GoogleFonts.dmSans(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter name...',
                  labelText: '$type Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final val = controller.text.trim();
                        if (val.isNotEmpty) {
                          final themeViewModel =
                              context.read<ThemeViewModel>();
                          if (old == null) {
                            themeViewModel.addItem(val, type);
                          } else {
                            themeViewModel.updateItem(old, val, type);
                          }
                          onDone(val);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
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

  Widget _buildAppInfoSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        SettingTile(
          icon: Icons.info_outline,
          title: 'About ${AppStrings.appNameShort}',
          subtitle: 'Developer, Privacy, Support & More',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            );
>>>>>>> master
          },
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    return ZoomTapAnimation(
      onTap: onTap,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: ResponsiveUtils.getResponsiveEdgeInsets(context,
              horizontal: 16, vertical: 4),
          leading: Container(
            width: ResponsiveUtils.getResponsiveIconSize(context,
                mobile: 40, tablet: 48, desktop: 56),
            height: ResponsiveUtils.getResponsiveIconSize(context,
                mobile: 40, tablet: 48, desktop: 56),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDestructive
                    ? Colors.red.withOpacity(0.3)
                    : Colors.teal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.teal,
              size: ResponsiveUtils.getResponsiveIconSize(context,
                  mobile: 20, tablet: 24, desktop: 28),
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                  mobile: 16, tablet: 18, desktop: 20),
              color: isDestructive ? Colors.red : null,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                  mobile: 13, tablet: 15, desktop: 17),
              color: Colors.grey.shade600,
            ),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
=======
  Widget _buildBudgetSection(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final budget = themeViewModel.monthlyBudget;
    return SettingTile(
      icon: Icons.track_changes,
      title: 'Monthly Budget',
      subtitle: budget > 0
          ? 'Monthly limit: ₹$budget'
          : 'Set a monthly spending limit',
      onTap: () => _showBudgetDialog(context),
    );
  }

  Widget _buildBalanceCalculationTile(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    return SettingTile(
      icon: Icons.calculate_outlined,
      title: 'Join Previous Month Balance',
      subtitle: 'Include previous month balance in current total',
      onTap: null,
      trailing: Switch(
        value: viewModel.joinPreviousMonthBalance,
        onChanged: (value) {
          HapticFeedback.lightImpact();
          viewModel.setJoinPreviousMonthBalance(value);
        },
      ),
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final viewModel = context.read<ThemeViewModel>();
    final controller =
        TextEditingController(text: viewModel.monthlyBudget.toString());
    BlurUtils.showBlurredDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0.0;
              viewModel.setMonthlyBudget(val);
              if (!mounted) return;
              Navigator.pop(context);
              ErrorHandler.showSuccessSnackBar(context, 'Budget updated!');
            },
            child: const Text('Save'),
          ),
        ],
>>>>>>> master
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
<<<<<<< HEAD
=======
    if (!context.mounted) return;
>>>>>>> master
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    final isDark =
        Provider.of<ThemeViewModel>(context, listen: false).isDarkMode;
    final theme = Theme.of(context);

<<<<<<< HEAD
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              "Confirm Delete",
              style: GoogleFonts.nunito(
=======
    BlurUtils.showBlurredDialog(
      context: context,
      child: AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              'Confirm Delete',
              style: GoogleFonts.dmSans(
>>>>>>> master
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
<<<<<<< HEAD
          "Are you sure you want to delete all transactions and reset your balance? This action cannot be undone.",
          style: GoogleFonts.nunito(
=======
          'Are you sure you want to delete all transactions and reset your balance? This action cannot be undone.',
          style: GoogleFonts.dmSans(
>>>>>>> master
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
<<<<<<< HEAD
              "Cancel",
=======
              'Cancel',
>>>>>>> master
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
<<<<<<< HEAD
            label: const Text("Delete All"),
=======
            label: const Text('Delete All'),
>>>>>>> master
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              try {
                final box = await Hive.openBox<double>('balanceBox');
                await box.clear();
<<<<<<< HEAD
                await Provider.of<TransactionViewModel>(context, listen: false)
                    .deleteAllData();
                await Provider.of<PersonViewModel>(context, listen: false)
                    .deleteAllData();
                Navigator.pop(context);
                _showSnackBar(context, "All data deleted successfully!");
              } catch (e) {
                Navigator.pop(context);
                _showSnackBar(
                    context, "Failed to delete all data. Please try again.");
=======
                if (!context.mounted) return;
                await Provider.of<TransactionViewModel>(context,
                        listen: false)
                    .deleteAllData();
                await Provider.of<PersonViewModel>(context, listen: false)
                    .deleteAllData();
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSnackBar(context, 'All data deleted successfully!');
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSnackBar(
                    context, 'Failed to delete all data. Please try again.');
>>>>>>> master
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmResetIntro(BuildContext context) async {
    final isDark =
        Provider.of<ThemeViewModel>(context, listen: false).isDarkMode;
    final theme = Theme.of(context);

<<<<<<< HEAD
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.refresh, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text(
              "Reset Intro",
              style: GoogleFonts.nunito(
=======
    BlurUtils.showBlurredDialog(
      context: context,
      child: AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.refresh, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text(
              'Reset Intro',
              style: GoogleFonts.dmSans(
>>>>>>> master
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
<<<<<<< HEAD
          "This will show the intro screens again the next time you open the app. Your data will remain unchanged.",
          style: GoogleFonts.nunito(
=======
          'This will show the intro screens again the next time you open the app. Your data will remain unchanged.',
          style: GoogleFonts.dmSans(
>>>>>>> master
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
<<<<<<< HEAD
              "Cancel",
=======
              'Cancel',
>>>>>>> master
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
<<<<<<< HEAD
            label: const Text("Reset"),
=======
            label: const Text('Reset'),
>>>>>>> master
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              try {
                final box = await Hive.openBox<double>('balanceBox');
                await box.clear();
                // Reset introCompleted flag in settings box
                final settingsBox = await Hive.openBox('settings');
                await settingsBox.put('introCompleted', false);
<<<<<<< HEAD
                Navigator.pop(context);
                _showSnackBar(context, "Intro reset successfully!");
              } catch (e) {
                Navigator.pop(context);
                _showSnackBar(
                    context, "Failed to reset intro. Please try again.\n$e");
=======
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSnackBar(context, 'Intro reset successfully!');
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSnackBar(
                    context, 'Failed to reset intro. Please try again.\n$e');
>>>>>>> master
              }
            },
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
<<<<<<< HEAD
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
=======
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
>>>>>>> master
}
