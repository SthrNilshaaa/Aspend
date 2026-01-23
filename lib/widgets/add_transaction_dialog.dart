import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/person_view_model.dart';
import 'package:aspends_tracker/models/person_transaction.dart';
import '../utils/responsive_utils.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _category;
  String _account = 'Cash';
  final List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Bonus',
    'Investment',
    'Interest',
    'Rent Received',
    'Gift',
    'Cashback',
    'Business',
    'Refund',
    'Other'
  ];
  final List<String> expenseCategories = [
    'Food',
    'Groceries',
    'Transport',
    'Fuel',
    'Shopping',
    'Bills',
    'Rent',
    'Entertainment',
    'Health',
    'Education',
    'Travel',
    'Maintenance',
    'Insurance',
    'Subscription',
    'Personal Care',
    'Tax',
    'Gifts',
    'Charity',
    'Loan Repayment',
    'Other'
  ];
  final List<String> accounts = [
    'Cash',
    'Bank',
    'Savings',
    'Wallet',
    'UPI',
    'Credit Card',
    'Debit Card',
    'Online'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      _amountController.text = widget.existingTransaction!.amount.toString();
      _noteController.text = widget.existingTransaction!.note;
      _category = widget.existingTransaction!.category;
      _account = widget.existingTransaction!.account;
      if (widget.existingTransaction!.imagePaths != null) {
        _imagePaths.addAll(widget.existingTransaction!.imagePaths!);
      }
    } else if (widget.existingPersonTransaction != null) {
      _amountController.text =
          widget.existingPersonTransaction!.amount.toString();
      _noteController.text = widget.existingPersonTransaction!.note;
      _category =
          'Other'; // Person transactions don't have categories by default
      _account = 'Cash';
    } else {
      _category = widget.isIncome ? 'Salary' : 'Food';
      if (widget.initialNote != null) {
        _noteController.text = widget.initialNote!;
      }
      if (widget.initialAmount != null) {
        _amountController.text = widget.initialAmount!.abs().toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      if (widget.existingTransaction != null) {
        final updatedTx = Transaction(
          amount: amount,
          note: _noteController.text,
          date: widget.existingTransaction!.date,
          isIncome: widget.isIncome,
          category: _category,
          account: _account,
          imagePaths: _imagePaths,
        );

        context
            .read<TransactionViewModel>()
            .updateTransaction(widget.existingTransaction!, updatedTx);
      } else if (widget.existingPersonTransaction != null) {
        final updatedPersonTx = PersonTransaction(
          personName: widget.existingPersonTransaction!.personName,
          amount: amount,
          note: _noteController.text,
          date: widget.existingPersonTransaction!.date,
          isIncome: widget.isIncome,
        );

        context.read<PersonViewModel>().updatePersonTransaction(
            widget.existingPersonTransaction!, updatedPersonTx);
      } else {
        final transaction = Transaction(
          amount: amount,
          note: _noteController.text,
          date: DateTime.now(),
          isIncome: widget.isIncome,
          category: _category,
          account: _account,
          imagePaths: _imagePaths,
        );

        context.read<TransactionViewModel>().addTransaction(transaction);
        _checkAndAddPersonTransactions(transaction);
      }
      Navigator.pop(context);
    }
  }

  void _checkAndAddPersonTransactions(Transaction tx) {
    if (tx.note.isEmpty) return;

    final personViewModel = context.read<PersonViewModel>();
    final people = personViewModel.people;
    final note = tx.note.toLowerCase();

    for (final person in people) {
      if (note.contains(person.name.toLowerCase())) {
        final personTx = PersonTransaction(
          personName: person.name,
          amount: tx.amount,
          note: tx.note,
          date: tx.date,
          isIncome: tx.isIncome,
        );
        personViewModel.addPersonTransaction(personTx, person.name);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Transaction also added to ${person.name}'s record"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.isIncome ? incomeCategories : expenseCategories;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                  horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.80),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.existingTransaction != null
                            ? (widget.isIncome ? 'Edit Income' : 'Edit Expense')
                            : (widget.isIncome ? 'Add Income' : 'Add Expense'),
                        style: GoogleFonts.nunito(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 22,
                              tablet: 26,
                              desktop: 28),
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.isIncome ? Colors.green : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surface.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                        ),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Category',
                              value: _category,
                              items: categories,
                              onChanged: (val) =>
                                  setState(() => _category = val!),
                              theme: theme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Account',
                              value: _account,
                              items: accounts,
                              onChanged: (val) =>
                                  setState(() => _account = val!),
                              theme: theme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        style: GoogleFonts.nunito(fontSize: 16),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Note (Optional)',
                          labelStyle: GoogleFonts.nunito(),
                          prefixIcon: const Icon(Icons.note_alt_outlined),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surface.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_imagePaths.isNotEmpty) ...[
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagePaths.length,
                            itemBuilder: (context, index) => Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image:
                                          FileImage(File(_imagePaths[index])),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _imagePaths.removeAt(index)),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: Text(
                          'Add Attachment',
                          style:
                              GoogleFonts.nunito(fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.isIncome ? Colors.green : Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                          shadowColor:
                              (widget.isIncome ? Colors.green : Colors.red)
                                  .withValues(alpha: 0.4),
                        ),
                        child: Text(
                          (widget.existingTransaction != null ||
                                  widget.existingPersonTransaction != null)
                              ? 'Update Transaction'
                              : 'Save Transaction',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: GoogleFonts.nunito(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(),
        filled: true,
        fillColor: theme.colorScheme.surface.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      items:
          items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: onChanged,
    );
  }
}
