import 'dart:ui';
<<<<<<< HEAD

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'dart:io';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../view_models/person_view_model.dart';
import '../view_models/theme_view_model.dart';
//import 'dart:async';
import 'package:flutter/rendering.dart';
=======
import 'package:aspends_tracker/core/const/app_colors.dart';
import 'package:aspends_tracker/core/const/app_dimensions.dart';
import 'package:aspends_tracker/widgets/floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../core/const/app_assets.dart';
import '../core/models/person.dart';
import '../core/models/person_transaction.dart';
import '../core/view_models/person_view_model.dart';
import '../../widgets/header_delegate.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/person_transaction_item.dart';
import '../../widgets/person_detail_header.dart';
import '../core/const/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';
>>>>>>> master

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
<<<<<<< HEAD
=======
  PersonTransactionSortOption _sortOption =
      PersonTransactionSortOption.dateNewest;
>>>>>>> master

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
<<<<<<< HEAD
      if (!_scrollController.hasClients) return;
=======
      if (!_scrollController.hasClients || !mounted) return;
>>>>>>> master
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

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PersonViewModel>();
    final txs = viewModel.transactionsFor(widget.person.name);
    final total = viewModel.getTotalForPerson(widget.person.name);
    final isPositive = total >= 0;
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final useAdaptive = themeViewModel.useAdaptiveColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: useAdaptive
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primaryContainer
                          ],
                        )
                      : isDark
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.8),
                                theme.colorScheme.primaryContainer
                                    .withOpacity(0.8)
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              //colors: [Colors.teal.shade100.withOpacity(0.8), Colors.teal.shade200.withOpacity(0.8)],
                              colors: [
                                theme.colorScheme.primary.withOpacity(0.8),
                                theme.colorScheme.primaryContainer
                                    .withOpacity(0.8)
                              ],
                            ),
                ),
              ),
            ),
          ),
          title: Text(
            widget.person.name,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
=======
  Future<void> _payNow(double total, Person person) async {
    if (person.upiId == null || person.upiId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('UPI ID not set for this person. please add it from edit.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final amount = total.abs();
    final uri = Uri.parse(
        'upi://pay?pa=${person.upiId}&pn=${Uri.encodeComponent(person.name)}&am=${amount.toStringAsFixed(2)}&cu=INR');

    if (await canLaunchUrl(uri)) {
      HapticFeedback.mediumImpact();
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find a UPI payment app'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<PersonViewModel>();
    // Optimized rebuilds with select
    final person =
        context.select<PersonViewModel, Person>((vm) => vm.people.firstWhere(
              (p) => p.key == widget.person.key,
              orElse: () => widget.person,
            ));
    final groupedTxs =
        viewModel.getGroupedTransactionsFor(person.name, _sortOption);
    final total = context.select<PersonViewModel, double>(
        (vm) => vm.getTotalForPerson(person.name));
    final txsCount =
        groupedTxs.values.fold(0, (prev, element) => prev + element.length);

    final isPositive = total >= 0;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
>>>>>>> master
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
<<<<<<< HEAD
          child: FloatingActionButton.extended(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: const Icon(Icons.add, size: 24),
            label: Text(
              'Add Transaction',
              style:
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              _showAddTxDialog(context);
              HapticFeedback.lightImpact();
=======
          child: FloatingActionBar(
            onSettle: () {
              _settleBalance(context, total, person);
            },
            onMinus: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withValues(alpha: 0.3),
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AddTransactionDialog(
                    isIncome: false,
                    initialNote: widget.person.name,
                  ),
                ),
              );
            },
            onPlus: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withValues(alpha: 0.3),
                builder: (context) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AddTransactionDialog(
                    isIncome: true,
                    initialNote: widget.person.name,
                  ),
                ),
              );
>>>>>>> master
            },
          ),
        ),
      ),
<<<<<<< HEAD
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Balance Card
              Container(
                margin: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: useAdaptive
                          ? [
                              theme.colorScheme.surface,
                              theme.colorScheme.surface.withOpacity(0.8),
                            ]
                          : [
                              theme.colorScheme.surface,
                              theme.colorScheme.surface.withOpacity(0.8),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: widget.person.photoPath != null
                                ? null
                                : useAdaptive
                                    ? LinearGradient(
                                        colors: [
                                          theme.colorScheme.primaryContainer,
                                          theme.colorScheme.secondaryContainer,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          isPositive
                                              ? Colors.green
                                              : Colors.red,
                                          isPositive
                                              ? Colors.green.withOpacity(0.8)
                                              : Colors.red.withOpacity(0.8),
                                        ],
                                      ),
                            color: widget.person.photoPath != null
                                ? Colors.transparent
                                : null,
                            borderRadius: BorderRadius.circular(30),
                            border: widget.person.photoPath != null
                                ? Border.all(
                                    color: useAdaptive
                                        ? (isPositive
                                            ? Colors.green
                                            : Colors.red)
                                        : (isPositive
                                            ? Colors.green
                                            : Colors.red),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: widget.person.photoPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.file(
                                    File(widget.person.photoPath!),
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  isPositive
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: useAdaptive
                                      ? theme.colorScheme.onPrimaryContainer
                                      : Colors.white,
                                  size: 30,
                                ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: GoogleFonts.nunito(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isPositive ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPositive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isPositive ? 'Credit' : 'Debit',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
=======
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
>>>>>>> master
                    ),
                  ),
                ),
              ),
<<<<<<< HEAD

              // Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Transactions',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: useAdaptive
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${txs.length}',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: useAdaptive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Transactions List
              Expanded(
                child: txs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: useAdaptive
                                    ? theme.colorScheme.primary.withOpacity(0.1)
                                    : theme.colorScheme.primary
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 50,
                                color: useAdaptive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No transactions yet',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first transaction with ${widget.person.name}',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: txs.length + 1, // +1 for bottom padding
                        itemBuilder: (c, i) {
                          // Add bottom padding as last item
                          if (i == txs.length) {
                            return const SizedBox(height: 80);
                          }

                          final tx = txs[i];
                          final sign = tx.isIncome ? '+' : '-';
                          final isPositiveTx = tx.isIncome;

                          return AnimatedBuilder(
                            animation: _fadeController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset:
                                    Offset(0, 20 * (1 - _fadeController.value)),
                                child: Opacity(
                                  opacity: _fadeController.value,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        HapticFeedback.lightImpact();
                                        _showDeleteTransactionDialog(
                                            context, tx);
                                      },
                                      child: ZoomTapAnimation(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: useAdaptive
                                                  ? [
                                                      theme.colorScheme.surface,
                                                      theme.colorScheme.surface
                                                          .withOpacity(0.8),
                                                    ]
                                                  : [
                                                      theme.colorScheme.surface,
                                                      theme.colorScheme.surface
                                                          .withOpacity(0.8),
                                                    ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: useAdaptive
                                                  ? theme.colorScheme.primary
                                                      .withOpacity(0.3)
                                                  : isDark
                                                      ? Colors.teal.shade900
                                                          .withOpacity(0.3)
                                                      : Colors.teal
                                                          .withOpacity(0.3),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: useAdaptive
                                                    ? theme.colorScheme.shadow
                                                        .withOpacity(0.1)
                                                    : theme.colorScheme.shadow
                                                        .withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: useAdaptive
                                                          ? [
                                                              isPositiveTx
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              isPositiveTx
                                                                  ? Colors.green
                                                                      .withOpacity(
                                                                          0.8)
                                                                  : Colors.red
                                                                      .withOpacity(
                                                                          0.8),
                                                            ]
                                                          : [
                                                              isPositiveTx
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              isPositiveTx
                                                                  ? Colors.green
                                                                      .withOpacity(
                                                                          0.8)
                                                                  : Colors.red
                                                                      .withOpacity(
                                                                          0.8),
                                                            ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  child: Icon(
                                                    isPositiveTx
                                                        ? Icons.add
                                                        : Icons.remove,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        tx.note.isEmpty
                                                            ? 'No note'
                                                            : tx.note,
                                                        style:
                                                            GoogleFonts.nunito(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        DateFormat.yMMMd()
                                                            .add_jm()
                                                            .format(tx.date),
                                                        style:
                                                            GoogleFonts.nunito(
                                                          fontSize: 14,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface
                                                              .withOpacity(0.7),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '$sign₹${tx.amount.abs().toStringAsFixed(2)}',
                                                      style: GoogleFonts.nunito(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isPositiveTx
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: isPositiveTx
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors.red
                                                                .withOpacity(
                                                                    0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        isPositiveTx
                                                            ? 'Credit'
                                                            : 'Debit',
                                                        style:
                                                            GoogleFonts.nunito(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isPositiveTx
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
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
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
=======
            ),
            actions: [
              if (!isPositive)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => _payNow(total, person),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.payment_rounded,
                          color: AppColors.accentRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showEditPersonDialog(context, person);
                  },
                  child: Container(
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
                ),
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeHeaderDelegate(
              height: 210,
              child: RepaintBoundary(
                child: GestureDetector(
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    _showDeleteConfirmation(context, person);
                  },
                  child: PersonDetailHeader(
                    person: person,
                    total: total,
                    txsCount: txsCount,
                    fadeAnimation: _fadeAnimation,
                    slideAnimation: _slideAnimation,
                    currentSortOption: _sortOption,
                    onShowSortOptions: () {
                      HapticFeedback.selectionClick();
                      _showSortOptions(context);
                    },
                  ),
                ),
              ),
            ),
          ),
          if (groupedTxs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                description: 'Add your first transaction with the person',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildGroupedTransactionList(groupedTxs, theme),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactionList(
      Map<String, List<PersonTransaction>> groupedTxs, ThemeData theme) {
    final flatList = [];
    groupedTxs.forEach((date, items) {
      flatList.add(date);
      flatList.addAll(items);
    });

    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: flatList.map((item) {
            if (item is String) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  item,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              );
            }

            final tx = item as PersonTransaction;
            return PersonTransactionItem(
              tx: tx,
              animation: _fadeAnimation,
              onLongPress: () {
                HapticFeedback.lightImpact();
                _showDeleteTransactionDialog(context, tx);
              },
            );
          }).toList(),
>>>>>>> master
        ),
      ),
    );
  }

<<<<<<< HEAD
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Person',
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${widget.person.name}? This action cannot be undone.',
          style: GoogleFonts.nunito(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style:
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PersonViewModel>().deletePerson(widget.person);
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
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
=======
  void _settleBalance(
      BuildContext context, double currentTotal, Person currentPerson) {
    if (currentTotal == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
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
                  barrierColor: Colors.black.withValues(alpha: 0.3),
                  builder: (context) => BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AddTransactionDialog(
                      isIncome: currentTotal < 0,
                      initialAmount: currentTotal.abs(),
                      initialNote: '${currentPerson.name} - Settled balance',
                    ),
                  ),
                );
                HapticFeedback.mediumImpact();
              },
              child: Text('Settle', style: GoogleFonts.dmSans()),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Person currentPerson) {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600),
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
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
>>>>>>> master
      ),
    );
  }

  void _showDeleteTransactionDialog(
      BuildContext context, PersonTransaction tx) {
    showDialog(
      context: context,
<<<<<<< HEAD
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Transaction',
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: GoogleFonts.nunito(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style:
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
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
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTxDialog(BuildContext context) {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    bool isIncome = true;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSt) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add Transaction',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a transaction with ${widget.person.name}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amtCtrl,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: GoogleFonts.nunito(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.currency_rupee,
                      color: theme.colorScheme.primary),
                ),
                style: GoogleFonts.nunito(fontSize: 16),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  labelStyle: GoogleFonts.nunito(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.note_outlined,
                      color: theme.colorScheme.primary),
                ),
                style: GoogleFonts.nunito(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5)),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Is Income',
                    style: GoogleFonts.nunito(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isIncome ? 'You received money' : 'You gave money',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  value: isIncome,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    setSt(() => isIncome = v);
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(
=======
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: GoogleFonts.dmSans(
>>>>>>> master
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
<<<<<<< HEAD
                HapticFeedback.lightImpact();
                if (amtCtrl.text.isNotEmpty) {
                  final transaction = PersonTransaction(
                    personName: widget.person.name,
                    amount: double.parse(amtCtrl.text),
                    note: noteCtrl.text,
                    date: DateTime.now(),
                    isIncome: isIncome,
                  );

                  context
                      .read<PersonViewModel>()
                      .addPersonTransaction(transaction, widget.person.name);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Add Transaction',
                style: GoogleFonts.nunito(
=======
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
                style: GoogleFonts.dmSans(
>>>>>>> master
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  void _showEditPersonDialog(BuildContext context, Person person) {
    final controller = TextEditingController(text: person.name);
    final upiController = TextEditingController(text: person.upiId);
    final theme = Theme.of(context);
    String? selectedPhotoPath = person.photoPath;

    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: StatefulBuilder(
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
                const SizedBox(height: 16),
                TextField(
                  controller: upiController,
                  decoration: InputDecoration(
                    labelText: 'UPI ID',
                    labelStyle: GoogleFonts.dmSans(fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    prefixIcon: Icon(Icons.payment_rounded,
                        color: theme.colorScheme.primary),
                    hintText: 'user@upi',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  style: GoogleFonts.dmSans(fontSize: 16),
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
                      upiId: upiController.text.trim(),
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
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.borderRadiusXLarge)),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sort Transactions By',
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeLarge,
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption(context, 'Date (Recent)',
                  PersonTransactionSortOption.dateNewest),
              _buildSortOption(context, 'Date (Oldest)',
                  PersonTransactionSortOption.dateOldest),
              _buildSortOption(context, 'Amount (Highest)',
                  PersonTransactionSortOption.amountHighest),
              _buildSortOption(context, 'Amount (Lowest)',
                  PersonTransactionSortOption.amountLowest),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context, String title, PersonTransactionSortOption option) {
    final theme = Theme.of(context);
    final isSelected = _sortOption == option;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        Navigator.pop(context);
      },
    );
  }
>>>>>>> master
}
