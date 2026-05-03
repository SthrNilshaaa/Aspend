import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:local_auth/local_auth.dart';
import '../core/view_models/theme_view_model.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aspends_tracker/l10n/generated/app_localizations.dart';
import 'package:hive/hive.dart';
//import 'dart:io';

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
          biometricOnly: false,
          persistAcrossBackgrounding: true,
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

      if (!mounted) return;
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        //controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            title: l10n.settings,
            centerTitle: true,
          ),

          // Settings Content
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
                      // Theme Section
                      TitledSection(
                        title: l10n.appearance,
                        icon: Icons.palette,
                        children: [
                          _buildThemeCard(context, isDark),
                          const SizedBox(height: 12),
                          _buildLanguagePicker(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                       TitledSection(
                        title: l10n.security,
                        icon: Icons.security,
                        children: [
                          _buildAppLockSection(context),
                          _buildUpiSettingsTile(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Auto Detection Section
                      TitledSection(
                        title: l10n.autoDetection,
                        icon: Icons.auto_awesome,
                        children: [
                          _buildAutoDetectionSection(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Backup & Export Section
                      TitledSection(
                        title: l10n.backupExport,
                        icon: Icons.backup,
                        children: [
                          _buildBackupSection(context, isDark),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Data Management Section
                      TitledSection(
                        title: l10n.dataManagement,
                        icon: Icons.storage,
                        children: [
                          _buildDataManagementSection(context, isDark),
                        ],
                      ),
                      const SizedBox(height: 24),

                      TitledSection(
                        title: l10n.budgetingBalance,
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
                        title: l10n.customDropdowns,
                        icon: Icons.list_alt,
                        children: [
                          _buildCustomOptionsSection(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // App Info Section
                      TitledSection(
                        title: l10n.appInformation,
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
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final useAdaptive = context.watch<ThemeViewModel>().useAdaptiveColor;
    final l10n = AppLocalizations.of(context)!;
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
                        l10n.theme,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        l10n.chooseTheme,
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
      ),
    );
  }

  Widget _buildLanguagePicker(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final l10n = AppLocalizations.of(context)!;

    String languageName = l10n.systemDefault;
    if (themeViewModel.locale?.languageCode == 'en') languageName = 'English';
    if (themeViewModel.locale?.languageCode == 'hi') languageName = 'हिन्दी';
    if (themeViewModel.locale?.languageCode == 'es') languageName = 'Español';
    if (themeViewModel.locale?.languageCode == 'fr') languageName = 'Français';
    if (themeViewModel.locale?.languageCode == 'de') languageName = 'Deutsch';
    if (themeViewModel.locale?.languageCode == 'ja') languageName = '日本語';
    if (themeViewModel.locale?.languageCode == 'zh') languageName = '中文';
    if (themeViewModel.locale?.languageCode == 'ar') languageName = 'العربية';
    if (themeViewModel.locale?.languageCode == 'pt') languageName = 'Português';
    if (themeViewModel.locale?.languageCode == 'ru') languageName = 'Русский';

    return SettingTile(
      icon: Icons.language_rounded,
      title: l10n.language,
      subtitle: languageName,
      onTap: () {
        _showLanguageDialog(context);
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final themeViewModel = context.read<ThemeViewModel>();
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, String>> langs = [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'हिन्दी'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'ja', 'name': '日本語'},
      {'code': 'zh', 'name': '中文'},
      {'code': 'ar', 'name': 'العربية'},
      {'code': 'pt', 'name': 'Português'},
      {'code': 'ru', 'name': 'Русский'},
    ];

    BlurUtils.showBlurredDialog(
      context: context,
      child: AlertDialog(
        title: Text(l10n.language),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(l10n.systemDefault),
                trailing: themeViewModel.locale == null
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeViewModel.setLocale(null);
                  Navigator.pop(context);
                },
              ),
              ...langs.map((l) => ListTile(
                title: Text(l['name']!),
                trailing: themeViewModel.locale?.languageCode == l['code']
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeViewModel.setLocale(Locale(l['code']!, ''));
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSegmentedControl(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildThemeOption(context, ThemeMode.system, Icons.settings_suggest_rounded, l10n.systemDefault),
          _buildThemeOption(context, ThemeMode.light, Icons.light_mode_rounded, l10n.lightMode),
          _buildThemeOption(context, ThemeMode.dark, Icons.dark_mode_rounded, l10n.darkMode),
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
              AppStrings.adaptiveColor,
              style: GoogleFonts.dmSans(
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
            viewModel.setUseAdaptiveColor(value);
          },
        ),
      ],
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
          final localAuth = LocalAuthentication();
          try {
            if (value) {
              final canCheck = await localAuth.canCheckBiometrics ||
                  await localAuth.isDeviceSupported();
              if (!mounted) return;
              if (!canCheck) {
                _showSnackBar(context,
                    'Device does not support biometrics or device authentication.');
                return;
              }
              final didAuthenticate = await localAuth.authenticate(
                localizedReason: 'Authenticate to enable app lock',
                biometricOnly: false,
                persistAcrossBackgrounding: true,
              );
              if (!mounted) return;
              if (!didAuthenticate) {
                _showSnackBar(
                    context, 'Authentication failed. App lock not enabled.');
                return;
              }
            }
            await _setAppLockEnabled(value);
            if (!mounted) return;
            _showSnackBar(
                context, value ? 'App lock enabled.' : 'App lock disabled.');
          } catch (e) {
            if (!mounted) return;
            _showSnackBar(context, 'Error: \n$e');
          }
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
        ],
      ),
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
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              final file = await PDFService.generateHomeTransactionPDF();
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
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              final file = await PDFService.generatePeopleTransactionPDF();
              if (!mounted) return;
              await Printing.sharePdf(
                  bytes: await file.readAsBytes(),
                  filename: 'person_transactions.pdf');
              if (!mounted) return;
              _showSnackBar(context, 'People data exported!');
            } catch (e) {
              if (!mounted) return;
              _showSnackBar(context, 'People data export failed: $e');
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
          onTap: () {
            HapticFeedback.lightImpact();
            _confirmDeleteAll(context);
          },
        ),
        SettingTile(
          icon: Icons.refresh,
          title: 'Reset Intro',
          subtitle: 'Show intro screens again',
          onTap: () {
            HapticFeedback.lightImpact();
            _confirmResetIntro(context);
          },
        ),
      ],
    );
  }

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
          },
        ),
      ],
    );
  }

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
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
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
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all transactions and reset your balance? This action cannot be undone.',
          style: GoogleFonts.dmSans(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Delete All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              try {
                final box = await Hive.openBox<double>('balanceBox');
                await box.clear();
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
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'This will show the intro screens again the next time you open the app. Your data will remain unchanged.',
          style: GoogleFonts.dmSans(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
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
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSnackBar(context, 'Intro reset successfully!');
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                _showSnackBar(
                    context, 'Failed to reset intro. Please try again.\n$e');
              }
            },
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
