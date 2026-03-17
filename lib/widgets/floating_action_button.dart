import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingActionBar extends StatelessWidget {
  final VoidCallback onSettle;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const FloatingActionBar({
    super.key,
    required this.onSettle,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔵 Settle Balance Pill Button
          _glassContainer(
            color: Colors.greenAccent,
            child: InkWell(
              onTap: onSettle,
              borderRadius: BorderRadius.circular(40),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      color: Colors.greenAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Settle Balance",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 11),

          // 🔴 Minus Button
          _circleButton(
            icon: Icons.remove,
            color: Colors.redAccent,
            onTap: onMinus,
          ),

          const SizedBox(width: 11),

          // 🟢 Plus Button
          _circleButton(
            icon: Icons.add,
            color: Colors.greenAccent,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }

  // Glassmorphism container
  Widget _glassContainer({
    required Widget child,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        height: 65,
        width: 215,
        decoration: BoxDecoration(
            // color: AppColors.accentGreen.withOpacity(0.06),
          borderRadius: BorderRadius.circular(40),
            // border: Border.all(
            //   color: AppColors.accentGreen.withOpacity(0.15),
            // ),
            color: color.withValues(alpha: 0.15),

          border: Border.all(
            color: color.withValues(alpha: 0.5),
          ),
        ),
        child: child,
      ),
      ),
    );
  }

  // Circular glass button
  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.5),
            ),
          ),
          child: Icon(icon, color: color),
        ),
      ),
      ),
    );
  }
}
