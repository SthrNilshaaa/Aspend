<<<<<<< HEAD
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
=======
import 'dart:io';
import 'package:aspends_tracker/core/const/app_assets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../core/models/transaction.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/utils/transaction_utils.dart';
import 'add_transaction_dialog.dart';
import '../core/utils/responsive_utils.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/utils/blur_utils.dart';
>>>>>>> master

class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  final int index;
<<<<<<< HEAD
=======
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggled;
  final VoidCallback? onLongPress;
>>>>>>> master

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.index,
<<<<<<< HEAD
=======
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggled,
    this.onLongPress,
>>>>>>> master
  });

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
<<<<<<< HEAD
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
=======
  static final _numberFormat = NumberFormat.currency(
    symbol: '',
    decimalDigits: 2,
  );
  static final _timeFormat = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode);
    final color =
        TransactionUtils.getCategoryColor(widget.transaction.category);
    final iconSvg =
        TransactionUtils.getCategorySvg(widget.transaction.category);
    final formatted = _numberFormat.format(widget.transaction.amount);

    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    return RepaintBoundary(
      child: Container(
        margin:
            const EdgeInsets.symmetric(vertical: AppDimensions.paddingXSmall),
        child: GestureDetector(
          onLongPress: widget.onLongPress,
          child: ZoomTapAnimation(
            onTap: widget.isSelectionMode
                ? widget.onSelectionToggled
                : () => _showDetailsSheet(context, isDark),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusLarge),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                      horizontal: AppDimensions.paddingStandard,
                      vertical: AppDimensions.paddingSmall +
                          AppDimensions.paddingXSmall),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.02)
                            : Colors.black.withValues(alpha: 0.01),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusLarge),
                    border: Border.all(
                      color: widget.isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : widget.transaction.source != null
                              ? Colors.blue.withValues(alpha: 0.1)
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                      width: widget.transaction.source != null ? 1.2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (widget.isSelectionMode) ...[
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: widget.isSelected
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: widget.isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                      ],
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
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusRegular),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(iconSvg,
                              colorFilter:
                                  ColorFilter.mode(color, BlendMode.srcIn),
                              width: ResponsiveUtils.getResponsiveIconSize(
                                  context,
                                  mobile:
                                      AppDimensions.categoryIconInsideMobile,
                                  tablet:
                                      AppDimensions.categoryIconInsideTablet,
                                  desktop:
                                      AppDimensions.categoryIconInsideDesktop)),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingStandard),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.transaction.note.isNotEmpty
                                  ? widget.transaction.note
                                  : widget.transaction.category,
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography
                                    .fontSizeMedium, // Stronger title presence
                                fontWeight: AppTypography
                                    .fontWeightBold, // Maximize contrast
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  widget.transaction.category.isNotEmpty
                                      ? widget.transaction.category
                                      : 'Uncategorized',
                                  style: GoogleFonts.dmSans(
                                    fontSize: AppTypography.fontSizeSmall,
                                    fontWeight: AppTypography.fontWeightMedium,
                                    color: theme.colorScheme.onSurface
                                        .withValues(
                                            alpha:
                                                0.5), // Elegant subtle subtitle
                                  ),
                                ),
                                if (widget.transaction.bankName != null &&
                                    widget.transaction.bankName!
                                        .isNotEmpty) ...[
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.transaction.bankName!,
                                      style: GoogleFonts.dmSans(
                                        fontSize: AppTypography.fontSizeXSmall,
                                        fontWeight:
                                            AppTypography.fontWeightMedium,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      // Amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                // Integer part (e.g. 55)
                                TextSpan(
                                  text:
                                      '${widget.transaction.isIncome ? '+' : '-'}₹$integerPart',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: AppTypography.fontWeightBlack,
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            mobile: AppTypography.fontSizeLarge,
                                            tablet:
                                                AppTypography.fontSizeXLarge,
                                            desktop: AppTypography
                                                .fontSizeXXLarge),
                                    color: widget.transaction.isIncome
                                        ? AppColors.accentGreen
                                        : AppColors.accentRed,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                // Decimal part (e.g. .00)
                                TextSpan(
                                  text: '.$decimalPart',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: AppTypography.fontWeightBold,
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            mobile: AppTypography.fontSizeSmall,
                                            tablet:
                                                AppTypography.fontSizeMedium,
                                            desktop:
                                                AppTypography.fontSizeLarge),
                                    color: widget.transaction.isIncome
                                        ? AppColors.accentGreen
                                            .withValues(alpha: 0.8)
                                        : AppColors.accentRed
                                            .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _timeFormat.format(widget.transaction.date),
                            style: GoogleFonts.dmSans(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.4),
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
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
            ),
          ),
        ),
>>>>>>> master
    );
  }

  void _showDetailsSheet(BuildContext context, bool isDark) {
<<<<<<< HEAD
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
                "Transaction Details",
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildDetailRow(
                  "Amount",
                  "${widget.transaction.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '₹').format(widget.transaction.amount)}",
                  widget.transaction.isIncome ? Colors.green : Colors.red,
                  center: true),
              const Divider(height: 32),
              _buildDetailRow("Category", widget.transaction.category,
                  Theme.of(context).colorScheme.primary),
              _buildDetailRow("Account", widget.transaction.account,
                  Theme.of(context).colorScheme.primary),
              _buildDetailRow(
                  "Date",
                  DateFormat('EEEE, d MMMM yyyy')
                      .format(widget.transaction.date),
                  Theme.of(context).colorScheme.onSurface),
              _buildDetailRow(
                  "Time",
                  DateFormat('hh:mm a').format(widget.transaction.date),
                  Theme.of(context).colorScheme.onSurface),
              if (widget.transaction.note.isNotEmpty)
                _buildDetailRow("Note", widget.transaction.note,
                    Theme.of(context).colorScheme.onSurface),
              if (widget.transaction.imagePaths != null &&
                  widget.transaction.imagePaths!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text("Attachments",
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
                      label: const Text("Delete",
                          style: const TextStyle(color: Colors.red)),
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
                      label: const Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
=======
    final theme = Theme.of(context);
    final color =
        TransactionUtils.getCategoryColor(widget.transaction.category);
    final iconSvg =
        TransactionUtils.getCategorySvg(widget.transaction.category);

    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: DraggableScrollableSheet(
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
                        padding: const EdgeInsets.all(AppDimensions
                            .paddingXXLarge), // More spacious padding
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
                              child: SvgPicture.asset(iconSvg,
                                  colorFilter:
                                      ColorFilter.mode(color, BlendMode.srcIn),
                                  width: AppDimensions.iconSizeHuge,
                                  height: AppDimensions.iconSizeHuge),
                            ),
                            const Spacer(),
                            Text(
                              "${widget.transaction.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '').format(widget.transaction.amount).trim()}",
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography
                                    .fontSizeGigantic, // Maximized hero size
                                fontWeight: AppTypography
                                    .fontWeightBlack, // Max weight for premium feel
                                color: widget.transaction.isIncome
                                    ? AppColors.accentGreen
                                    : AppColors.accentRed,
                                letterSpacing:
                                    -1.5, // tighter tracking for huge numbers
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
                            const SizedBox(
                                width: AppDimensions.paddingStandard),
                            Text(
                              'Notes',
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography.fontSizeMedium,
                                fontWeight: AppTypography.fontWeightBold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(
                                width: AppDimensions.paddingStandard),
                            Container(
                              height: 60,
                              width: 1,
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                            const SizedBox(
                                width: AppDimensions.paddingStandard),
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
                              final path =
                                  widget.transaction.imagePaths![index];
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
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.1),
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
                                color:
                                    theme.dividerColor.withValues(alpha: 0.1)),
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
                                color:
                                    AppColors.accentRed.withValues(alpha: 0.2),
                              ),
                            ),
                            child: SvgPicture.asset(
                              SvgAppIcons.deleteIcon,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.accentRed, BlendMode.srcIn),
                            )),
                      ),
                      const SizedBox(width: AppDimensions.paddingStandard),
                      Expanded(
                        child: ZoomTapAnimation(
                          onTap: () {
                            Navigator.pop(context);
                            BlurUtils.showBlurredBottomSheet(
                              context: context,
                              child: AddTransactionDialog(
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
                                      theme.colorScheme.primary,
                                      BlendMode.srcIn),
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(
                                    width: AppDimensions.paddingSmall),
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
>>>>>>> master
              ),
            ],
          ),
        ),
<<<<<<< HEAD
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
=======
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
>>>>>>> master
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
<<<<<<< HEAD
        title: const Text("Delete Transaction?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
=======
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
>>>>>>> master
          ),
          TextButton(
            onPressed: () {
              context
                  .read<TransactionViewModel>()
                  .deleteTransaction(widget.transaction);
              Navigator.pop(context);
            },
<<<<<<< HEAD
            child:
                const Text("Delete", style: const TextStyle(color: Colors.red)),
=======
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
>>>>>>> master
          ),
        ],
      ),
    );
  }
}
