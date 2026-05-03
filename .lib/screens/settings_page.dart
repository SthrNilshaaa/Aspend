import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' hide GlassAppBar;

import '../core/view_models/theme_view_model.dart';
import '../core/services/backup_service.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/view_models/person_view_model.dart';
import '../core/services/pdf_service.dart';
import '../core/services/transaction_detection_service.dart';
import '../core/services/native_bridge.dart';
import '../core/utils/transaction_parser.dart';
import '../core/utils/responsive_utils.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/blur_utils.dart';
import '../core/utils/transaction_utils.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_constants.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_assets.dart';

import 'detection_history_page.dart';
import 'app_selection_page.dart';
import 'about_page.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/monitoring_setup_dialog.dart';

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
    final box = await Hive.openBox(AppConstants.settingsBox);
    if (!mounted) return;
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
          if (!mounted) return;
          ErrorHandler.showErrorSnackBar(context,
              'Biometric authentication is not supported on this device');
          return;
        }

        if (!canCheckBiometrics) {
          if (!mounted) return;
          ErrorHandler.showErrorSnackBar(
              context, 'No biometric authentication methods available');
          return;
        }

        final didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Authenticate to enable app lock',
        );

        if (!didAuthenticate) {
          if (!mounted) return;
          ErrorHandler.showErrorSnackBar(
              context, 'Authentication failed. App lock not enabled.');
          return;
        }
      }

      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put('appLockEnabled', enabled);
      if (!mounted) return;
      setState(() {
        _appLockEnabled = enabled;
      });

      ErrorHandler.showSuccessSnackBar(
          context,
          enabled
              ? 'App lock enabled successfully'
              : 'App lock disabled successfully');
    } catch (e) {
      if (!mounted) return;
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const CustomGlassAppBar(
            title: AppStrings.settings,
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                      horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitledSection(
                        title: AppStrings.appearance,
                        icon: Icons.palette,
                        children: [
                          _buildThemeCard(context, isDark),
                          _buildColorPickerTile(context),
                          _buildAdaptiveColorSwitch(context),
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
                      TitledSection(
                        title: AppStrings.autoDetection,
                        icon: Icons.auto_awesome,
                        children: [
                          _buildAutoDetectionSection(context),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TitledSection(
                        title: AppStrings.backupExport,
                        icon: Icons.backup,
                        children: [
                          _buildBackupSection(context, isDark),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                      TitledSection(
                        title: AppStrings.customDropdowns,
                        icon: Icons.list_alt,
                        children: [
                          _buildCustomOptionsSection(context),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TitledSection(
                        title: AppStrings.appInformation,
                        icon: Icons.info,
                        children: [
                          _buildAppInfoSection(context, isDark),
                        ],
                      ),
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
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.palette,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.theme,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      AppStrings.chooseTheme,
                      style: GoogleFonts.dmSans(
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
          _buildThemeSegmentedControl(context),
        ],
      ),
    );
  }

  Widget _buildThemeSegmentedControl(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                color: theme.colorScheme.primary.withOpacity(0.3),
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

  Widget _buildAdaptiveColorSwitch(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    return SettingTile(
      icon: Icons.color_lens,
      title: AppStrings.adaptiveColor,
      subtitle: 'Use system colors on supported devices',
      trailing: Switch(
        value: viewModel.useAdaptiveColor,
        onChanged: (value) {
          HapticFeedback.lightImpact();
          viewModel.setUseAdaptiveColor(value);
        },
      ),
    );
  }

  Widget _buildColorPickerTile(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
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
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppLockSection(BuildContext context) {
    return SettingTile(
      icon: Icons.lock,
      title: AppStrings.appLock,
      subtitle: AppStrings.appLockDesc,
      trailing: Switch(
        value: _appLockEnabled,
        onChanged: (value) async {
          await _setAppLockEnabled(value);
        },
      ),
    );
  }

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
        ),
      ],
    );
  }

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
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

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
              return Switch(
                value: isEnabled,
                onChanged: (value) async {
                  HapticFeedback.lightImpact();
                  try {
                    if (value) {
                      final hasPermission = await NativeBridge.checkNotificationPermission();
                      if (!hasPermission) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: const MonitoringSetupDialog(),
                          ),
                        );
                        if (confirmed != true) return;
                      }
                      await NativeBridge.requestBatteryOptimization();
                    }
                    await TransactionDetectionService.setEnabled(value);
                    if (mounted) setState(() {});
                  } catch (e) {
                    if (mounted) {
                      ErrorHandler.handleError(context, e, customMessage: 'Failed to update auto-detection');
                    }
                  }
                },
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
                ErrorHandler.showSuccessSnackBar(context, 'Recent data processed successfully!');
              }
            } catch (e) {
              if (mounted) ErrorHandler.handleError(context, e, customMessage: 'Error processing data');
            }
          },
        ),
        SettingTile(
          icon: Icons.manage_history,
          title: 'Show Detection History',
          subtitle: 'View detailed logs of detected transactions',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DetectionHistoryPage()));
          },
        ),
      ],
    );
  }

  Widget _buildBackupSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        SettingTile(
          icon: Icons.upload_file,
          title: 'Export Transactions (CSV)',
          subtitle: 'Export your transactions to CSV',
          onTap: () async {
            try {
              await BackupService.exportToCsvAndShare();
              if (mounted) ErrorHandler.showSuccessSnackBar(context, 'Export completed!');
            } catch (e) {
              if (mounted) ErrorHandler.handleError(context, e, customMessage: 'Export failed');
            }
          },
        ),
        SettingTile(
          icon: Icons.backup,
          title: 'Full Backup (JSON)',
          subtitle: 'Backup all data to JSON',
          onTap: () async {
            try {
              await BackupService.exportAllDataJsonAndShare();
              if (mounted) ErrorHandler.showSuccessSnackBar(context, 'Backup completed!');
            } catch (e) {
              if (mounted) ErrorHandler.handleError(context, e, customMessage: 'Backup failed');
            }
          },
        ),
        SettingTile(
          icon: Icons.restore,
          title: 'Restore Backup (JSON)',
          subtitle: 'Restore all data from JSON backup',
          onTap: () async {
            try {
              final success = await BackupService.importDataFromJson(context);
              if (mounted && success) ErrorHandler.showSuccessSnackBar(context, 'Data restored!');
            } catch (e) {
              if (mounted) ErrorHandler.handleError(context, e, customMessage: 'Restore failed');
            }
          },
        ),
        SettingTile(
          icon: Icons.picture_as_pdf,
          title: 'Export as PDF',
          subtitle: 'Generate PDF reports',
          onTap: () async {
            try {
              final file = await PDFService.generateHomeTransactionPDF();
              await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'home_transactions.pdf');
            } catch (e) {
              if (mounted) ErrorHandler.handleError(context, e, customMessage: 'PDF export failed');
            }
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        SettingTile(
          icon: Icons.delete_forever,
          title: 'Delete All Data',
          subtitle: '⚠️ This action cannot be undone',
          isDestructive: true,
          onTap: () => _confirmDeleteAll(context),
        ),
        SettingTile(
          icon: Icons.refresh,
          title: 'Reset Intro',
          subtitle: 'Show intro screens again',
          onTap: () => _confirmResetIntro(context),
        ),
      ],
    );
  }

  Widget _buildBudgetSection(BuildContext context) {
    return SettingTile(
      icon: Icons.wallet_membership,
      title: 'Monthly Budget',
      subtitle: 'Set and track your monthly budget',
      onTap: () {
        // Implementation for budget settings
      },
    );
  }

  Widget _buildBalanceCalculationTile(BuildContext context) {
    return SettingTile(
      icon: Icons.calculate_outlined,
      title: 'Balance Calculation',
      subtitle: 'Configure how your balance is calculated',
      onTap: () {
        // Implementation for balance settings
      },
    );
  }

  Widget _buildCustomOptionsSection(BuildContext context) {
    return Column(
      children: [
        SettingTile(
          icon: Icons.category_outlined,
          title: 'Manage Categories',
          subtitle: 'Add or remove transaction categories',
          onTap: () {
            // Implementation
          },
        ),
        SettingTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Manage Accounts',
          subtitle: 'Add or remove payment accounts',
          onTap: () {
            // Implementation
          },
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        SettingTile(
          icon: Icons.info_outline,
          title: 'About Aspend',
          subtitle: 'Version 5.8.0',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
          },
        ),
      ],
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    BlurUtils.showBlurredDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text('This will permanently delete all your transactions and settings. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await Hive.box(AppConstants.transactionsBox).clear();
              final box2 = await Hive.openBox(AppConstants.settingsBox);
              await box2.clear();
              if (mounted) {
                Navigator.pop(context);
                ErrorHandler.showSuccessSnackBar(context, 'All data cleared');
              }
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  void _confirmResetIntro(BuildContext context) {
    BlurUtils.showBlurredDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Reset Intro?'),
        content: const Text('This will show the introduction screens again on next app launch.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final box = await Hive.openBox(AppConstants.settingsBox);
              await box.put('introCompleted', false);
              if (mounted) {
                Navigator.pop(context);
                ErrorHandler.showSuccessSnackBar(context, 'Intro reset successful');
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
