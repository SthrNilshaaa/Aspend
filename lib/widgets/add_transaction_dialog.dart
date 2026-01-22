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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                    horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.65),
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
                              ? (widget.isIncome
                                  ? 'Edit Income'
                                  : 'Edit Expense')
                              : (widget.isIncome
                                  ? 'Add Income'
                                  : 'Add Expense'),
                          style: GoogleFonts.nunito(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 20,
                                tablet: 24,
                                desktop: 28),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: GoogleFonts.nunito(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            labelStyle: GoogleFonts.nunito(),
                            prefixIcon: const Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (val) =>
                              (val == null || val.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          style: GoogleFonts.nunito(
                              color: theme.colorScheme.onSurface, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: GoogleFonts.nunito(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: categories
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setState(() => _category = val!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _account,
                          style: GoogleFonts.nunito(
                              color: theme.colorScheme.onSurface, fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Account',
                            labelStyle: GoogleFonts.nunito(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: accounts
                              .map((a) =>
                                  DropdownMenuItem(value: a, child: Text(a)))
                              .toList(),
                          onChanged: (val) => setState(() => _account = val!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          style: GoogleFonts.nunito(fontSize: 16),
                          decoration: InputDecoration(
                            labelText: 'Note (Optional)',
                            labelStyle: GoogleFonts.nunito(),
                            prefixIcon: const Icon(Icons.note_alt_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_imagePaths.isNotEmpty) ...[
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imagePaths.length,
                              itemBuilder: (context, index) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(File(_imagePaths[index])),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: const Text('Add Attachment'),
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
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            (widget.existingTransaction != null ||
                                    widget.existingPersonTransaction != null)
                                ? 'Update Transaction'
                                : 'Save Transaction',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
