import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/view_models/liquid_navbar_view_model.dart';

class NativeGlassNavBarItem {
  final String label;
  final String symbol;

  const NativeGlassNavBarItem({required this.label, required this.symbol});
}

class TabBarActionButton {
  final String symbol;
  final VoidCallback onTap;

  const TabBarActionButton({required this.symbol, required this.onTap});
}

class NativeGlassNavBar extends StatefulWidget {
  final List<NativeGlassNavBarItem> tabs;
  final TabBarActionButton? actionButton;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? tintColor;

  const NativeGlassNavBar({
    super.key,
    required this.tabs,
    this.actionButton,
    required this.currentIndex,
    required this.onTap,
    this.tintColor,
  });

  @override
  State<NativeGlassNavBar> createState() => _NativeGlassNavBarState();
}

class _NativeGlassNavBarState extends State<NativeGlassNavBar> {
  late List<GlobalKey> _iconKeys;
  final GlobalKey _navBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _iconKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
    
    // Initial measurement after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LiquidNavbarViewModel>().initMeasuredPositions(_iconKeys, _navBarKey.currentContext!);
      }
    });
  }

  @override
  void didUpdateWidget(NativeGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _iconKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<LiquidNavbarViewModel>().initMeasuredPositions(_iconKeys, _navBarKey.currentContext!);
        }
      });
    }
    
    // Sync current index if it changed from outside (and user NOT interacting)
    if (widget.currentIndex != oldWidget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final vm = context.read<LiquidNavbarViewModel>();
          if (!(vm.isDragging || vm.isPressed)) {
            vm.setCurrentIndex(widget.currentIndex);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tintColor = widget.tintColor ?? Theme.of(context).colorScheme.primary;
    final viewModel = context.watch<LiquidNavbarViewModel>();
    
    final bool active = viewModel.isDragging || viewModel.isPressed;
    
    // Bar dimensions
    final double barHeight = active ? 85 : 70;
    final double barWidthBase = ResponsiveUtils.isMobile(context) ? 310 : 350;
    final double barWidth = active ? barWidthBase + 30 : barWidthBase;

    // Indicator Width Calculation
    final double baseIndicatorWidth = ResponsiveUtils.isMobile(context) ? 60 : 75; 
    final double adaptiveIndicatorWidth = baseIndicatorWidth * (3.5 / widget.tabs.length).clamp(1.0, 1.2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0, left: 16, right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Main Navigation Bar Container
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              height: barHeight,
              width: barWidth,
              child: Stack(
                key: _navBarKey,
                alignment: Alignment.center,
                clipBehavior: Clip.none
                ,
                children: [
                  // 1. Glassy Background (Expanding)
                  _BackgroundGlass(
                    active: active,
                    isDark: isDark,
                    navBarKey: _navBarKey,
                    iconKeys: _iconKeys,
                  ),

                  // 2. Liquid Indicator (Visual Only)
                  if (viewModel.positions.isNotEmpty)
                    _LiquidIndicator(
                      position: viewModel.draggablePosition,
                      width: adaptiveIndicatorWidth,
                      tintColor: tintColor,
                      isDragging: viewModel.isDragging,
                      isPressed: viewModel.isPressed,
                      parentBarHeight: barHeight,
                    ),

                  // 3. Foreground Icons & Labels (Distorted when active)
                  _IconsLiquidLayer(
                    tabs: widget.tabs,
                    iconKeys: _iconKeys,
                    active: active,
                    isDark: isDark,
                    position: viewModel.draggablePosition,
                    currentIndex: viewModel.currentIndex,
                    positions: viewModel.positions,
                    barHeight: barHeight,
                  ),

                  // 4. Master Gesture Layer
                  if (viewModel.positions.isNotEmpty)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          viewModel.setIsPressed(true); 
                           HapticFeedback.lightImpact();
                        },
                        onTapUp: (details) {
                          viewModel.setIsPressed(false);
                          final RenderBox box = _navBarKey.currentContext!.findRenderObject() as RenderBox;
                          final localPos = box.globalToLocal(details.globalPosition);
                          _resolveTabTap(localPos, viewModel);
                        },
                        onTapCancel: () => viewModel.setIsPressed(false),
                        onPanStart: (details) {
                          viewModel.setIsDragging(true);
                          viewModel.setIsPressed(true);
                          final RenderBox box = _navBarKey.currentContext!.findRenderObject() as RenderBox;
                          final localPos = box.globalToLocal(details.globalPosition);
                          viewModel.setDraggablePosition(localPos.dx.clamp(0.0, box.size.width));
                        },
                        onPanUpdate: (details) {
                          final RenderBox box = _navBarKey.currentContext!.findRenderObject() as RenderBox;
                          final localPos = box.globalToLocal(details.globalPosition);
                          viewModel.setDraggablePosition(localPos.dx.clamp(0.0, box.size.width));
                        },
                        onPanEnd: (_) {
                          final nearestIndex = viewModel.getNearestIndex();
                          viewModel.setCurrentIndex(nearestIndex);
                          widget.onTap(nearestIndex);
                          viewModel.setIsPressed(false);
                          viewModel.setIsDragging(false);
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Action Button
          if (widget.actionButton != null) ...[
            const SizedBox(width: 12),
            ZoomTapAnimation(
              onTap: widget.actionButton!.onTap,
              child: LiquidGlassLayer(
                settings: const LiquidGlassSettings(thickness: 10, blur: 2),
                child: LiquidGlass(
                  shape: LiquidRoundedSuperellipse(borderRadius: 32),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black26,
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      _getIconData(widget.actionButton!.symbol),
                      color: isDark ? Colors.white : Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _resolveTabTap(Offset localPos, LiquidNavbarViewModel viewModel) {
    double minDict = double.infinity;
    int targetIndex = viewModel.currentIndex;
    for (int i = 0; i < viewModel.positions.length; i++) {
      final dist = (localPos.dx - viewModel.positions[i]).abs();
      if (dist < minDict) {
        minDict = dist;
        targetIndex = i;
      }
    }
    if (targetIndex != viewModel.currentIndex) {
      viewModel.setCurrentIndex(targetIndex);
      widget.onTap(targetIndex);
    }
  }

  IconData _getIconData(String symbol) {
    switch (symbol) {
      case 'house': return Icons.home_rounded;
      case 'person.2': return Icons.group_rounded;
      case 'chart.xyaxis.line': return Icons.auto_graph_rounded;
      case 'gear': return Icons.settings_rounded;
      case 'plus': return Icons.add_rounded;
      default: return Icons.circle;
    }
  }
}

class _IconsLiquidLayer extends StatelessWidget {
  final List<NativeGlassNavBarItem> tabs;
  final List<GlobalKey> iconKeys;
  final bool active;
  final bool isDark;
  final double position;
  final int currentIndex;
  final List<double> positions;
  final double barHeight;

  const _IconsLiquidLayer({
    required this.tabs,
    required this.iconKeys,
    required this.active,
    required this.isDark,
    required this.position,
    required this.currentIndex,
    required this.positions,
    required this.barHeight,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;

          // Localized distortion factor based on distance to the indicator
          double swellFactor = 0.0;
          if (active && index < positions.length) {
            final double distance = (positions[index] - position).abs();
            // Swell within 70px of the indicator center
            swellFactor = (1.0 - (distance / 70)).clamp(0.0, 1.0);
          }

          final Widget iconContent = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconData(item.symbol),
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white38 : Colors.black38),
                size: isSelected ? 24 : 22,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white38 : Colors.black38),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          );

          return Expanded(
            child: Container(
              key: iconKeys[index],
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: active && swellFactor > 0.1
                  ? LiquidGlassLayer(
                      settings: LiquidGlassSettings(
                        lightIntensity: 1.0 + (swellFactor * 2.0),
                        thickness: 10,
                        blur: 0.1,
                      ),
                      child: LiquidStretch(
                        stretch: 0.6 * swellFactor,
                        interactionScale: 1.0 + (0.5 * swellFactor),
                        child: iconContent,
                      ),
                    )
                  : iconContent,
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconData(String symbol) {
    switch (symbol) {
      case 'house': return Icons.home_rounded;
      case 'person.2': return Icons.group_rounded;
      case 'chart.xyaxis.line': return Icons.auto_graph_rounded;
      case 'gear': return Icons.settings_rounded;
      case 'plus': return Icons.add_rounded;
      default: return Icons.circle;
    }
  }
}

class _BackgroundGlass extends StatelessWidget {
  final bool active;
  final bool isDark;
  final GlobalKey navBarKey;
  final List<GlobalKey> iconKeys;

  const _BackgroundGlass({
    required this.active,
    required this.isDark,
    required this.navBarKey,
    required this.iconKeys,
  });

  @override
  Widget build(BuildContext context) {
    final shape = LiquidRoundedSuperellipse(borderRadius: 40);
    final decoration = BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(40),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.08),
        width: 0.8,
      ),
    );

    if (active) {
      return LiquidGlassLayer(
        settings: const LiquidGlassSettings(thickness: 22, blur: 3),
        child: LiquidGlass(
          shape: shape,
          child: Container(
            decoration: decoration,
            child: _MeasureHelper(navBarKey: navBarKey, iconKeys: iconKeys),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: decoration,
          child: _MeasureHelper(navBarKey: navBarKey, iconKeys: iconKeys),
        ),
      ),
    );
  }
}

class _MeasureHelper extends StatelessWidget {
  final GlobalKey navBarKey;
  final List<GlobalKey> iconKeys;

  const _MeasureHelper({required this.navBarKey, required this.iconKeys});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final viewModel = context.read<LiquidNavbarViewModel>();
          viewModel.initMeasuredPositions(iconKeys, navBarKey.currentContext!);
        });
        return const SizedBox.expand();
      },
    );
  }
}

class _LiquidIndicator extends StatelessWidget {
  final double position;
  final double width;
  final Color tintColor;
  final bool isDragging;
  final bool isPressed;
  final double parentBarHeight;

  const _LiquidIndicator({
    required this.position,
    required this.width,
    required this.tintColor,
    required this.isDragging,
    required this.isPressed,
    required this.parentBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = isDragging || isPressed;
    
    final double displayWidth = active ? width * 2.0 : width * 1.1; 
    final double displayHeight = active ? parentBarHeight - 12 : 60; 
    
    final Color displayColor = active 
        ? tintColor.withValues(alpha: 0.1) 
        : tintColor.withValues(alpha: 0.2); 

    return AnimatedPositioned(
      duration: isDragging ? Duration.zero : const Duration(milliseconds: 600),
      curve: const ElasticOutCurve(0.6),
      left: position - displayWidth / 2,
      top: (parentBarHeight - displayHeight) / 2,
      width: displayWidth,
      height: displayHeight,
      child: IgnorePointer(
        child: active 
          ? LiquidGlassLayer(
              settings: const LiquidGlassSettings(
                lightIntensity: 4.0,
                thickness: 50,
                blur: 0.2,
              ),
              child: LiquidStretch(
                stretch: 1.0,
                interactionScale: 1.6,
                child: LiquidGlass(
                  glassContainsChild: true,
                  shape: LiquidRoundedSuperellipse(borderRadius: 55),
                  child: GlassGlow(
                    child: Container(
                      decoration: _indicatorDecoration(displayColor, 55),
                    ),
                  ),
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: _indicatorDecoration(displayColor, 30),
                ),
              ),
            ),
      ),
    );
  }

  BoxDecoration _indicatorDecoration(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.25),
        width: 0.8,
      ),
    );
  }
}
