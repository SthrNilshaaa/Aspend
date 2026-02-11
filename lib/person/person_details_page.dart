import 'dart:ui';

import 'package:aspends_tracker/const/app_colors.dart';
import 'package:aspends_tracker/const/app_dimensions.dart';
import 'package:aspends_tracker/const/app_strings.dart';
import 'package:aspends_tracker/widgets/floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../const/app_assets.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../view_models/person_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../widgets/header_delegate.dart';
import '../widgets/modern_card.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/glass_action_button.dart';

class PersonDetailPage extends StatefulWidget {
  final Person person;

  const PersonDetailPage({super.key, required this.person});

  @override
  State<PersonDetailPage> createState() => _PersonDetailPageState();
}

class _PersonDetailPageState extends State<PersonDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final atTop = _scrollController.position.pixels <= 0;
      final txs =
          context.read<PersonViewModel>().transactionsFor(widget.person.name);
      final isEmpty = txs.isEmpty;
      final shouldShowFab = atTop || isEmpty;

      // Only update state if there's an actual change
      if (shouldShowFab != _showFab) {
        setState(() => _showFab = shouldShowFab);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PersonViewModel>();
    final person = viewModel.people.firstWhere(
      (p) => p.key == widget.person.key,
      orElse: () => widget.person,
    );
    final txs = viewModel.transactionsFor(person.name);
    final total = viewModel.getTotalForPerson(person.name);
    final isPositive = total >= 0;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionBar(
            onSettle: () {
              _settleBalance(context, total, person);
            },
            onMinus: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddTransactionDialog(
                  isIncome: false,
                  initialNote: widget.person.name,
                ),
              );
            },
            onPlus: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddTransactionDialog(
                  isIncome: true,
                  initialNote: widget.person.name,
                ),
              );
            },
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            title: person.name,
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
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
                      child: SvgPicture.asset(
                        SvgAppIcons.backButtonIcon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  //navigate to notification page
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showEditPersonDialog(context, person);
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surface.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SvgPicture.asset(
                            SvgAppIcons.editIcon,
                            colorFilter: ColorFilter.mode(
                                isPositive
                                    ? AppColors.accentGreen
                                    : AppColors.accentRed,
                                BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeHeaderDelegate(
              // minHeight: 150,
              // maxHeight: 150,
              height: 220,
              child: GestureDetector(
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    _showDeleteConfirmation(context, person);
                  },
                  child: _buildPinnedHeader(context)),
            ),
          ),
          if (txs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                description: 'Add your first transaction with ${person.name}',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (c, i) {
                    final tx = txs[i];
                    final sign = tx.isIncome ? '+' : '-';
                    final isPositiveTx = tx.isIncome;

                    return AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - _fadeController.value)),
                          child: Opacity(
                            opacity: _fadeController.value,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onLongPress: () {
                                  HapticFeedback.lightImpact();
                                  _showDeleteTransactionDialog(context, tx);
                                },
                                child: ZoomTapAnimation(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          AddTransactionDialog(
                                        isIncome: tx.isIncome,
                                        existingPersonTransaction: tx,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.borderRadiusXLarge),
                                      border: Border.all(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.05),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 1),
                                            child: Container(
                                              width: 4,
                                              height:
                                                  43, // Adjust the height as needed
                                              decoration: BoxDecoration(
                                                color: isPositiveTx
                                                    ? AppColors.accentGreen
                                                        .withValues(alpha: 0.2)
                                                    : AppColors.accentRed
                                                        .withValues(alpha: 0.2),
                                                borderRadius: const BorderRadius
                                                    .horizontal(
                                                  left: Radius.circular(
                                                      AppDimensions
                                                          .borderRadiusXLarge),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                              vertical: 16),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      color: (isPositiveTx
                                                              ? AppColors
                                                                  .accentGreen
                                                              : AppColors
                                                                  .accentRed)
                                                          .withValues(
                                                              alpha: 0.1),
                                                      border: Border.all(
                                                        color: isPositiveTx
                                                            ? AppColors
                                                                .accentGreen
                                                                .withValues(
                                                                    alpha: 0.1)
                                                            : AppColors
                                                                .accentRed
                                                                .withValues(
                                                                    alpha: 0.1),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius
                                                          .circular(AppDimensions
                                                              .borderRadiusMedium),
                                                    ),
                                                    child: Icon(
                                                      isPositiveTx
                                                          ? Icons
                                                              .add_circle_rounded
                                                          : Icons.remove_circle,
                                                      color: isPositiveTx
                                                          ? AppColors
                                                              .accentGreen
                                                          : AppColors.accentRed,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          tx.note.isEmpty
                                                              ? 'No note provided'
                                                              : tx.note,
                                                          style: GoogleFonts
                                                              .dmSans(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurface,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          DateFormat(
                                                                  'MMM d, yyyy • hh:mm a')
                                                              .format(tx.date),
                                                          style: GoogleFonts
                                                              .dmSans(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.4),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '$sign₹${tx.amount.abs().toStringAsFixed(0)}',
                                                        style:
                                                            GoogleFonts.dmSans(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: isPositiveTx
                                                              ? AppColors
                                                                  .accentGreen
                                                              : AppColors
                                                                  .accentRed,
                                                        ),
                                                      ),
                                                      // const SizedBox(height: 2),
                                                      // Text(
                                                      //   isPositiveTx
                                                      //       ? 'Credit'
                                                      //       : 'Debit',
                                                      //   style:
                                                      //       GoogleFonts.dmSans(
                                                      //     fontSize: 10,
                                                      //     fontWeight:
                                                      //         FontWeight.w800,
                                                      //     color: (isPositiveTx
                                                      //             ? AppColors
                                                      //                 .accentGreen
                                                      //             : AppColors
                                                      //                 .accentRed)
                                                      //         .withValues(
                                                      //             alpha: 0.5),
                                                      //     letterSpacing: 0.5,
                                                      //   ),
                                                      // ),
                                                    ],
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
                      },
                    );
                  },
                  childCount: txs.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPinnedHeader(BuildContext context) {
    final theme = Theme.of(context);
    final person = context.read<PersonViewModel>().people.firstWhere(
          (p) => p.key == widget.person.key,
          orElse: () => widget.person,
        );
    final txs = context.read<PersonViewModel>().transactionsFor(person.name);
    final total =
        context.read<PersonViewModel>().getTotalForPerson(person.name);
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.1),
                            width: 1.4,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusXLarge),
                          color: isPositive
                              ? AppColors.accentGreen.withValues(alpha: 0.1)
                              : AppColors.accentRed.withValues(alpha: 0.1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 65,
                                    height: 65,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.borderRadiusLarge),
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: person.photoPath != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppDimensions
                                                          .borderRadiusLarge),
                                              child: person.photoPath!
                                                      .startsWith('assets/')
                                                  ? Image.asset(
                                                      person.photoPath!,
                                                      fit: BoxFit.cover)
                                                  : Image.file(
                                                      File(person.photoPath!),
                                                      fit: BoxFit.cover,
                                                    ),
                                            )
                                          : Icon(
                                              Icons.person_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 32,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isPositive
                                            ? AppColors.accentGreen
                                            : AppColors.accentRed,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: theme.colorScheme.surface,
                                            width: 1.5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: SvgPicture.asset(
                                            isPositive
                                                ? SvgAppIcons.incomeIcon
                                                : SvgAppIcons.expenseIcon,
                                            colorFilter: ColorFilter.mode(
                                                Colors.white, BlendMode.srcIn)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                
                                    Text(
                                      isPositive
                                          ? AppStrings.youWillGet
                                          : AppStrings.youWillGive,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '₹ ',
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w900,
                                              color: isPositive
                                                  ? AppColors.accentGreen
                                                  : AppColors.accentRed,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                          const TextSpan(text: " "),
                                          TextSpan(
                                            text: integerPart,
                                            style: GoogleFonts.bayon(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: isPositive
                                                  ? AppColors.accentGreen
                                                  : AppColors.accentRed,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '.$decimalPart',
                                            style: GoogleFonts.bayon(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w900,
                                              color: isPositive
                                                  ? AppColors.accentGreen
                                                  : AppColors.accentRed,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Positioned(
                                    //   left: 0,
                                    //   top: 0,
                                    //   child: Text(
                                    //     isPositive
                                    //         ? AppStrings.youWillGet
                                    //         : AppStrings.youWillGive,
                                    //     style: GoogleFonts.dmSans(
                                    //       fontSize: 15,
                                    //       fontWeight: FontWeight.w600,
                                    //       color: theme.colorScheme.onSurface,
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 60,
                      right: 60,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.accentGreen
                              : AppColors.accentRed,
                          // rounded corners only on the top
                          borderRadius: const BorderRadius.only(
                            bottomLeft:
                                Radius.circular(AppDimensions.borderRadiusFull),
                            bottomRight:
                                Radius.circular(AppDimensions.borderRadiusFull),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                          Container(
                            height: 27,
                            width: 27,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusRegular),
                              border: Border.all(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.1),
                                width: 1.4,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${txs.length}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 110,
                        height: 41,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusRegular),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                            width: 1.4,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Recent',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _settleBalance(
      BuildContext context, double currentTotal, Person currentPerson) {
    if (currentTotal == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Settle Balance',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text(
          'This will add a transaction of ₹${currentTotal.abs().toStringAsFixed(2)} to bring the balance to zero. Continue?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddTransactionDialog(
                  isIncome: currentTotal < 0,
                  initialAmount: currentTotal.abs(),
                  initialNote: '${currentPerson.name} - Settled balance',
                ),
              );
              HapticFeedback.mediumImpact();
            },
            child: Text('Settle', style: GoogleFonts.dmSans()),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Person currentPerson) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Person',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${currentPerson.name}? This action cannot be undone.',
          style: GoogleFonts.dmSans(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style:
                  GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PersonViewModel>().deletePerson(currentPerson);
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Delete',
              style:
                  GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteTransactionDialog(
      BuildContext context, PersonTransaction tx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Transaction',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: GoogleFonts.dmSans(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style:
                  GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PersonViewModel>().deleteTransaction(tx);
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Delete',
              style:
                  GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPersonDialog(BuildContext context, Person person) {
    final controller = TextEditingController(text: person.name);
    final theme = Theme.of(context);
    String? selectedPhotoPath = person.photoPath;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Person',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo Selection
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image != null) {
                    setStateDialog(() {
                      selectedPhotoPath = image.path;
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: selectedPhotoPath != null
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: selectedPhotoPath != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: selectedPhotoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: (selectedPhotoPath!.startsWith('assets/') ||
                                  selectedPhotoPath!.startsWith('http'))
                              ? Image.asset(selectedPhotoPath!,
                                  width: 96, height: 96, fit: BoxFit.cover)
                              : Image.file(
                                  File(selectedPhotoPath!),
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 30,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Update the details for this person',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Person Name',
                  labelStyle: GoogleFonts.dmSans(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.person_outline,
                      color: theme.colorScheme.primary),
                ),
                style: GoogleFonts.dmSans(fontSize: 16),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  HapticFeedback.lightImpact();
                  final updatedPerson = Person(
                    name: name,
                    photoPath: selectedPhotoPath,
                  );
                  context
                      .read<PersonViewModel>()
                      .updatePerson(person, updatedPerson);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Update',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
