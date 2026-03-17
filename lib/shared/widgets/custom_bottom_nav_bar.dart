import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isDark;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBNBItem(context, Icons.home, 0, 'Home'),
        _buildBNBItem(context, Icons.group, 1, 'People'),
        _buildBNBItem(context, Icons.auto_graph, 2, 'Charts'),
        _buildBNBItem(context, Icons.settings_outlined, 3, 'Settings'),
      ],
    );
  }

  Widget _buildBNBItem(
      BuildContext context, IconData icon, int index, String label) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    return AnimatedContainer(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ZoomTapAnimation(
        onTap: () => onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.4)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 0.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
