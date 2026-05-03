import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../core/models/transaction.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/view_models/person_view_model.dart';
import '../core/models/person_transaction.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_assets.dart';
import '../core/utils/transaction_utils.dart';

class AddTransactionDialog extends StatefulWidget {
  final bool isIncome;
  final Transaction? existingTransaction;
  final PersonTransaction? existingPersonTransaction;
  final String? initialNote;
  final double? initialAmount;

  const AddTransactionDialog({
    super.key,
    required this.isIncome,
    this.existingTransaction,
    this.existingPersonTransaction,
    this.initialNote,
    this.initialAmount,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late String _category;
  late String _account;
  late DateTime _selectedDate;
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    final ctx = widget.existingPersonTransaction;
    _category = tx?.category ?? (widget.isIncome ? 'Salary' : 'Food');
    _account = tx?.account ?? 'Cash';
    _selectedDate = tx?.date ?? ctx?.date ?? DateTime.now();
    if (tx != null) {
      _amount.text = tx.amount.toString();
      _note.text = tx.note;
      _images.addAll(tx.imagePaths ?? []);
    } else if (ctx != null) {
      _amount.text = ctx.amount.toString();
      _note.text = ctx.note;
      _category = 'Other';
    } else {
      _note.text = widget.initialNote ?? '';
      _amount.text = widget.initialAmount?.abs().toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amountText = _amount.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;
    final vm = context.read<TransactionViewModel>();
    final pvm = context.read<PersonViewModel>();

    if (widget.existingTransaction != null) {
      vm.updateTransaction(
          widget.existingTransaction!,
          Transaction(
            amount: amount,
            note: _note.text,
            date: _selectedDate,
            isIncome: widget.isIncome,
            category: _category,
            account: _account,
            imagePaths: _images,
          ));
    } else if (widget.existingPersonTransaction != null) {
      pvm.updatePersonTransaction(
          widget.existingPersonTransaction!,
          PersonTransaction(
            personName: widget.existingPersonTransaction!.personName,
            amount: amount,
            note: _note.text,
            date: _selectedDate,
            isIncome: widget.isIncome,
          ));
    } else {
      final tx = Transaction(
        amount: amount,
        note: _note.text,
        date: _selectedDate,
        isIncome: widget.isIncome,
        category: _category,
        account: _account,
        imagePaths: _images,
      );
      vm.addTransaction(tx);
      _syncPerson(tx, pvm);
    }
    Navigator.pop(context);
  }

  void _syncPerson(Transaction tx, PersonViewModel pvm) {
    if (tx.note.isEmpty) return;
    for (final p in pvm.people) {
      if (tx.note.toLowerCase().contains(p.name.toLowerCase())) {
        pvm.addPersonTransaction(
            PersonTransaction(
              personName: p.name,
              amount: tx.amount,
              note: tx.note,
              date: tx.date,
              isIncome: tx.isIncome,
            ),
            p.name);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Linked to ${p.name}'s record"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tvm = context.watch<ThemeViewModel>();
    final isDark = tvm.isDarkMode;
    final cats = widget.isIncome ? tvm.incomeCategories : tvm.expenseCategories;
    final accs = tvm.accounts;

    if (!cats.contains(_category)) {
      _category = cats.isNotEmpty ? cats.first : 'Other';
    }
    if (!accs.contains(_account)) {
      _account = accs.isNotEmpty ? accs.first : 'Cash';
    }

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.borderRadiusXLarge)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stylized Amount Header
                    GestureDetector(
                      onTap: () {
                        if (_amount.text == '0.00') {
                          _amount.text = '';
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingLarge + 8,
                            horizontal: AppDimensions.paddingXLarge),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (widget.isIncome
                                      ? AppColors.accentGreen
                                      : AppColors.accentRed)
                                  .withOpacity(isDark ? 0.15 : 0.08),
                              (widget.isIncome
                                      ? AppColors.accentGreen
                                      : AppColors.accentRed)
                                  .withOpacity(isDark ? 0.10 : 0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.borderRadiusXLarge),
                          border: Border.all(
                            color: (widget.isIncome
                                    ? AppColors.accentGreen
                                    : AppColors.accentRed)
                                .withOpacity(isDark ? 0.2 : 0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount in INR',
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography.fontSizeXSmall,
                                fontWeight: FontWeight.bold,
                                color: (widget.isIncome
                                        ? AppColors.accentGreen
                                        : AppColors.accentRed)
                                    .withOpacity(0.6),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹',
                                  style: GoogleFonts.dmSans(
                                    fontSize: AppTypography.fontSizeXXLarge,
                                    fontWeight: AppTypography.fontWeightBlack,
                                    color: widget.isIncome
                                        ? AppColors.accentGreen
                                        : AppColors.accentRed,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IntrinsicWidth(
                                  child: TextFormField(
                                    controller: _amount,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.bayon(
                                      fontSize: AppTypography.fontSizeGigantic + 10,
                                      color: widget.isIncome
                                          ? AppColors.accentGreen
                                          : AppColors.accentRed,
                                      letterSpacing: 0,
                                      height: 1,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: GoogleFonts.bayon(
                                        color: (widget.isIncome
                                                ? AppColors.accentGreen
                                                : AppColors.accentRed)
                                            .withOpacity(0.2),
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    textAlign: TextAlign.start,
                                    validator: (v) =>
                                        (v?.isEmpty ?? true) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Categories',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: cats.map((cat) {
                          final isSelected = _category == cat;
                          final color = TransactionUtils.getCategoryColor(cat);
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ZoomTapAnimation(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _category = cat);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.15)
                                      : isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? color.withOpacity(0.4)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      TransactionUtils.getCategorySvg(cat),
                                      colorFilter: ColorFilter.mode(
                                          isSelected ? color : Colors.grey,
                                          BlendMode.srcIn),
                                      width: 16,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? color
                                            : theme.colorScheme.onSurface
                                                .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _picker(
                              'Category',
                              _category,
                              cats,
                              (v) => setState(() => _category = v!),
                              widget.isIncome ? 'Income' : 'Expense'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _picker('Account', _account, accs,
                              (v) => setState(() => _account = v!), 'Account'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _picker(
                        'Date',
                        DateFormat('dd MMM, yyyy').format(_selectedDate),
                        [],
                        (v) {},
                        'Date'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _note,
                      maxLines: 2,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: AppTypography.fontSizeSmall + 1,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Note',
                        labelStyle: GoogleFonts.dmSans(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.5),
                        ),
                        floatingLabelStyle: GoogleFonts.dmSans(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            SvgAppIcons.noteIcon,
                            colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary.withOpacity(0.8),
                                BlendMode.srcIn),
                            width: 20,
                            height: 20,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusLarge),
                          borderSide: BorderSide(
                              color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusLarge),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_images.isNotEmpty) ...[
                      _imageGrid(),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        ZoomTapAnimation(
                          onTap: () async {
                            final img = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (img != null) setState(() => _images.add(img.path));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withOpacity(0.2),
                              ),
                            ),
                            child: Icon(Icons.add_a_photo_rounded,
                                color: theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isIncome
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusFull),
                              ),
                            ),
                            child: Text(
                              widget.existingTransaction != null
                                  ? 'Update Transaction'
                                  : 'Save Transaction',
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography.fontSizeMedium,
                                fontWeight: AppTypography.fontWeightBlack,
                                letterSpacing: 0.5,
                              ),
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
    );
  }

  Widget _picker(String label, String value, List<String> items,
      ValueChanged<String?> onChanged, String type) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: items.isEmpty
          ? () async {
              if (type == 'Date') {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              }
            }
          : () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items
                        .map((item) => ListTile(
                              title: Text(item),
                              onTap: () {
                                onChanged(item);
                                Navigator.pop(context);
                              },
                            ))
                        .toList(),
                  ),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.dmSans(
                    fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _imageGrid() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, i) => Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    image: FileImage(File(_images[i])), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 4,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: () => setState(() => _images.removeAt(i)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
