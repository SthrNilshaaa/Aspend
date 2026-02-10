import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../models/detection_history.dart';
import '../services/transaction_detection_service.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/empty_state_view.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../const/app_assets.dart';
import '../view_models/theme_view_model.dart';

class DetectionHistoryPage extends StatefulWidget {
  const DetectionHistoryPage({super.key});

  @override
  State<DetectionHistoryPage> createState() => _DetectionHistoryPageState();
}

class _DetectionHistoryPageState extends State<DetectionHistoryPage> {
  String? _searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            title: 'Detection History',
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await TransactionDetectionService
                      .recheckSkippedTransactions();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recheck complete')),
                    );
                  }
                },
                tooltip: 'Recheck skipped',
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearConfirmation(context),
                tooltip: 'Clear history',
              ),
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
              if (_searchQuery != null) {
                entries = entries.where((e) {
                  return e.text.toLowerCase().contains(_searchQuery!) ||
                      (e.reason != null &&
                          e.reason!.toLowerCase().contains(_searchQuery!)) ||
                      (e.packageName != null &&
                          e.packageName!.toLowerCase().contains(_searchQuery!));
                }).toList();
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
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(entry: entry),
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
          vertical: AppDimensions.paddingSmall),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusFull),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    SvgAppIcons.searchIcon,
                    colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary, BlendMode.srcIn),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery =
                        val.trim().isEmpty ? null : val.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search logs...',
                  hintStyle: GoogleFonts.dmSans(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: AppTypography.fontSizeSmall,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                  fontSize: AppTypography.fontSizeSmall,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDetected = entry.status == 'detected';
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: isDetected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.orange.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDetected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDetected ? Icons.check_rounded : Icons.priority_high_rounded,
              color: isDetected ? theme.colorScheme.primary : Colors.orange,
              size: 24,
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
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, hh:mm a').format(entry.timestamp),
                    style: GoogleFonts.dmSans(
                      fontSize: AppTypography.fontSizeXSmall,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                                entry.text.toLowerCase().contains('received'),
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
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded,
                                  color: theme.colorScheme.onPrimary, size: 20),
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
    );
  }
}
