import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/const/app_dimensions.dart';
import '../../core/const/app_typography.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/transaction_utils.dart';
import '../../core/models/transaction.dart';
import '../../widgets/transaction_tile.dart';

class HomeTransactionList extends StatelessWidget {
  final Map<DateTime, List<Transaction>> grouped;

  const HomeTransactionList({
    super.key,
    required this.grouped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Flatten the grouped transactions into a list of items for SliverList
    final items = <dynamic>[];
    for (final entry in grouped.entries) {
      items.add(entry.key); // Add the date as a header
      
      // Add transactions with their index
      for (int i = 0; i < entry.value.length; i++) {
        items.add({'transaction': entry.value[i], 'index': i});
      }
    }

    return SliverPadding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingStandard),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          
          if (item is DateTime) {
            final dateKey = item;
            final dateStr =
                "${dateKey.year}-${dateKey.month.toString().padLeft(2, '0')}-${dateKey.day.toString().padLeft(2, '0')}";
            final relativeDate = TransactionUtils.formatRelativeDate(dateStr);
            
            return Padding(
              padding: const EdgeInsets.only(
                  left: AppDimensions.paddingXSmall,
                  bottom: AppDimensions.paddingXSmall,
                  top: AppDimensions.paddingXSmall),
              child: Text(
                relativeDate,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary.withValues(alpha: 0.8),
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: AppTypography.fontSizeSmall,
                      tablet: AppTypography.fontSizeMedium,
                      desktop: AppTypography.fontSizeSmall + 4),
                  letterSpacing: 0.5,
                ),
              ),
            );
          } else {
            // It's a transaction
            final map = item as Map<String, dynamic>;
            final transaction = map['transaction'] as Transaction;
            final itemIndex = map['index'] as int;
            
            // Add padding after the last item of a group or if we need bottom spacing
            final isLastInGroup = index < items.length - 1 && items[index + 1] is DateTime;
            final isVeryLast = index == items.length - 1;
            
            Widget tile = TransactionTile(
              transaction: transaction,
              index: itemIndex,
            );
            
            if (isLastInGroup || isVeryLast) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingXLarge),
                child: tile,
              );
            }
            
            return tile;
          }
        },
      ),
    );
  }
}
