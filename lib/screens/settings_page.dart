import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:local_auth/local_auth.dart';
import '../view_models/theme_view_model.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
//import 'dart:io';

import '../services/backup_service.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/person_view_model.dart';
import '../services/pdf_service.dart';
import '../services/transaction_detection_service.dart';
import '../services/native_bridge.dart';
import '../utils/responsive_utils.dart';
import '../utils/error_handler.dart';
import 'detection_history_page.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/settings_widgets.dart';
import '../const/app_strings.dart';
import '../const/app_constants.dart';

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
          ErrorHandler.showErrorSnackBar(context,
              'Biometric authentication is not supported on this device');
          return;
        }

        if (!canCheckBiometrics) {
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
          ErrorHandler.showErrorSnackBar(
              context, 'Authentication failed. App lock not enabled.');
          return;
        }
      }

      final box = await Hive.openBox(AppConstants.settingsBox);
      await box.put('appLockEnabled', enabled);
      setState(() {
        _appLockEnabled = enabled;
      });

      ErrorHandler.showSuccessSnackBar(
          context,
          enabled
              ? 'App lock enabled successfully'
              : 'App lock disabled successfully');
    } catch (e) {
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
          GlassAppBar(
            title: AppStrings.settings,
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
                        title: AppStrings.appearance,
                        icon: Icons.palette,
                        children: [
                          _buildThemeCard(context, isDark),
                          if (!useAdaptive) ...[
                            const SizedBox(height: 12),
                            _buildColorPickerTile(context),
                          ],
                          const SizedBox(height: 12),
                          _buildAdaptiveColorSwitch(context),
                        ],
                      ),
                      const SizedBox(height: 24),

                      TitledSection(
                        title: AppStrings.security,
                        icon: Icons.security,
                        children: [
                          _buildAppLockSection(context),
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
                      const SizedBox(height: 8),
                      // Add developer credit at the very bottom
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            AppStrings.developedBy,
                            style: GoogleFonts.dmSans(
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
            ),
          ),
        ],
      ),
    );
  }

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
            DropdownButtonHideUnderline(
              child: DropdownButton<ThemeMode>(
                value: context.watch<ThemeViewModel>().themeMode,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (mode) {
                  HapticFeedback.lightImpact();
                  if (mode != null) {
                    context.read<ThemeViewModel>().setThemeMode(mode);
                  }
                },
                items: ThemeMode.values.map((mode) {
                  final label = mode.toString().split('.').last.capitalize();
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(label),
                  );
                }).toList(),
              ),
            ),
          ],
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
    final currentColor = viewModel.customSeedColor ?? Colors.teal;
    return SettingTile(
      icon: Icons.color_lens,
      title: AppStrings.appColor,
      subtitle: AppStrings.selectColor,
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
              if (!didAuthenticate) {
                _showSnackBar(
                    context, 'Authentication failed. App lock not enabled.');
                return;
              }
            }
            await _setAppLockEnabled(value);
            _showSnackBar(
                context, value ? 'App lock enabled.' : 'App lock disabled.');
          } catch (e) {
            _showSnackBar(context, 'Error: \n$e');
          }
        },
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
                            final confirmed =
                                await _showAutoDetectionInfoDialog(context);
                            if (confirmed != true) {
                              setState(() {});
                              return;
                            }
                            await NativeBridge.requestNotificationPermission();
                          }

                          final notificationAccess =
                              await NativeBridge.checkNotificationPermission();
                          if (!notificationAccess && mounted) {
                            ErrorHandler.showWarningSnackBar(context,
                                'Enabled: Please make sure to allow Aspend in the notification access settings.');
                          }

                          await NativeBridge.requestBatteryOptimization();
                        }

                        await TransactionDetectionService.setEnabled(value);

                        if (mounted) {
                          ErrorHandler.showSuccessSnackBar(
                              context,
                              value
                                  ? 'Auto-detection enabled!'
                                  : 'Auto-detection disabled!');
                        }

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
              if (mounted) {
                ErrorHandler.handleError(context, e,
                    customMessage: 'Error processing data');
              }
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
      ],
    );
  }

  void _showTestDetectionDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text:
          'Alert: Your account XX1234 has been debited by Rs. 500.00 for a purchase at AMAZON. Ref: 12345678.',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulate Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a sample notification message to see how our AI parser handles it.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Paste notification text here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text;
              Navigator.pop(context);

              // Directly call the service logic
              await TransactionDetectionService.processNotification(
                  'Test', text,
                  packageName: 'com.test.bank');

              if (mounted) {
                ErrorHandler.showInfoSnackBar(
                    context, 'Test processed. Check History for results.');
              }
            },
            child: const Text('Run Test'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showAutoDetectionInfoDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = context.read<ThemeViewModel>().isDarkMode;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Auto Transaction \n Detection',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  // fontSize: 20,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This feature will automatically detect transactions from:',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
                '🔔 App notifications', 'Monitors payment app notifications'),
            _buildInfoItem('📱 Banking notifications',
                'Detects UPI, ATM, and banking transactions'),
            _buildInfoItem('💰 Automatic categorization',
                'Categorizes transactions based on bank keywords'),
            const SizedBox(height: 12),
            Text(
              'Required permissions:',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
                '🔔 Notification access', 'To monitor payment notifications'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                "💡 Tip: The app will only process messages that contain transaction amounts and keywords like 'credited', 'debited', 'paid', etc.",
                style: GoogleFonts.dmSans(
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
              'Cancel',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, false);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, true);
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }

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
              _showSnackBar(context, 'Export completed successfully!');
            } catch (e) {
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
              _showSnackBar(context, 'Backup completed!');
            } catch (e) {
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
              if (success) {
                _showSnackBar(context, 'Data restored successfully!');
                // Restart app or reload all data might be needed,
                // but since we are using reactive Hive watchers, it should work.
              } else {
                _showSnackBar(context, 'Restore failed or cancelled');
              }
            } catch (e) {
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
              await Printing.sharePdf(
                  bytes: await file.readAsBytes(),
                  filename: 'home_transactions.pdf');
              _showSnackBar(context, 'PDF exported successfully!');
            } catch (e) {
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
              await Printing.sharePdf(
                  bytes: await file.readAsBytes(),
                  filename: 'person_transactions.pdf');
              _showSnackBar(context, 'People data exported!');
            } catch (e) {
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
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
        );
      },
    );
  }

  void _showEditItemDialog(
      BuildContext context, String? old, String type, Function(String) onDone) {
    final controller = TextEditingController(text: old);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                          final themeViewModel = context.read<ThemeViewModel>();
                          if (old == null)
                            themeViewModel.addItem(val, type);
                          else
                            themeViewModel.updateItem(old, val, type);
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
          title: 'Version',
          subtitle: '5.9.1',
          onTap: null,
        ),
        SettingTile(
          icon: Icons.description,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnackBar(context, 'Privacy policy coming soon!');
          },
        ),
        SettingTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnackBar(context, 'Help section coming soon!');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                await Provider.of<TransactionViewModel>(context, listen: false)
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
