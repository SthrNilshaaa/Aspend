import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../view_models/person_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../widgets/modern_card.dart';
import '../widgets/add_transaction_dialog.dart';
import '../utils/error_handler.dart';
//import 'dart:async';

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
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final useAdaptive = themeViewModel.useAdaptiveColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: ClipRRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Bottom layer: Blur
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(color: Colors.transparent),
                ),
                // Middle layer: Gradient tint
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                        theme.colorScheme.surface.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
                // Top layer: Subtle border for "one more effect"
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            person.name,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showDeleteConfirmation(context, person);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 24,
              ),
              onPressed: () => _showEditPersonDialog(context, person),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
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
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddTransactionDialog(
                  isIncome: true,
                  initialNote: person.name,
                ),
              );
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ModernCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                            ),
                            child: person.photoPath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.file(
                                      File(person.photoPath!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    isPositive
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: isPositive
                                        ? Colors.greenAccent.shade700
                                        : Colors.redAccent,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Balance',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '₹${total.abs().toStringAsFixed(2)}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: isPositive
                                        ? Colors.greenAccent.shade700
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (total != 0) ...[
                        const SizedBox(height: 20),
                        ZoomTapAnimation(
                          onTap: () => _settleBalance(context, total, person),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Settle Balance',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

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
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
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
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.1)
                                    : theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
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
                              'Add your first transaction with ${person.name}',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
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
                                            gradient: LinearGradient(
                                              colors: useAdaptive
                                                  ? [
                                                      theme.colorScheme.surface,
                                                      theme.colorScheme.surface
                                                          .withValues(
                                                              alpha: 0.8),
                                                    ]
                                                  : [
                                                      theme.colorScheme.surface,
                                                      theme.colorScheme.surface
                                                          .withValues(
                                                              alpha: 0.8),
                                                    ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: useAdaptive
                                                  ? theme.colorScheme.primary
                                                      .withValues(alpha: 0.3)
                                                  : isDark
                                                      ? Colors.teal.shade900
                                                          .withValues(
                                                              alpha: 0.3)
                                                      : Colors.teal.withValues(
                                                          alpha: 0.3),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: useAdaptive
                                                    ? theme.colorScheme.shadow
                                                        .withValues(alpha: 0.1)
                                                    : theme.colorScheme.shadow
                                                        .withValues(alpha: 0.1),
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
                                                                      .withValues(
                                                                          alpha:
                                                                              0.8)
                                                                  : Colors.red
                                                                      .withValues(
                                                                          alpha:
                                                                              0.8),
                                                            ]
                                                          : [
                                                              isPositiveTx
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              isPositiveTx
                                                                  ? Colors.green
                                                                      .withValues(
                                                                          alpha:
                                                                              0.8)
                                                                  : Colors.red
                                                                      .withValues(
                                                                          alpha:
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
                                                              .withValues(
                                                                  alpha: 0.7),
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
                                                                .withValues(
                                                                    alpha: 0.1)
                                                            : Colors.red
                                                                .withValues(
                                                                    alpha: 0.1),
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
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        content: Text(
          'This will add a transaction of ₹${currentTotal.abs().toStringAsFixed(2)} to bring the balance to zero. Continue?',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.nunito()),
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
            child: Text('Settle', style: GoogleFonts.nunito()),
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
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${currentPerson.name}? This action cannot be undone.',
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
                  GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
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
            style: GoogleFonts.nunito(
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
                              style: GoogleFonts.nunito(
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
                style: GoogleFonts.nunito(
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
                  labelStyle: GoogleFonts.nunito(fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  prefixIcon: Icon(Icons.person_outline,
                      color: theme.colorScheme.primary),
                ),
                style: GoogleFonts.nunito(fontSize: 16),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(
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
                style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
