import 'dart:ui';

import 'package:flutter/material.dart';
import '../view_models/theme_view_model.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
//import 'dart:io';

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
import 'detection_history_page.dart';

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
    final box = await Hive.openBox('settings');
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

      final box = await Hive.openBox('settings');
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
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveAppBarHeight(context),
            floating: true,
            pinned: true,
            elevation: 1,
            backgroundColor: Colors.transparent,
            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                // Persistent Glass Effect Layer
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.surface.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Subtle Bottom Border
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Settings',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                      ),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme Section
                  _buildSectionHeader('Appearance', Icons.palette),
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
                      'Auto Transaction Detection', Icons.auto_awesome),
                  const SizedBox(height: 10),
                  _buildAutoDetectionSection(context),
                  const SizedBox(height: 18),
                  // Backup & Export Section
                  _buildSectionHeader('Backup & Export', Icons.backup),
                  const SizedBox(height: 10),
                  _buildBackupSection(context, isDark),
                  const SizedBox(height: 18),
                  // Data Management Section
                  _buildSectionHeader('Data Management', Icons.storage),
                  const SizedBox(height: 10),
                  _buildDataManagementSection(context, isDark),
                  const SizedBox(height: 18),
                  _buildSectionHeader('Budgeting', Icons.wallet_membership),
                  const SizedBox(height: 10),
                  _buildBudgetSection(context),
                  const SizedBox(height: 18),
                  // App Info Section
                  _buildSectionHeader('App Information', Icons.info),
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
        ],
      ),
    );
  }

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
                        'Theme',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Choose your preferred theme',
                        style: GoogleFonts.nunito(
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
              'Adaptive Android Color',
              style: GoogleFonts.nunito(
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
            viewModel.setAdaptiveColor(value);
          },
        ),
      ],
    );
  }

  Widget _buildColorPickerTile(BuildContext context) {
    final viewModel = context.watch<ThemeViewModel>();
    final currentColor = viewModel.customSeedColor ?? Colors.teal;
    return _buildSettingsTile(
      icon: Icons.color_lens,
      title: 'App Color',
      subtitle: 'Select a custom app color',
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
        );
      },
    );
  }

  Widget _buildAppLockSection(BuildContext context) {
    return _buildSettingsTile(
      icon: Icons.lock,
      title: 'App Lock',
      subtitle: 'Require device authentication to open app',
      onTap: null,
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
                localizedReason: 'Authenticate to disable app lock',
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
        _buildSettingsTile(
          icon: Icons.auto_awesome,
          title: 'Auto Transaction Detection',
          subtitle: 'Automatically detect transactions from notifications',
          onTap: null,
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
        _buildSettingsTile(
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
        _buildSettingsTile(
          icon: Icons.bug_report_outlined,
          title: 'Test Detection Logic',
          subtitle: 'Simulate a notification to verify parsing',
          onTap: () => _showTestDetectionDialog(context),
        ),
        _buildSettingsTile(
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
                style: GoogleFonts.nunito(
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
              style: GoogleFonts.nunito(
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
              style: GoogleFonts.nunito(
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
        ],
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.upload_file,
          title: 'Export Transactions',
          subtitle: 'Backup your data to CSV',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await DataExporter.shareBackupFile();
              _showSnackBar(context, 'Export completed successfully!');
            } catch (e) {
              _showSnackBar(context, 'Export failed: $e');
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.download,
          title: 'Import Transactions',
          subtitle: 'Restore data from backup',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await DataImporter.importFromJson(context);
              _showSnackBar(context, 'Import completed successfully!');
            } catch (e) {
              _showSnackBar(context, 'Import failed: $e');
            }
          },
        ),
        _buildSettingsTile(
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
        _buildSettingsTile(
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
        _buildSettingsTile(
          icon: Icons.ios_share,
          title: 'Export People Data (JSON)',
          subtitle: 'Backup people and transactions',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await PersonBackupHelper.exportToJsonAndShare();
              _showSnackBar(context, 'People data exported!');
            } catch (e) {
              _showSnackBar(context, 'People data export failed: $e');
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.import_export,
          title: 'Import People Data (JSON)',
          subtitle: 'Restore people data from backup',
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              await PersonBackupHelper.importFromJson(context);
              _showSnackBar(context, 'People data imported successfully!');
            } catch (e) {
              _showSnackBar(context, 'People data import failed: $e');
            }
          },
        ),
        _buildSettingsTile(
          icon: Icons.delete_forever,
          title: 'Delete All Data',
          subtitle: '⚠️ This action cannot be undone',
          isDestructive: true,
          onTap: () {
            HapticFeedback.lightImpact();
            _confirmDeleteAll(context);
          },
        ),
        _buildSettingsTile(
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

  Widget _buildAppInfoSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'Version',
          subtitle: '5.8.0',
          onTap: null,
        ),
        _buildSettingsTile(
          icon: Icons.description,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnackBar(context, 'Privacy policy coming soon!');
          },
        ),
        _buildSettingsTile(
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
    return _buildSettingsTile(
      icon: Icons.track_changes,
      title: 'Monthly Budget',
      subtitle: budget > 0
          ? 'Monthly limit: ₹$budget'
          : 'Set a monthly spending limit',
      onTap: () => _showBudgetDialog(context),
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
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.teal.withValues(alpha: 0.3),
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
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all transactions and reset your balance? This action cannot be undone.',
          style: GoogleFonts.nunito(
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
                await Provider.of<TransactionViewModel>(context, listen: false)
                    .deleteAllData();
                await Provider.of<PersonViewModel>(context, listen: false)
                    .deleteAllData();
                Navigator.pop(context);
                _showSnackBar(context, 'All data deleted successfully!');
              } catch (e) {
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
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'This will show the intro screens again the next time you open the app. Your data will remain unchanged.',
          style: GoogleFonts.nunito(
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
                Navigator.pop(context);
                _showSnackBar(context, 'Intro reset successfully!');
              } catch (e) {
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
