import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../view_models/theme_view_model.dart';
import '../view_models/transaction_view_model.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final Function(double) onBalanceUpdate;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.onBalanceUpdate,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

    final transactionViewModel = context.watch<TransactionViewModel>();
    final totalIncome = transactionViewModel.totalIncome;
    final totalExpenses = transactionViewModel.totalSpend;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.lightImpact();
        _showEditBalanceDialog(context, isDark);
      },
      onTap: () {
        HapticFeedback.selectionClick();
        _showBalanceDetails(context, isDark);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                        theme.colorScheme.primary.withValues(alpha: 0.5)
                      ]
                    : [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.5)
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Balance',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.balance)}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showEditBalanceDialog(context, isDark);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernStatItem(
                                'Income',
                                totalIncome,
                                Icons.arrow_downward_rounded,
                                Colors.white,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            Expanded(
                              child: _buildModernStatItem(
                                'Expense',
                                totalExpenses,
                                Icons.arrow_upward_rounded,
                                Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatItem(
      String label, double amount, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color.withValues(alpha: 0.7), size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(amount)}',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showBalanceDetails(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Balance Details',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
              ),
              title: const Text('Tap and hold to edit balance'),
              subtitle:
                  const Text('Long press the balance card on the home screen'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showEditBalanceDialog(BuildContext context, bool isDark) {
    final controller =
        TextEditingController(text: widget.balance.toStringAsFixed(2));
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Balance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'New Balance',
            prefixText: '₹ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBalance = double.tryParse(controller.text);
              if (newBalance != null) {
                widget.onBalanceUpdate(newBalance);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
