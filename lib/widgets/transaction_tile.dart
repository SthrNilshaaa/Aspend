import 'dart:io';
import 'package:aspends_tracker/const/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import '../const/app_colors.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';

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
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXSmall),
      child: ZoomTapAnimation(
        onTap: () => _showDetailsSheet(context, isDark),
        child: Container(
          padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
              horizontal: AppDimensions.paddingStandard,
              vertical:
                  AppDimensions.paddingSmall + AppDimensions.paddingXSmall),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
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
                    mobile: AppDimensions.categoryIconSizeMobile,
                    tablet: AppDimensions.categoryIconSizeTablet,
                    desktop: AppDimensions.categoryIconSizeDesktop),
                width: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: AppDimensions.categoryIconSizeMobile,
                    tablet: AppDimensions.categoryIconSizeTablet,
                    desktop: AppDimensions.categoryIconSizeDesktop),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusRegular),
                ),
                child: Icon(icon,
                    color: color,
                    size: ResponsiveUtils.getResponsiveIconSize(context,
                        mobile: AppDimensions.categoryIconInsideMobile,
                        tablet: AppDimensions.categoryIconInsideTablet,
                        desktop: AppDimensions.categoryIconInsideDesktop)),
              ),
              const SizedBox(width: AppDimensions.paddingStandard),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transaction.note.isEmpty
                          ? widget.transaction.category
                          : widget.transaction.note,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w800,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: AppTypography.fontSizeSmall + 1,
                            tablet: AppTypography.fontSizeMedium,
                            desktop: AppTypography.fontSizeMedium + 1),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.paddingXSmall),
                    Row(
                      children: [
                        Text(
                          widget.transaction.account,
                          style: GoogleFonts.dmSans(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.6),
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: AppTypography.fontSizeXSmall - 1,
                                tablet: AppTypography.fontSizeXSmall,
                                desktop: AppTypography.fontSizeSmall - 1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.transaction.source != null) ...[
                          const SizedBox(width: AppDimensions.paddingSmall),
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
                    style: GoogleFonts.dmSans(
                      fontWeight: AppTypography.fontWeightBlack,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                          mobile: AppTypography.fontSizeMedium,
                          tablet: AppTypography.fontSizeRegular,
                          desktop: AppTypography.fontSizeLarge),
                      color: widget.transaction.isIncome
                          ? AppColors.accentGreen
                          : AppColors.accentRed,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(widget.transaction.date),
                    style: GoogleFonts.dmSans(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.4),
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                          mobile: AppTypography.fontSizeXSmall - 3,
                          tablet: AppTypography.fontSizeXSmall - 2,
                          desktop: AppTypography.fontSizeXSmall - 1),
                      fontWeight: AppTypography.fontWeightBold,
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
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.borderRadiusXLarge)),
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
              const SizedBox(height: AppDimensions.spacingMedium),
              Container(
                width: AppDimensions.avatarSizeStandard,
                height: AppDimensions.spacingXSmall,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.spacingTiny),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingStandard),
                  children: [
                    // Handle height correction
                    const SizedBox(height: AppDimensions.paddingStandard),

                    // Header Amount Card (Dark Modern Design)
                    Container(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingXLarge),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.1 : 0.05),
                        borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusXLarge + 8),
                        border: Border.all(
                          color: color.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                AppDimensions.paddingStandard),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon,
                                color: color, size: AppDimensions.iconSizeHuge),
                          ),
                          const Spacer(),
                          Text(
                            "${widget.transaction.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '').format(widget.transaction.amount).trim()}",
                            style: GoogleFonts.dmSans(
                              fontSize: AppTypography.fontSizeGigantic - 4,
                              fontWeight: AppTypography.fontWeightBlack,
                              color: widget.transaction.isIncome
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXLarge),

                    // Transaction Info Grid (2x2)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoColumn(
                            'Account',
                            widget.transaction.account,
                            SvgAppIcons.walletIcon,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            'Date',
                            DateFormat('dd MMM, yyyy')
                                .format(widget.transaction.date),
                            Icons.calendar_today_outlined,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoColumn(
                            'Time',
                            DateFormat('hh:mm a')
                                .format(widget.transaction.date),
                            Icons.access_time_outlined,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            'Status',
                            'Completed',
                            Icons.check_circle_outline_rounded,
                            isDark,
                            valueColor: AppColors.accentGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.paddingStandard),
                    const Divider(
                        height: AppDimensions.paddingXXLarge,
                        color: Colors.transparent),

                    // Notes Section
                    if (widget.transaction.note.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                AppDimensions.paddingSmall + 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              SvgAppIcons.noteIcon,
                              colorFilter: ColorFilter.mode(
                                  theme.colorScheme.primary, BlendMode.srcIn),
                              width: 20,
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingStandard),
                          Text(
                            'Notes',
                            style: GoogleFonts.dmSans(
                              fontSize: AppTypography.fontSizeMedium,
                              fontWeight: AppTypography.fontWeightBold,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingStandard),
                          Container(
                            height: 60,
                            width: 1,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: AppDimensions.paddingStandard),
                          Expanded(
                            child: Text(
                              widget.transaction.note,
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography.fontSizeSmall + 1,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.7),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                    ],

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
                      const SizedBox(height: AppDimensions.paddingLarge),
                      Text(
                        'Attachments',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMedium),
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
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusMedium),
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
                      const SizedBox(height: AppDimensions.paddingLarge),
                      Text(
                        'Original Log',
                        style: GoogleFonts.dmSans(
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
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium),
                          border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          widget.transaction.originalText!,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            height: 1.5,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingXLarge),
                  ],
                ),
              ),

              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    ZoomTapAnimation(
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context);
                      },
                      child: Container(
                          padding: const EdgeInsets.all(
                              AppDimensions.paddingStandard),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentRed.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.accentRed.withValues(alpha: 0.2),
                            ),
                          ),
                          child: SvgPicture.asset(
                            SvgAppIcons.deleteIcon,
                            color: AppColors.accentRed,
                          )),
                    ),
                    const SizedBox(width: AppDimensions.paddingStandard),
                    Expanded(
                      child: ZoomTapAnimation(
                        onTap: () {
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusFull),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.5),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.2),
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                SvgAppIcons.editIcon,
                                colorFilter: ColorFilter.mode(
                                    theme.colorScheme.primary, BlendMode.srcIn),
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: AppDimensions.paddingSmall),
                              Text(
                                'Edit Transaction',
                                style: GoogleFonts.dmSans(
                                  fontWeight: AppTypography.fontWeightBold,
                                  color: theme.colorScheme.primary,
                                  fontSize: AppTypography.fontSizeMedium,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildInfoColumn(String label, String value, dynamic icon, bool isDark,
      {Color? valueColor}) {
    final theme = Theme.of(context);

    Widget iconWidget;
    if (icon is String) {
      iconWidget = SvgPicture.asset(
        icon,
        colorFilter:
            ColorFilter.mode(theme.colorScheme.primary, BlendMode.srcIn),
        width: 20,
        height: 20,
      );
    } else if (icon is IconData) {
      iconWidget = Icon(icon, color: theme.colorScheme.primary, size: 20);
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall + 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: iconWidget,
        ),
        const SizedBox(width: AppDimensions.paddingSmall + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeXSmall,
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeSmall + 1,
                  fontWeight: AppTypography.fontWeightBold,
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
            style: GoogleFonts.dmSans(
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
                    style: GoogleFonts.dmSans(
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
