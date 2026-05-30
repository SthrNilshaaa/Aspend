import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/services/native_bridge.dart';
import 'package:aspends_tracker/l10n/generated/app_localizations.dart';

class MonitoringSetupDialog extends StatefulWidget {
  const MonitoringSetupDialog({super.key});

  @override
  State<MonitoringSetupDialog> createState() => _MonitoringSetupDialogState();
}

class _MonitoringSetupDialogState extends State<MonitoringSetupDialog>
    with WidgetsBindingObserver {
  bool _isNotificationPermissionGranted = false;
  bool _isSmsPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await NativeBridge.checkNotificationPermission();
    final smsStatus = await NativeBridge.checkSmsPermission();

    if (mounted) {
      setState(() {
        _isNotificationPermissionGranted = notificationStatus;
        _isSmsPermissionGranted = smsStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: AppDimensions.blurRadiusLarge,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Beautiful Header Circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.autoDetectionSetup,
                  style: GoogleFonts.dmSans(
                    fontSize: AppTypography.fontSizeXLarge,
                    fontWeight: AppTypography.fontWeightBold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.autoDetectionSetupDesc,
                  style: GoogleFonts.dmSans(
                    fontSize: AppTypography.fontSizeSmall + 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Step 1: Notification Access Card
                _buildPermissionStep(
                  context: context,
                  title: l10n.notificationAccess,
                  description: l10n.notificationAccessDesc,
                  icon: Icons.notifications_active_outlined,
                  isGranted: _isNotificationPermissionGranted,
                  isDark: isDark,
                  onGrant: () async {
                    await NativeBridge.requestNotificationPermission();
                  },
                ),
                const SizedBox(height: 12),

                // Step 2: SMS Permission Card
                _buildPermissionStep(
                  context: context,
                  title: l10n.smsPermission,
                  description: l10n.smsPermissionDesc,
                  icon: Icons.sms_outlined,
                  isGranted: _isSmsPermissionGranted,
                  isDark: isDark,
                  onGrant: () async {
                    await NativeBridge.requestSmsPermission();
                    await Future.delayed(const Duration(milliseconds: 500));
                    await _checkPermissions();
                    await Future.delayed(const Duration(milliseconds: 1000));
                    await _checkPermissions();
                  },
                ),
                const SizedBox(height: 28),

                // Action Buttons Row
                Column(
                  children: [
                    ZoomTapAnimation(
                      onTap: (_isNotificationPermissionGranted || _isSmsPermissionGranted)
                          ? () => Navigator.pop(context, true)
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: (_isNotificationPermissionGranted || _isSmsPermissionGranted)
                              ? LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                )
                              : null,
                          color: (_isNotificationPermissionGranted || _isSmsPermissionGranted)
                              ? null
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05)),
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                          boxShadow: (_isNotificationPermissionGranted || _isSmsPermissionGranted)
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.finishSetup.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: AppTypography.fontSizeSmall + 1,
                            fontWeight: AppTypography.fontWeightBold,
                            color: (_isNotificationPermissionGranted || _isSmsPermissionGranted)
                                ? Colors.white
                                : (isDark ? Colors.white38 : Colors.black38),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ZoomTapAnimation(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.cancel.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: AppTypography.fontSizeSmall,
                            fontWeight: AppTypography.fontWeightBold,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
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
      ),
    );
  }

  Widget _buildPermissionStep({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool isGranted,
    required bool isDark,
    required VoidCallback onGrant,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusStandard),
        border: Border.all(
          color: isGranted
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.primaryGreen.withValues(alpha: 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isGranted ? AppColors.accentGreen : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontWeight: AppTypography.fontWeightBold,
                    fontSize: AppTypography.fontSizeSmall + 1,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: AppTypography.fontSizeSmall - 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isGranted)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              ),
            )
          else
            ZoomTapAnimation(
              onTap: onGrant,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall - 2),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  l10n.grant.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: AppTypography.fontSizeSmall - 1,
                    fontWeight: AppTypography.fontWeightBold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
