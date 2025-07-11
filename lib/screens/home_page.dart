import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/transaction.dart';
import '../models/person_transaction.dart';
import '../providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/person_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/balance_card.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double _currentBalance = 0;
  late AnimationController _fabController;
  late Animation<double> _fabScale;
  late AnimationController _fabVisibilityController;
  late ScrollController _scrollController;
  bool _showFab = true;

  // Add search state
  String? _searchQuery;
  List<Transaction>? _filteredTransactions;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    
    // New FAB visibility animation controller
    _fabVisibilityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scrollController = ScrollController();
    
    // Optimized scroll listener with debouncing
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      
      final atTop = _scrollController.position.pixels <= 0;
      final txns = context.read<TransactionProvider>().transactions;
      final isEmpty = txns.isEmpty;
      final shouldShowFab = atTop || isEmpty;
      
      // Only update state if there's an actual change
      if (shouldShowFab != _showFab) {
        setState(() => _showFab = shouldShowFab);
      }
    });
    
    _currentBalance; // ✅ Load from Hive
  }

  @override
  void dispose() {
    _fabController.dispose();
    _fabVisibilityController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void balance() {
    final box = Hive.box<double>('_currentBalance');
    setState(() {
      _currentBalance = box.get('_currentBalance', defaultValue: 0.0)!;
    });
  }

  void onBalanceUpdate(double newBalance) {
    final box = Hive.box<double>('_currentBalance');
    box.put('_currentBalance', newBalance); // ✅ Save to Hive
    setState(() {
      _currentBalance = newBalance;
    });
  }

  Future<void> _handleRefresh() async {
    Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    // Optionally, you can also reload balance or other data here
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final useAdaptive = context.watch<AppThemeProvider>().useAdaptiveColor;
    final transactionProvider = context.watch<TransactionProvider>();
    final txns = _filteredTransactions ?? transactionProvider.sortedTransactions;
    final balance = transactionProvider.totalBalance;
    final grouped = _groupTransactionsByDate(txns);
    final hasTransactions = txns.isNotEmpty;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        showChildOpacityTransition: false,
        color: theme.colorScheme.primary,
        backgroundColor: theme.scaffoldBackgroundColor,
        animSpeedFactor: 2.0,
        child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar with Glass Effect
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            elevation: 1,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Aspends Tracker",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              background: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: useAdaptive
                          ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                              colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                            )
                          : isDark
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.teal.shade900.withOpacity(0.8), Colors.teal.shade700.withOpacity(0.8)],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.teal.shade100.withOpacity(0.8), Colors.teal.shade200.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                    _showAnalyticsDialog(context);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showSearchDialog(context);
                },
              ),
            ],
          ),
          // Balance Card and Header
          SliverToBoxAdapter(
            child: Column(
              children: [
                BalanceCard(
                  balance: balance,
                  onBalanceUpdate: (newBalance) async {
                    final box = Hive.box<double>('balanceBox');
                    await box.put('startingBalance', newBalance);
                    Provider.of<TransactionProvider>(context, listen: false)
                        .updateBalance(newBalance);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Colors.teal.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Recent Transactions",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Transaction List
          if (hasTransactions)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  String dateKey = grouped.entries.elementAt(index).key;
                  List<Transaction> dayTxs = grouped[dateKey]!;
                  List<Transaction> dayIncomes = dayTxs.where((t) => t.isIncome).toList();
                  List<Transaction> dayExpenses = dayTxs.where((t) => !t.isIncome).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Combined Date and Transaction Type Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            // Date Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: useAdaptive ? theme.colorScheme.primary.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: useAdaptive ? theme.colorScheme.primary.withOpacity(0.3) : Colors.teal.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                dateKey,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                    color: useAdaptive ? theme.colorScheme.primary : Colors.teal.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Income Badge
                            if (dayIncomes.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_up, color: Colors.green, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Income",
                                      style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 6),
                            // Expense Badge
                            if (dayExpenses.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_down, color: Colors.red, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Expenses",
                                      style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      ...dayIncomes.map((tx) => TransactionTile(transaction: tx, index: index)).toList(),
                      ...dayExpenses.map((tx) => TransactionTile(transaction: tx, index: index)).toList(),
                      const SizedBox(height: 12),
                    ],
                  );
                },
                childCount: grouped.length,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No Transactions Yet",
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add your first transaction to get started",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          // Bottom padding for better readability
          SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom + 70),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Glass Effect Container for FABs
                  Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Income FAB
                                ScaleTransition(
                                  scale: _fabScale,
                                  child: ZoomTapAnimation(
                                    onTap: () {
                                      _fabController.forward().then((_) => _fabController.reverse());
                                      _showAddTransactionDialog(context, isIncome: true);
                                      HapticFeedback.heavyImpact();
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.green, Colors.green.shade600],
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Expense FAB
                                ScaleTransition(
                                  scale: _fabScale,
                                  child: ZoomTapAnimation(
                                    onTap: () {
                                      _fabController.forward().then((_) => _fabController.reverse());
                                      _showAddTransactionDialog(context, isIncome: false);
                                      HapticFeedback.heavyImpact();
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.red, Colors.red.shade600],
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 28,
                                      ),
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
                ],
              ),
            ),
      ),
    );
  }

  // Helper to group transactions by date for filtered results
  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> txns) {
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in txns) {
      final dateKey = "${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    return grouped;
  }

  void _showSearchDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<AppThemeProvider>(context, listen: false).isDarkMode;
    final searchController = TextEditingController(text: _searchQuery ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.dialogBackgroundColor,
        title: Row(
          children: [
            Icon(Icons.search, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
          "Search Transactions",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
              ),
          ),
          ],
        ),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Enter transaction note, category, or account...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Search"),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              final query = searchController.text.trim().toLowerCase();
              if (query.isEmpty) {
                setState(() {
                  _searchQuery = null;
                  _filteredTransactions = null;
                });
                Navigator.pop(context);
                return;
              }
              final allTxns = Provider.of<TransactionProvider>(context, listen: false).sortedTransactions;
              final filtered = allTxns.where((tx) =>
                tx.note.toLowerCase().contains(query) ||
                tx.category.toLowerCase().contains(query) ||
                tx.account.toLowerCase().contains(query)
              ).toList();
              setState(() {
                _searchQuery = query;
                _filteredTransactions = filtered;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(filtered.isEmpty ? "No transactions found." : "Showing results for '$query'"),
                  backgroundColor: filtered.isEmpty ? Colors.red : Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          if (_searchQuery != null && _searchQuery!.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = null;
                  _filteredTransactions = null;
                });
                Navigator.pop(context);
              },
              child: Text("Clear Search", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, {required bool isIncome}) {
    final _formKey = GlobalKey<FormState>();
    final _amountController = TextEditingController();
    final _noteController = TextEditingController();
    String _category = isIncome ? "Salary" : "Food";
    String _account = "Cash";
    bool _isIncome = isIncome;
    final theme = Theme.of(context);
    final isDark = Provider.of<AppThemeProvider>(context, listen: false).isDarkMode;

    // Predefined categories
    final List<String> incomeCategories = [
      "Salary", "Freelance", "Investment", "Gift", "Refund", "Other"
    ];
    final List<String> expenseCategories = [
      "Food", "Transport", "Shopping", "Bills", "Entertainment", "Health", "Education", "Other"
    ];
    final List<String> accounts = ["Cash", "Bank", "Credit Card", "Digital Wallet"];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Add Transaction",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: theme.dialogBackgroundColor,
              title: Row(
                children: [
                  Icon(
                    isIncome ? Icons.add_circle : Icons.remove_circle,
                    color: isIncome ? Colors.green : Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isIncome ? "Add Income" : "Add Expense",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: _formKey,
                child: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Amount Field
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: "Amount",
                            prefixText: "₹ ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.isEmpty
                              ? "Enter amount"
                              : null,
                        ),
                        const SizedBox(height: 16),
                        
                        // Note Field
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: "Note (Optional)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: InputDecoration(
                            labelText: "Category",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          items: (isIncome ? incomeCategories : expenseCategories)
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            _category = val!;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Account Dropdown
                        DropdownButtonFormField<String>(
                          value: _account,
                          decoration: InputDecoration(
                            labelText: "Account",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          items: accounts
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            _account = val!;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(isIncome ? Icons.add : Icons.remove),
                  label: Text(isIncome ? "Add Income" : "Add Expense"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIncome ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (_formKey.currentState!.validate()) {
                      final tx = Transaction(
                        amount: double.parse(_amountController.text),
                        note: _noteController.text,
                        category: _category,
                        account: _account,
                        date: DateTime.now(),
                        isIncome: _isIncome,
                      );
                      Provider.of<TransactionProvider>(context, listen: false)
                          .addTransaction(tx);
                      
                      // Check for person names in the note and add person transactions
                      _checkAndAddPersonTransactions(tx);
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isIncome ? "Income added successfully!" : "Expense added successfully!",
                          ),
                          backgroundColor: isIncome ? Colors.green : Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkAndAddPersonTransactions(Transaction tx) {
    // Get all people from the person provider
    final personProvider = Provider.of<PersonProvider>(context, listen: false);
    final people = personProvider.people;
    
    // Check if any person name appears in the transaction note
    for (final person in people) {
      final personName = person.name.toLowerCase();
      final note = tx.note.toLowerCase();
      
      // Check if person name is mentioned in the note
      if (note.contains(personName)) {
        // Create a person transaction
        final personTx = PersonTransaction(
          personName: person.name,
          amount: tx.amount,
          note: tx.note,
          date: tx.date,
          isIncome: tx.isIncome,
        );
        
        // Add the person transaction
        personProvider.addTransaction(personTx);
        
        // Show a subtle notification that person transaction was added
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Transaction also added to ${person.name}'s record",
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showAnalyticsDialog(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final totalIncome = transactionProvider.totalIncome;
    final totalSpend = transactionProvider.totalSpend;
    final count = transactionProvider.transactions.length;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.dialogBackgroundColor,
        title: Row(
          children: [
            Icon(Icons.analytics, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text("Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Transactions: $count", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Total Income: ₹${totalIncome.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.green)),
            const SizedBox(height: 8),
            Text("Total Expenses: ₹${totalSpend.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}
