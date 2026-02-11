
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  HomeHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    return Column(

      children: [
        /// 👇 Show blur ONLY when overlapping (scroll started)
        if (overlapsContent)
          Container(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     theme.colorScheme.primary.withValues(alpha: 0.15),
              //     theme.colorScheme.surface.withValues(alpha: 0.15),
              //   ],
              // ),
              color: theme.colorScheme.surface.withValues(alpha: 0.15),
            ),
          ),

        /// Always show header content
        child,
      ],
    );
  }

  @override
  bool shouldRebuild(HomeHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
  }
}
