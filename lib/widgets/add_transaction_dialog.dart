import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/person_view_model.dart';
import '../models/person_transaction.dart';
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
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late String _category;
  late String _account;
  final List<String> _images = [];

  @override
  void initState() {
    super.initState();
    final tx = widget.existingTransaction;
    final ctx = widget.existingPersonTransaction;
    _category = tx?.category ?? (widget.isIncome ? 'Salary' : 'Food');
    _account = tx?.account ?? 'Cash';
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
            date: widget.existingTransaction!.date,
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
            date: widget.existingPersonTransaction!.date,
            isIncome: widget.isIncome,
          ));
    } else {
      final tx = Transaction(
        amount: amount,
        note: _note.text,
        date: DateTime.now(),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.isIncome ? 'Income' : 'Expense',
                    style: GoogleFonts.nunito(
                        fontSize: 22, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.isIncome ? Colors.green : Colors.red),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      hintText: '0', prefixIcon: Icon(Icons.currency_rupee)),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: _picker(
                          'Category',
                          _category,
                          cats,
                          (v) => setState(() => _category = v),
                          widget.isIncome ? 'Income' : 'Expense')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _picker('Account', _account, accs,
                          (v) => setState(() => _account = v), 'Account')),
                ]),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Note',
                      prefixIcon: Icon(Icons.note_alt_outlined)),
                ),
                const SizedBox(height: 24),
                if (_images.isNotEmpty) _imageGrid(),
                TextButton.icon(
                  onPressed: () async {
                    final img = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (img != null) setState(() => _images.add(img.path));
                  },
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
                  ),
                  child: Text('Save Transaction',
                      style: GoogleFonts.nunito(
                          fontSize: 18, fontWeight: FontWeight.w900)),
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
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _showManageItems(context, type, items, val, onDone),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withAlpha(100)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: Text(val, style: GoogleFonts.nunito())),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(c).size.height * 0.7,
          child: Column(
            children: [
              Text('Select $type',
                  style: GoogleFonts.nunito(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: currentItems.length,
                  itemBuilder: (c, i) {
                    final item = currentItems[i];
                    return ListTile(
                      title: Text(item,
                          style: GoogleFonts.nunito(
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
              borderRadius: BorderRadius.circular(16),
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
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 12, color: Colors.white)),
              )),
        ]),
      ),
    );
  }
}
