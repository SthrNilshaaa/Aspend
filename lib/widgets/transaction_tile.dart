import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../models/transaction.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../utils/transaction_utils.dart';
import 'add_transaction_dialog.dart';
import '../utils/responsive_utils.dart';

class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  final int index;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.index,
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final color =
        TransactionUtils.getCategoryColor(widget.transaction.category);
    final icon = TransactionUtils.getCategoryIcon(widget.transaction.category);

    return Container(
      margin: ResponsiveUtils.getResponsiveEdgeInsets(context,
          horizontal: 16, vertical: 8),
      child: ZoomTapAnimation(
        onTap: () => _showDetailsSheet(context, isDark),
        child: Container(
          padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: 48, tablet: 52, desktop: 56),
                width: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: 48, tablet: 52, desktop: 56),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon,
                    color: color,
                    size: ResponsiveUtils.getResponsiveIconSize(context,
                        mobile: 22, tablet: 24, desktop: 26)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transaction.note.isEmpty
                          ? widget.transaction.category
                          : widget.transaction.note,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 15, tablet: 16, desktop: 17),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.transaction.account,
                          style: GoogleFonts.nunito(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 11,
                                tablet: 12,
                                desktop: 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.transaction.source != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.auto_awesome,
                              size: 10,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.5)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${widget.transaction.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(widget.transaction.amount)}",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w900,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                          mobile: 16, tablet: 18, desktop: 20),
                      color: widget.transaction.isIncome
                          ? Colors.greenAccent.shade700
                          : Colors.redAccent,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(widget.transaction.date),
                    style: GoogleFonts.nunito(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.4),
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                          mobile: 9, tablet: 10, desktop: 11),
                      fontWeight: FontWeight.bold,
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

  void _showDetailsSheet(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final color =
        TransactionUtils.getCategoryColor(widget.transaction.category);
    final icon = TransactionUtils.getCategoryIcon(widget.transaction.category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Header Amount Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.15),
                            color.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "${widget.transaction.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '₹').format(widget.transaction.amount)}",
                            style: GoogleFonts.nunito(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: widget.transaction.isIncome
                                  ? Colors.greenAccent.shade700
                                  : Colors.redAccent,
                            ),
                          ),
                          Text(
                            widget.transaction.category,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Transaction Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoColumn(
                            'Account',
                            widget.transaction.account,
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            'Date',
                            DateFormat('dd MMM, yyyy')
                                .format(widget.transaction.date),
                            Icons.calendar_today_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoColumn(
                            'Time',
                            DateFormat('hh:mm a')
                                .format(widget.transaction.date),
                            Icons.access_time,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            'Status',
                            'Completed',
                            Icons.check_circle_outline,
                            valueColor: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 48),

                    // Additional Details
                    if (widget.transaction.note.isNotEmpty)
                      _buildModernDetailRow('Note', widget.transaction.note),

                    if (widget.transaction.bankName != null)
                      _buildModernDetailRow(
                          'Service', widget.transaction.bankName!),

                    if (widget.transaction.reference != null)
                      _buildModernDetailRow(
                          'Ref ID', widget.transaction.reference!),

                    if (widget.transaction.balanceAfter != null)
                      _buildModernDetailRow(
                        'Total Balance',
                        NumberFormat.currency(symbol: '₹')
                            .format(widget.transaction.balanceAfter),
                      ),

                    if (widget.transaction.source != null)
                      _buildModernDetailRow(
                          'Detected via', widget.transaction.source!,
                          isAuto: true),

                    if (widget.transaction.imagePaths != null &&
                        widget.transaction.imagePaths!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Attachments',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.transaction.imagePaths!.length,
                          itemBuilder: (context, index) {
                            final path = widget.transaction.imagePaths![index];
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: FileImage(File(path)),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                  color:
                                      theme.dividerColor.withValues(alpha: 0.1),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    if (widget.transaction.originalText != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Original Log',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          widget.transaction.originalText!,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            height: 1.5,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.redAccent.withValues(alpha: 0.1),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(context);
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 8,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => AddTransactionDialog(
                              isIncome: widget.transaction.isIncome,
                              existingTransaction: widget.transaction,
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Edit Transaction'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon,
      {Color? valueColor}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? theme.textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernDetailRow(String label, String value,
      {bool isAuto = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isAuto) ...[
                  const Icon(Icons.auto_awesome, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<TransactionViewModel>()
                  .deleteTransaction(widget.transaction);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
