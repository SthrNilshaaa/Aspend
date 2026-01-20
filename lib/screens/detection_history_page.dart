import 'dart:ui';
import 'package:aspends_tracker/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/detection_history.dart';
import '../services/transaction_detection_service.dart';
import '../widgets/add_transaction_dialog.dart';

class DetectionHistoryPage extends StatelessWidget {
  const DetectionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Bottom layer: Blur
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.transparent),
              ),
              // Middle layer: Gradient tint
              Container(
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
              // Top layer: Subtle border
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Detection History',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await TransactionDetectionService.recheckSkippedTransactions();
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
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<DetectionHistory>('detection_history').listenable(),
        builder: (context, Box<DetectionHistory> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No detection history yet',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final entries = box.values.toList().reversed.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _HistoryCard(entry: entry);
            },
          );
        },
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

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDetected
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDetected ? Colors.green : Colors.orange)
                .withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDetected ? Icons.check_circle_outline : Icons.help_outline,
            color: isDetected ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          isDetected ? 'Successfully Detected' : 'Skipped / Unrecognized',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          DateFormat('MMM d, hh:mm a').format(entry.timestamp),
          style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Message Content:',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.text,
                    style: GoogleFonts.nunito(
                        fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
                if (entry.reason != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Reason: ${entry.reason}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (entry.packageName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'App: ${entry.packageName}',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isDetected)
                      TextButton.icon(
                        onPressed: () {
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
                        icon: const Icon(Icons.add_task, size: 18),
                        label: Text('Add Manually',
                            style: GoogleFonts.nunito(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
