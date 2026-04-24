import 'package:flutter/material.dart';
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
        SnackBar(content: Text('Deleted ${indices.length} logs')),
      );
    }
  }

  Future<void> _bulkIgnore(List<int> indices) async {
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
          SnackBar(content: Text('Permanently ignored $count patterns')),
        );
      }
    } else {
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomGlassAppBar(
            title: _isSelectionMode
                ? '${_selectedIndices.length} Selected'
                : 'Detection History',
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
                          const SnackBar(content: Text('Recheck complete')),
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
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.history_toggle_off,
                    title: 'No detection history yet',
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
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.search_off,
                    title: 'No results found',
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
                        hintText: "Search Logs...",
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDetected = entry.status == 'detected';
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: onLongPress,
      child: ZoomTapAnimation(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : isDetected
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: isSelectionMode
                  ? Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 24)
                          : null,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDetected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isDetected
                                  ? theme.colorScheme.primary
                                  : Colors.orange)
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: entry.confidence != null
                            ? Text(
                                '${(entry.confidence! * 100).toInt()}%',
                                style: GoogleFonts.bayon(
                                  fontSize: 16,
                                  color: isDetected
                                      ? theme.colorScheme.primary
                                      : Colors.orange,
                                ),
                              )
                            : Icon(
                                isDetected
                                    ? Icons.check_rounded
                                    : Icons.priority_high_rounded,
                                color: isDetected
                                    ? theme.colorScheme.primary
                                    : Colors.orange,
                                size: 20,
                              ),
                      ),
                    ),
              title: Text(
                isDetected
                    ? 'Successfully Detected'
                    : (entry.reason ?? 'Skipped Entry'),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: AppTypography.fontSizeSmall,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, hh:mm a').format(entry.timestamp),
                        style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeXSmall,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.05),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'RAW MESSAGE',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Text(
                          entry.text,
                          style: GoogleFonts.dmSans(
                            fontSize: AppTypography.fontSizeSmall,
                            height: 1.5,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      if (entry.packageName != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.apps_rounded,
                                size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              entry.packageName!,
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography.fontSizeXSmall,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!isDetected) ...[
                        const SizedBox(height: 16),
                        ZoomTapAnimation(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => AddTransactionDialog(
                                isIncome: entry.text
                                        .toLowerCase()
                                        .contains('credit') ||
                                    entry.text
                                        .toLowerCase()
                                        .contains('received'),
                                initialNote: entry.text,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusMedium),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded,
                                      color: theme.colorScheme.onPrimary,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add Manually',
                                    style: GoogleFonts.dmSans(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppTypography.fontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
