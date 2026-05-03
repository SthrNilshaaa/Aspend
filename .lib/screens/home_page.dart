import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../core/models/transaction.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/view_models/person_view_model.dart';
import '../core/models/person_transaction.dart';
import '../core/services/native_bridge.dart';
import '../core/services/transaction_detection_service.dart';
import '../core/services/speech_service.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_constants.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_assets.dart';
import '../core/utils/blur_utils.dart';
import '../core/utils/voice_parser.dart';

import '../widgets/header_delegate.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/glass_action_button.dart';
import '../widgets/recording_hud.dart';
import '../widgets/request_money_dialog.dart';

import '../shared/widgets/home_app_bar.dart';
import '../shared/widgets/home_balance_section.dart';
import '../shared/widgets/home_search_bar.dart';
import '../shared/widgets/home_transaction_list.dart';

import 'settings_page.dart';
import 'transactions_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showFab = true;
  double _turns = 0.0;
  StreamSubscription<String>? _uiEventSubscription;
  
  final SpeechService _speechService = SpeechService();
  String _recordingText = "";
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _uiEventSubscription = NativeBridge.uiEvents.listen(_handleUiEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingEvent = NativeBridge.consumePendingEvent();
      if (pendingEvent != null) {
        _handleUiEvent(pendingEvent);
      }
    });
  }

  void _scrollListener() {
    if (!_scrollController.hasClients || !mounted) return;

    final position = _scrollController.position;
    final atTop = position.pixels <= 0;

    final scrollingUp = position.userScrollDirection == ScrollDirection.forward;
    final scrollingDown =
        position.userScrollDirection == ScrollDirection.reverse;
    final isEmpty = context.read<TransactionViewModel>().transactions.isEmpty;

    bool nextShowFab = _showFab;

    if (isEmpty || atTop || scrollingUp) {
      nextShowFab = true;
    } else if (scrollingDown) {
      nextShowFab = false;
    }

    if (nextShowFab != _showFab) {
      setState(() => _showFab = nextShowFab);
    }
  }

  void _handleUiEvent(String event) {
    Future.delayed(AppConstants.homeArrivalDelay, () {
      if (!mounted) return;
      if (event == 'SHOW_ADD_INCOME') {
        _showAddTransactionDialog(isIncome: true);
      } else if (event == 'SHOW_ADD_EXPENSE') {
        _showAddTransactionDialog(isIncome: false);
      } else if (event == 'SHOW_VOICE_INPUT') {
        _startRecording();
      } else if (event == 'SYNC_STARTED') {
        context.read<TransactionViewModel>().setSyncing(true);
      } else if (event == 'SYNC_FINISHED') {
        context.read<TransactionViewModel>().setSyncing(false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  void _showAddTransactionDialog({required bool isIncome}) {
    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: AddTransactionDialog(isIncome: isIncome),
    );
  }

  Future<void> _startRecording() async {
    final success = await _speechService.initSpeech();
    if (success) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isRecording = true;
        _recordingText = "";
      });
      _speechService.startListening((text) {
        setState(() => _recordingText = text);
      });
    } else {
      Fluttertoast.showToast(msg: "Speech recognition unavailable");
    }
  }

  Future<void> _stopAndSaveRecording() async {
    if (!_isRecording) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _isRecording = false);
    await _speechService.stopListening();

    if (_recordingText.isEmpty) return;

    final pvm = context.read<PersonViewModel>();
    final tvm = context.read<TransactionViewModel>();
    
    final result = VoiceParser.parse(
      _recordingText, 
      knownPeople: pvm.people.map((p) => p.name).toList(),
    );

    if (result.isRequest && result.amount != null && result.personName != null) {
      showDialog(
        context: context,
        builder: (context) => RequestMoneyDialog(
          personName: result.personName!,
          amount: result.amount!,
        ),
      );
      Fluttertoast.showToast(msg: "Opening Request QR for ${result.personName}");
      return; 
    }

    if (result.amount != null) {
      final tx = Transaction(
        amount: result.amount!,
        note: result.note,
        category: result.category ?? 'Other',
        account: 'Cash',
        date: DateTime.now(),
        isIncome: result.isIncome ?? false,
      );

      await tvm.addTransaction(tx);

      if (result.personName != null) {
        pvm.addPersonTransaction(
          PersonTransaction(
            personName: result.personName!,
            amount: tx.amount,
            note: tx.note,
            date: tx.date,
            isIncome: tx.isIncome,
          ), 
          result.personName!,
        );
      }

      Fluttertoast.showToast(
        msg: "Saved ₹${result.amount} for ${result.category ?? 'Other'}",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      HapticFeedback.vibrate();
      Fluttertoast.showToast(
        msg: "Couldn't find amount. Try: 'Spent 500 on Food'",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      // Fallback: Open manual dialog
      _showAddTransactionDialog(isIncome: result.isIncome ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionViewModel = context.watch<TransactionViewModel>();
    final isDark = context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode);

    final grouped = transactionViewModel.groupedFilteredTransactions;
    final txns = transactionViewModel.filteredTransactions;

    return Scaffold(
      extendBody: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              HomeAppBar(
                isDark: isDark,
                turns: _turns,
                isSyncing: transactionViewModel.isSyncing,
                onLeadingTap: () => setState(() => _turns += 4),
              ),
              HomeBalanceSection(viewModel: transactionViewModel),
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeHeaderDelegate(
                  height: 140 * MediaQuery.textScalerOf(context).scale(1) + 20,
                  child: _buildPinnedHeader(context),
                ),
              ),
              if (txns.isNotEmpty)
                HomeTransactionList(grouped: grouped)
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: txns.isNotEmpty
                      ? MediaQuery.of(context).padding.bottom +
                          AppDimensions.paddingXLarge * 2.5
                      : MediaQuery.of(context).padding.bottom +
                          AppDimensions.paddingXLarge * 3,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 130, 
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              reverseDuration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: child,
                  ),
                );
              },
              child: _isRecording
                  ? RecordingHUD(
                      key: const ValueKey('recording_hud'),
                      text: _recordingText,
                      isListening: _isRecording,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
          AnimatedSlide(
            offset: _showFab ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _showFab ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: _buildDualFab(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedHeader(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      shape: const LiquidRoundedRectangle(borderRadius: 0),
      quality: GlassQuality.premium,
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildDragHandle(context),
          const SizedBox(height: AppDimensions.paddingXSmall),
          HomeSearchBar(onFilterTap: () {
            HapticFeedback.mediumImpact();
            _showSortDialog(context);
          }),
          const SizedBox(height: AppDimensions.paddingXSmall),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingStandard,
              vertical: AppDimensions.paddingSmall,
            ),
            child: _buildTransactionHeaderRow(context),
          ),
        ],
      ),
    );
  }


  Widget _buildTransactionHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.transactionsTitle,
            style: GoogleFonts.dmSans(
              fontSize: AppTypography.fontSizeSubHeader + 2,
              fontWeight: AppTypography.fontWeightBlack,
              letterSpacing: -0.5,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionsHistoryPage(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.viewAllLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: AppTypography.fontSizeSmall + 1,
                    fontWeight: AppTypography.fontWeightBold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<TransactionViewModel>();

    BlurUtils.showBlurredBottomSheet(
      context: context,
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
                  color: theme.dividerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sort By',
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeLarge,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(
                context, 'Date (Newest)', SortOption.dateNewest, vm),
            _buildSortOption(
                context, 'Date (Oldest)', SortOption.dateOldest, vm),
            _buildSortOption(
                context, 'Amount (Highest)', SortOption.amountHighest, vm),
            _buildSortOption(
                context, 'Amount (Lowest)', SortOption.amountLowest, vm),
            _buildSortOption(context, 'Category', SortOption.category, vm),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String title, SortOption option,
      TransactionViewModel vm) {
    final theme = Theme.of(context);
    final isSelected = vm.currentSortOption == option;

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
        vm.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: AppDimensions.avatarSizeStandard,
        height: AppDimensions.spacingXSmall,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppDimensions.spacingTiny),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateView(
      icon: Icons.account_balance_wallet_outlined,
      title: AppStrings.emptyWalletTitle,
      description: AppStrings.emptyWalletDesc,
      action: FutureBuilder<bool>(
        future: TransactionDetectionService.isEnabled(),
        builder: (context, snapshot) {
          final isEnabled = snapshot.data ?? false;
          if (isEnabled) return const SizedBox.shrink();

          return ZoomTapAnimation(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.3),
                    blurRadius: AppDimensions.blurRadiusStandard,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.enableAutoDetection,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: AppTypography.fontWeightBold,
                      fontSize: AppTypography.fontSizeMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDualFab(ThemeData theme) {
    return GlassFab(
      marginBottom: 65,
      children: [
        ClipOval(
          child: GlassActionButton(
            icon: SvgAppIcons.incomeIcon,
            color: AppColors.accentGreen,
            onTap: () => _showAddTransactionDialog(isIncome: true),
          ),
        ),
        const SizedBox(width: 8),
        ClipOval(
          child: GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) async {
              await Future.delayed(const Duration(milliseconds: 900));
              _stopAndSaveRecording();
            },
            onLongPressUp: () async {
              await Future.delayed(const Duration(milliseconds: 900));
              _stopAndSaveRecording();
            },
            child: GlassActionButton(
              icon: Icons.mic_rounded,
              color: theme.colorScheme.primary,
              onTap: () {
                Fluttertoast.showToast(msg: "Hold to record transaction");
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipOval(
          child: GlassActionButton(
            icon: SvgAppIcons.expenseIcon,
            color: AppColors.accentRed,
            onTap: () => _showAddTransactionDialog(isIncome: false),
          ),
        ),
      ],
    );
  }
}

class GlassFab extends StatelessWidget {
  final List<Widget> children;
  final double marginBottom;

  const GlassFab({
    super.key,
    required this.children,
    this.marginBottom = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const LiquidRoundedRectangle(borderRadius: 36),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

