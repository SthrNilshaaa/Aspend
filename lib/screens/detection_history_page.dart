import 'package:flutter/material.dart';
import 'package:aspends_tracker/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/const/app_colors.dart';
import '../core/models/detection_history.dart';
import '../core/services/transaction_detection_service.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_assets.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/repositories/settings_repository.dart';
import '../core/utils/transaction_parser.dart';

class DetectionHistoryPage extends StatefulWidget {
  const DetectionHistoryPage({super.key});

  @override
  State<DetectionHistoryPage> createState() => _DetectionHistoryPageState();
}

class _DetectionHistoryPageState extends State<DetectionHistoryPage> {
  String? _searchQuery;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIndices.add(index);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _enterSelectionMode(int index) {
    setState(() {
      _isSelectionMode = true;
      _selectedIndices.add(index);
    });
    HapticFeedback.mediumImpact();
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndices.clear();
    });
  }

  Future<void> _bulkDelete(List<int> indices) async {
    final l10n = AppLocalizations.of(context)!;
    final box = Hive.box<DetectionHistory>('detection_history');
    // Important: sort indices descending to avoid shifting issues when deleting
    final sortedIndices = List<int>.from(indices)
      ..sort((a, b) => b.compareTo(a));

    _exitSelectionMode();
    for (var i in sortedIndices) {
      await box.deleteAt(i);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logsDeleted(indices.length))),
      );
    }
  }

  Future<void> _bulkIgnore(List<int> indices) async {
    final l10n = AppLocalizations.of(context)!;
    final box = Hive.box<DetectionHistory>('detection_history');
    final settings = SettingsRepository();
    final ignored = settings.getIgnoredPatterns();

    int count = 0;
    for (var i in indices) {
      final entry = box.getAt(i);
      if (entry != null) {
        // Simple logic: ignore first word if it looks like a sender/merchant
        final words = entry.text.split(' ');
        if (words.isNotEmpty) {
          final word = words[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
          if (word.length > 3 && !ignored.contains(word)) {
            ignored.add(word);
            count++;
          }
        }
      }
    }

    if (count > 0) {
      await TransactionDetectionService.updateIgnoredPatterns(ignored);
      // Also delete the ignored items from history
      await _bulkDelete(indices);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.patternsIgnored(count))),
        );
      }
    } else {
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            title: _isSelectionMode
                ? '${_selectedIndices.length} Selected'
                : l10n.autoDetection,
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (_isSelectionMode) {
                  _exitSelectionMode();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppDimensions.paddingSmall +
                        AppDimensions.paddingSmall),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Icon(
                        _isSelectionMode ? Icons.close : Icons.arrow_back,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (_isSelectionMode) ...[
                IconButton(
                  icon: const Icon(Icons.block_flipped, color: Colors.orange),
                  tooltip: 'Ignore Patterns',
                  onPressed: () => _bulkIgnore(_selectedIndices.toList()),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete Selected',
                  onPressed: () => _bulkDelete(_selectedIndices.toList()),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await TransactionDetectionService
                          .recheckSkippedTransactions();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.recheckComplete)),
                        );
                      }
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          width: 1.3,
                        ),
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showClearConfirmation(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          width: 1.3,
                        ),
                      ),
                      child: const Icon(Icons.delete_sweep_outlined),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SliverToBoxAdapter(
            child: _buildSearchSection(context),
          ),
          ValueListenableBuilder(
            valueListenable:
                Hive.box<DetectionHistory>('detection_history').listenable(),
            builder: (context, Box<DetectionHistory> box, _) {
              if (box.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.history_toggle_off,
                    title: l10n.noTransactions,
                  ),
                );
              }

              var entries = box.values.toList().reversed.toList();
              if (_searchQuery != null && _searchQuery!.isNotEmpty) {
                final query = _searchQuery!.trim().toLowerCase();
                final rangeMatch =
                    RegExp(r'^([><])\s*(\d+(\.\d+)?)$').firstMatch(query);

                if (rangeMatch != null) {
                  final op = rangeMatch.group(1);
                  final target = double.tryParse(rangeMatch.group(2)!) ?? 0.0;
                  entries = entries.where((e) {
                    final amt = TransactionParser.parseAmount(e.text);
                    if (amt == null) return false;
                    return op == '>' ? amt > target : amt < target;
                  }).toList();
                } else {
                  entries = entries.where((e) {
                    return e.text.toLowerCase().contains(query) ||
                        (e.reason != null &&
                            e.reason!.toLowerCase().contains(query)) ||
                        (e.packageName != null &&
                            e.packageName!.toLowerCase().contains(query));
                  }).toList();
                }
              }

              if (entries.isEmpty && _searchQuery != null) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.search_off,
                    title: l10n.noTransactions,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingStandard,
                    vertical: AppDimensions.paddingSmall),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final actualIndex = box.length - 1 - index;
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(
                          entry: entry,
                          isSelectionMode: _isSelectionMode,
                          isSelected: _selectedIndices.contains(actualIndex),
                          onTap: () => _isSelectionMode
                              ? _toggleSelection(actualIndex)
                              : null,
                          onLongPress: () => _enterSelectionMode(actualIndex),
                        ),
                      );
                    },
                    childCount: entries.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingStandard,
          vertical: AppDimensions.paddingStandard),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.primaryColor.withValues(alpha: 0.05)
                    // : Colors.black.withValues(alpha: 0.05),
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMinLarge),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.balanceCardDarkModePositive
                              : AppColors.balanceCardLightModePositive,
                          // color: theme.colorScheme.primary.withValues(alpha: 0.05),
                          border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              width: 1.4),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusRegular)),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusMedium),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              SvgAppIcons.searchIcon,
                              colorFilter: const ColorFilter.mode(
                                  // theme.colorScheme.primary,
                                  AppColors.accentGreen,
                                  BlendMode.srcIn),
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().isEmpty
                              ? null
                              : val.trim().toLowerCase();
                        });
                      },
                      //transaparnt search bar
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        hintStyle: GoogleFonts.dmSans(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          fontSize: AppTypography.fontSizeSmall,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchQuery != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeRegular,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.1),
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

  // Widget _buildSearchSection(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final isDark = context.watch<ThemeViewModel>().isDarkMode;
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(
  //         horizontal: AppDimensions.paddingStandard,
  //         vertical: AppDimensions.paddingSmall),
  //     child: Container(
  //       height: 54,
  //       decoration: BoxDecoration(
  //         color: isDark
  //             ? Colors.white.withValues(alpha: 0.05)
  //             : Colors.black.withValues(alpha: 0.05),
  //         borderRadius: BorderRadius.circular(AppDimensions.borderRadiusFull),
  //         border: Border.all(
  //           color: theme.dividerColor.withValues(alpha: 0.1),
  //           width: 1,
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(6.0),
  //             child: Container(
  //               width: 42,
  //               height: 42,
  //               decoration: BoxDecoration(
  //                 color: theme.colorScheme.primary.withValues(alpha: 0.15),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: Center(
  //                 child: SvgPicture.asset(
  //                   SvgAppIcons.searchIcon,
  //                   colorFilter: ColorFilter.mode(
  //                       theme.colorScheme.primary, BlendMode.srcIn),
  //                   width: 20,
  //                   height: 20,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Container(
  //             width: 1,
  //             height: 24,
  //             color: theme.dividerColor.withValues(alpha: 0.2),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: TextField(
  //               onChanged: (val) {
  //                 setState(() {
  //                   _searchQuery =
  //                       val.trim().isEmpty ? null : val.toLowerCase();
  //                 });
  //               },
  //               decoration: InputDecoration(
  //                 hintText: 'Search logs...',
  //                 hintStyle: GoogleFonts.dmSans(
  //                   color: isDark ? Colors.white38 : Colors.black38,
  //                   fontSize: AppTypography.fontSizeSmall,
  //                 ),
  //                 border: InputBorder.none,
  //                 enabledBorder: InputBorder.none,
  //                 focusedBorder: InputBorder.none,
  //                 disabledBorder: InputBorder.none,
  //                 filled: true,
  //                 fillColor: Colors.transparent,
  //                 contentPadding: const EdgeInsets.symmetric(vertical: 12),
  //                 suffixIcon: _searchQuery != null
  //                     ? IconButton(
  //                         icon: const Icon(Icons.clear, size: 18),
  //                         onPressed: () {
  //                           setState(() {
  //                             _searchQuery = null;
  //                           });
  //                         },
  //                       )
  //                     : null,
  //               ),
  //               style: GoogleFonts.dmSans(
  //                 fontSize: AppTypography.fontSizeSmall,
  //                 color: theme.colorScheme.onSurface,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all saved detection logs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Hive.box<DetectionHistory>('detection_history').clear();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DetectionHistory entry;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _HistoryCard({
    required this.entry,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  String _getAppLabel(String? pkg) {
    if (pkg == null) return 'Unknown App';
    if (pkg.contains('com.google.android.apps.nbu.paisa.user')) return 'Google Pay';
    if (pkg.contains('com.phonepe.app')) return 'PhonePe';
    if (pkg.contains('net.one97.paytm')) return 'Paytm';
    if (pkg.contains('com.whatsapp')) return 'WhatsApp';
    if (pkg.contains('com.amazon.mShop')) return 'Amazon';
    if (pkg.contains('sms')) return 'SMS Message';
    return pkg.split('.').last.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Parse on the fly for rich info
    final parsed = TransactionParser.parse(entry.text, packageName: entry.packageName);
    final isDetected = entry.status == 'detected' || parsed != null;
    
    final amount = parsed?.amount ?? TransactionParser.parseAmount(entry.text);
    final isIncome = parsed?.isIncome ?? (entry.text.toLowerCase().contains('credit') || entry.text.toLowerCase().contains('received'));
    final merchant = parsed?.merchant ?? 'Unknown Source';

    return GestureDetector(
      onLongPress: onLongPress,
      child: ZoomTapAnimation(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : isDetected
                      ? (isIncome ? Colors.green : Colors.redAccent).withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: isSelectionMode
                  ? _buildSelectionIndicator(theme)
                  : _buildStatusIcon(theme, isDetected, isIncome, parsed?.confidence),
              title: Text(
                isDetected 
                  ? (amount != null && amount > 0 
                      ? '₹${amount.toStringAsFixed(0)} ${isIncome ? 'Received' : 'Paid'}' 
                      : 'Transaction Detected')
                  : (entry.reason ?? 'Notification Logged'),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: AppTypography.fontSizeRegular,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isDetected ? merchant : 'Pattern not matched',
                          style: GoogleFonts.dmSans(
                            fontSize: AppTypography.fontSizeXSmall,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('h:mm a').format(entry.timestamp),
                          style: GoogleFonts.dmSans(
                            fontSize: AppTypography.fontSizeXSmall,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getAppLabel(entry.packageName),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                _buildDetails(context, theme, parsed, isIncome),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(ThemeData theme) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 22) : null,
    );
  }

  Widget _buildStatusIcon(ThemeData theme, bool isDetected, bool isIncome, double? confidence) {
    final color = isDetected 
        ? (isIncome ? Colors.green : Colors.redAccent) 
        : Colors.orange;
        
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Center(
        child: isDetected && confidence != null
            ? Text(
                '${(confidence * 100).toInt()}%',
                style: GoogleFonts.bayon(fontSize: 14, color: color),
              )
            : Icon(
                isDetected ? (isIncome ? Icons.call_received : Icons.call_made) : Icons.query_builder_rounded,
                color: color,
                size: 18,
              ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme, ParsedTransaction? parsed, bool isIncome) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NOTIFICATION DATA',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: entry.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Message copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      width: 200,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 10, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'COPY',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.08)),
            ),
            child: SelectableText(
              entry.text.isNotEmpty ? entry.text : 'No message content available',
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeSmall,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ),
          if (entry.packageName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Source: ${entry.packageName}',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (entry.status != 'detected' && parsed == null)
            _buildManualAddButton(context, theme, isIncome)
          else
            _buildDetectedLabel(theme, isIncome),
        ],
      ),
    );
  }

  Widget _buildManualAddButton(BuildContext context, ThemeData theme, bool isIncome) {
    return ZoomTapAnimation(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddTransactionDialog(
            isIncome: isIncome,
            initialNote: entry.text,
            initialAmount: TransactionParser.parseAmount(entry.text),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add Manually',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: AppTypography.fontSizeSmall,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectedLabel(ThemeData theme, bool isIncome) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: (isIncome ? Colors.green : Colors.blue).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: (isIncome ? Colors.green : Colors.blue).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: isIncome ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 10),
          Text(
            isIncome ? 'Detected as Income' : 'Detected as Expense',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isIncome ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

