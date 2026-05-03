import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔵 Settle Balance Pill Button
          ZoomTapAnimation(
            onTap: onSettle,
            child: GlassCard(
              width: 180,
              height: 56,
              padding: EdgeInsets.zero,
              child: Container(
                color: Colors.greenAccent.withValues(alpha: 0.8),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Settle Balance",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🔴 Minus Button
          ZoomTapAnimation(
            onTap: onMinus,
            child: GlassCard(
              width: 56,
              height: 56,
              padding: EdgeInsets.zero,
              shape: const LiquidOval(),
              child: Container(
                color: Colors.redAccent.withValues(alpha: 0.8),
                child: const Center(
                  child: Icon(Icons.remove_rounded, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🟢 Plus Button
          ZoomTapAnimation(
            onTap: onPlus,
            child: GlassCard(
              width: 56,
              height: 56,
              padding: EdgeInsets.zero,
              shape: const LiquidOval(),
              child: Container(
                color: Colors.greenAccent.withValues(alpha: 0.8),
                child: const Center(
                  child: Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
