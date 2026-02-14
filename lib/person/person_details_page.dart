import 'package:aspends_tracker/const/app_colors.dart';
import 'package:aspends_tracker/const/app_dimensions.dart';
import 'package:aspends_tracker/widgets/floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../const/app_assets.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../view_models/person_view_model.dart';
import '../widgets/header_delegate.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/person_transaction_item.dart';
import '../widgets/person_detail_header.dart';
import '../const/app_typography.dart';

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
  PersonTransactionSortOption _sortOption =
      PersonTransactionSortOption.dateNewest;

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

  void _showSortOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
}
