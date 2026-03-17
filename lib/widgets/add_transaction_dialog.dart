import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/models/transaction.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/view_models/person_view_model.dart';
import '../core/models/person_transaction.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amount.text);
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingLarge + 8,
                      horizontal: AppDimensions.paddingXLarge),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (widget.isIncome
                                ? AppColors.accentGreen
                                : AppColors.accentRed)
                            .withValues(alpha: isDark ? 0.15 : 0.08),
                        (widget.isIncome
                                ? AppColors.accentGreen
                                : AppColors.accentRed)
                            .withValues(alpha: isDark ? 0.05 : 0.02),
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
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Amount in INR',
                        style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeXSmall,
                          fontWeight: FontWeight.bold,
                          color: (widget.isIncome
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed)
                              .withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                      .withValues(alpha: 0.2),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                              textAlign: TextAlign.center,
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
                // Quick Category Scroll
                Text(
                  'Quick Categories',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                                  ? color.withValues(alpha: 0.15)
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? color.withValues(alpha: 0.4)
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
                                            .withValues(alpha: 0.6),
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

                // Date & Category Pickers Row
                Row(
                  children: [
                    Expanded(
                      child: _picker(
                          'Category',
                          _category,
                          cats,
                          (v) => setState(() => _category = v),
                          widget.isIncome ? 'Income' : 'Expense'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _picker('Account', _account, accs,
                          (v) => setState(() => _account = v), 'Account'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Picker
                _picker(
                    'Date',
                    DateFormat('dd MMM, yyyy').format(_selectedDate),
                    [],
                    (v) {},
                    'Date'),

                const SizedBox(height: 16),

                // Note Input
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
                          ?.withValues(alpha: 0.5),
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
                            theme.colorScheme.primary.withValues(alpha: 0.8),
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
                          color: theme.dividerColor.withValues(alpha: 0.1)),
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

                // Action Buttons
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
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
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
    );
  }

  Widget _picker(String label, String val, List<String> items,
      ValueChanged<String> onDone, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeXSmall, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            if (type == 'Date') {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _selectedDate = date);
            } else if (type == 'Category') {
              _showCategoryGrid(context, items, val, onDone);
            } else {
              _showManageItems(context, type, items, val, onDone);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withAlpha(100)),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusSmall),
            ),
            child: Row(
              children: [
                if (type == 'Date') ...[
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                ] else if (type == 'Income' || type == 'Expense') ...[
                  SvgPicture.asset(TransactionUtils.getCategorySvg(val),
                      colorFilter: ColorFilter.mode(
                          TransactionUtils.getCategoryColor(val),
                          BlendMode.srcIn),
                      width: 18,
                      height: 18),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(val, style: GoogleFonts.dmSans())),
                if (type != 'Date') const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryGrid(BuildContext context, List<String> items, String val,
      ValueChanged<String> onDone) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Category',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final category = items[index];
                  final isSelected = category == val;
                  final color = TransactionUtils.getCategoryColor(category);
                  final iconSvg = TransactionUtils.getCategorySvg(category);

                  return ZoomTapAnimation(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onDone(category);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.1)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? color.withValues(alpha: 0.5)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              iconSvg,
                              colorFilter:
                                  ColorFilter.mode(color, BlendMode.srcIn),
                              width: 24,
                              height: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? color : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageItems(BuildContext context, String type, List<String> items,
      String selected, ValueChanged<String> onDone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(builder: (c, setStateSheet) {
        final tvm = c.watch<ThemeViewModel>();
        final currentItems = (type == 'Income')
            ? tvm.incomeCategories
            : (type == 'Expense')
                ? tvm.expenseCategories
                : tvm.accounts;

        return Container(
          decoration: BoxDecoration(
              color: Theme.of(c).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.borderRadiusLarge))),
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(c).size.height * 0.5,
          child: Column(
            children: [
              Text('Select $type',
                  style: GoogleFonts.dmSans(
                      fontSize: AppTypography.fontSizeLarge - 2,
                      fontWeight: AppTypography.fontWeightBold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: currentItems.length,
                  itemBuilder: (c, i) {
                    final item = currentItems[i];
                    return ListTile(
                      leading: (type == 'Income' || type == 'Expense')
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: TransactionUtils.getCategoryColor(item)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                TransactionUtils.getCategorySvg(item),
                                colorFilter: ColorFilter.mode(
                                    TransactionUtils.getCategoryColor(item),
                                    BlendMode.srcIn),
                                width: 20,
                                height: 20,
                              ),
                            )
                          : null,
                      title: Text(item,
                          style: GoogleFonts.dmSans(
                              fontWeight: item == selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      onTap: () {
                        onDone(item);
                        Navigator.pop(c);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _imageGrid() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (c, i) => Stack(children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 90,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
              image: DecorationImage(
                  image: FileImage(File(_images[i])), fit: BoxFit.cover),
            ),
          ),
          Positioned(
              top: 4,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _images.removeAt(i)),
                child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.accentRed,
                    child: Icon(Icons.close,
                        size: AppTypography.fontSizeXSmall,
                        color: Colors.white)),
              )),
        ]),
      ),
    );
  }
}
