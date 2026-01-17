import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../utils/transaction_utils.dart';
import '../utils/responsive_utils.dart';
import 'image_preview_widgets.dart';
import 'add_transaction_dialog.dart';

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

    return Padding(
      padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
          horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _showDetailsSheet(context, isDark),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: 48, tablet: 56, desktop: 64),
                width: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: 48, tablet: 56, desktop: 64),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: color,
                    size: ResponsiveUtils.getResponsiveIconSize(context,
                        mobile: 24, tablet: 28, desktop: 32)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transaction.note.isEmpty
                          ? widget.transaction.category
                          : widget.transaction.note,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 16, tablet: 18, desktop: 20),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.transaction.account,
                      style: GoogleFonts.nunito(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 12, tablet: 14, desktop: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${widget.transaction.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '₹').format(widget.transaction.amount)}",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                          mobile: 16, tablet: 18, desktop: 20),
                      color: widget.transaction.isIncome
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(widget.transaction.date),
                    style: GoogleFonts.nunito(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontSize: 11,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Transaction Details',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildDetailRow(
                  'Amount',
                  "${widget.transaction.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '₹').format(widget.transaction.amount)}",
                  widget.transaction.isIncome ? Colors.green : Colors.red,
                  center: true),
              const Divider(height: 32),
              _buildDetailRow('Category', widget.transaction.category,
                  Theme.of(context).colorScheme.primary),
              _buildDetailRow('Account', widget.transaction.account,
                  Theme.of(context).colorScheme.primary),
              _buildDetailRow(
                  'Date',
                  DateFormat('EEEE, d MMMM yyyy')
                      .format(widget.transaction.date),
                  Theme.of(context).colorScheme.onSurface),
              _buildDetailRow(
                  'Time',
                  DateFormat('hh:mm a').format(widget.transaction.date),
                  Theme.of(context).colorScheme.onSurface),
              if (widget.transaction.note.isNotEmpty)
                _buildDetailRow('Note', widget.transaction.note,
                    Theme.of(context).colorScheme.onSurface),
              if (widget.transaction.imagePaths != null &&
                  widget.transaction.imagePaths!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Attachments',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.transaction.imagePaths!.length,
                    itemBuilder: (context, index) =>
                        ImagePreviewWithInteraction(
                      imagePath: widget.transaction.imagePaths![index],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  Widget _buildDetailRow(String label, String value, Color textColor,
      {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              color: textColor,
              fontSize: center ? 32 : 18,
              fontWeight: FontWeight.bold,
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
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
