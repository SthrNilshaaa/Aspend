import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/person_provider.dart';
import '../providers/theme_provider.dart';
import '../models/person_transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  final bool isIncome;
  const AddTransactionDialog({super.key, required this.isIncome});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _category;
  String _account = "Cash";
  final List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> incomeCategories = [
    "Salary",
    "Freelance",
    "Investment",
    "Gift",
    "Refund",
    "Other"
  ];
  final List<String> expenseCategories = [
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Entertainment",
    "Health",
    "Education",
    "Other"
  ];
  final List<String> accounts = ["Cash", "Online", "Credit Card", "Bank"];

  @override
  void initState() {
    super.initState();
    _category = widget.isIncome ? "Salary" : "Food";
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
      final transaction = Transaction(
        amount: amount,
        note: _noteController.text,
        date: DateTime.now(),
        isIncome: widget.isIncome,
        category: _category,
        account: _account,
        imagePaths: _imagePaths,
      );

      context.read<TransactionProvider>().addTransaction(transaction);
      _checkAndAddPersonTransactions(transaction);
      Navigator.pop(context);
    }
  }

  void _checkAndAddPersonTransactions(Transaction tx) {
    if (tx.note.isEmpty) return;

    final personProvider = context.read<PersonProvider>();
    final people = personProvider.people;
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
        personProvider.addTransaction(personTx);

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
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isIncome ? "Add Income" : "Add Expense",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _account,
                  decoration: const InputDecoration(labelText: "Account"),
                  items: accounts
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (val) => setState(() => _account = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: "Note (Optional)",
                    prefixIcon: Icon(Icons.note_alt_outlined),
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
                  label: const Text("Add Attachment"),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isIncome ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Save Transaction"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
