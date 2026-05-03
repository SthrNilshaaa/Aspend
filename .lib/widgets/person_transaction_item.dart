import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/const/app_assets.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/models/person_transaction.dart';
import '../core/utils/blur_utils.dart';
import '../../widgets/add_transaction_dialog.dart';

class PersonTransactionItem extends StatelessWidget {
  final PersonTransaction tx;
  final Animation<double> animation;
  final VoidCallback onLongPress;

  const PersonTransactionItem({
    super.key,
    required this.tx,
    required this.animation,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositiveTx = tx.isIncome;

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onLongPress: onLongPress,
            child: ZoomTapAnimation(
              onTap: () {
                BlurUtils.showBlurredBottomSheet(
                  context: context,
                  child: AddTransactionDialog(
                    isIncome: tx.isIncome,
                    existingPersonTransaction: tx,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusXLarge),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.05),
                    width: 1.4,
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withValues(alpha: 0.03),
                  //     blurRadius: 10,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: Container(
                          width: 4,
                          height: 43,
                          decoration: BoxDecoration(
                            color: (isPositiveTx
                                    ? AppColors.accentGreen
                                    : AppColors.accentRed)
                                .withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(
                                  AppDimensions.borderRadiusXLarge),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: (isPositiveTx
                                          ? AppColors.accentGreen
                                          : AppColors.accentRed)
                                      .withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: (isPositiveTx
                                            ? AppColors.accentGreen
                                            : AppColors.accentRed)
                                        .withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadiusMedium),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    isPositiveTx
                                        ? SvgAppIcons.incomeIcon
                                        : SvgAppIcons.expenseIcon,
                                    colorFilter: ColorFilter.mode(
                                        isPositiveTx
                                            ? AppColors.accentGreen
                                            : AppColors.accentRed,
                                        BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tx.note.isEmpty
                                          ? 'No note provided'
                                          : tx.note,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM d, yyyy • hh:mm a')
                                          .format(tx.date),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${tx.amount.abs().toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isPositiveTx
                                      ? AppColors.accentGreen
                                      : AppColors.accentRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
