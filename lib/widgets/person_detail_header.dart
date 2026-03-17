import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_assets.dart';
import '../core/models/person.dart';
import '../core/view_models/person_view_model.dart';

class PersonDetailHeader extends StatelessWidget {
  final Person person;
  final double total;
  final int txsCount;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final PersonTransactionSortOption currentSortOption;
  final VoidCallback onShowSortOptions;

  const PersonDetailHeader({
    super.key,
    required this.person,
    required this.total,
    required this.txsCount,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.currentSortOption,
    required this.onShowSortOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = total >= 0;
    final formatted = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(total);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: Column(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: (isPositive
                                    ? AppColors.accentGreen
                                    : AppColors.accentRed)
                                .withValues(alpha: 0.2),
                            width: 1.4,
                          ),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusXLarge),
                          color: isPositive
                              ? AppColors.accentGreen.withValues(alpha: 0.1)
                              : AppColors.accentRed.withValues(alpha: 0.1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          child: Row(
                            children: [
                              _PersonaAvatar(
                                  person: person, isPositive: isPositive),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isPositive
                                          ? AppStrings.youGet
                                          : AppStrings.youGive,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    _BalanceAmount(
                                      isPositive: isPositive,
                                      integerPart: integerPart,
                                      decimalPart: decimalPart,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _DecorativeBottomLine(isPositive: isPositive),
                  ],
                ),
                _TransactionsSectionHeader(
                  txsCount: txsCount,
                  currentSortOption: currentSortOption,
                  onShowSortOptions: onShowSortOptions,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonaAvatar extends StatelessWidget {
  final Person person;
  final bool isPositive;

  const _PersonaAvatar({required this.person, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: person.photoPath != null
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusLarge),
                    child: person.photoPath!.startsWith('assets/')
                        ? Image.asset(person.photoPath!, fit: BoxFit.cover)
                        : Image.file(File(person.photoPath!),
                            fit: BoxFit.cover),
                  )
                : Icon(Icons.person_rounded,
                    color: theme.colorScheme.primary, size: 32),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isPositive ? AppColors.accentGreen : AppColors.accentRed,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: SvgPicture.asset(
                isPositive ? SvgAppIcons.incomeIcon : SvgAppIcons.expenseIcon,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceAmount extends StatelessWidget {
  final bool isPositive;
  final String integerPart;
  final String decimalPart;

  const _BalanceAmount({
    required this.isPositive,
    required this.integerPart,
    required this.decimalPart,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.accentGreen : AppColors.accentRed;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '₹ ',
            style: GoogleFonts.bebasNeue(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const TextSpan(text: " "),
          TextSpan(
            text: integerPart,
            style: GoogleFonts.bayon(
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
          TextSpan(
            text: '.$decimalPart',
            style: GoogleFonts.bayon(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeBottomLine extends StatelessWidget {
  final bool isPositive;

  const _DecorativeBottomLine({required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 60,
      right: 60,
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: isPositive ? AppColors.accentGreen : AppColors.accentRed,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.borderRadiusFull),
            bottomRight: Radius.circular(AppDimensions.borderRadiusFull),
          ),
        ),
      ),
    );
  }
}

class _TransactionsSectionHeader extends StatelessWidget {
  final int txsCount;
  final PersonTransactionSortOption currentSortOption;
  final VoidCallback onShowSortOptions;

  const _TransactionsSectionHeader({
    required this.txsCount,
    required this.currentSortOption,
    required this.onShowSortOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.dmSans(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              _TxsCountBadge(count: txsCount),
            ],
          ),
          _SortToggleButton(
              currentSortOption: currentSortOption, onTap: onShowSortOptions),
        ],
      ),
    );
  }
}

class _TxsCountBadge extends StatelessWidget {
  final int count;

  const _TxsCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 27,
      width: 27,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusRegular),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1.4,
        ),
      ),
      child: Center(
        child: Text(
          '$count',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _SortToggleButton extends StatelessWidget {
  final PersonTransactionSortOption currentSortOption;
  final VoidCallback onTap;

  const _SortToggleButton(
      {required this.currentSortOption, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 41,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusRegular),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getSortLabel(currentSortOption),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Icon(
              _getSortIcon(currentSortOption),
              size: 20,
              color: theme.colorScheme.primary,
            )
          ],
        ),
      ),
    );
  }

  String _getSortLabel(PersonTransactionSortOption option) {
    switch (option) {
      case PersonTransactionSortOption.dateNewest:
        return 'Recent';
      case PersonTransactionSortOption.dateOldest:
        return 'Oldest';
      case PersonTransactionSortOption.amountHighest:
        return 'Highest';
      case PersonTransactionSortOption.amountLowest:
        return 'Lowest';
    }
  }

  IconData _getSortIcon(PersonTransactionSortOption option) {
    switch (option) {
      case PersonTransactionSortOption.dateNewest:
        return Icons.keyboard_arrow_down;
      case PersonTransactionSortOption.dateOldest:
        return Icons.keyboard_arrow_up;
      case PersonTransactionSortOption.amountHighest:
        return Icons.expand_more;
      case PersonTransactionSortOption.amountLowest:
        return Icons.expand_less;
    }
  }
}
