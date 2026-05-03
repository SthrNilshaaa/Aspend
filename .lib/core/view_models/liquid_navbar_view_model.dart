import 'package:flutter/material.dart';

class LiquidNavbarViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  double _draggablePosition = 0;
  List<double> _positions = []; // Centers of icons relative to navbar container
  bool _isDragging = false;
  bool _isPressed = false;

  int get currentIndex => _currentIndex;
  double get draggablePosition => _draggablePosition;
  List<double> get positions => _positions;
  bool get isDragging => _isDragging;
  bool get isPressed => _isPressed;

  /// Initialize positions evenly based on container width
  void initEvenPositions(
      {required int itemCount, required double containerWidth}) {
    if (itemCount == 0) return;
    final itemWidth = containerWidth / itemCount;
    _positions = List.generate(
      itemCount,
      (i) => itemWidth * i + itemWidth / 2,
    );

    // Set initial draggable position carefully (only if not currently active)
    if (_currentIndex < _positions.length && !(_isDragging || _isPressed)) {
      _draggablePosition = _positions[_currentIndex];
    }
    notifyListeners();
  }

  /// Initialize positions using actual context-based measurements (GlobalKey)
  /// This version calculates positions RELATIVE to the nav bar container.
  void initMeasuredPositions(
      List<GlobalKey> iconKeys, BuildContext navBarContext) {
    if (iconKeys.isEmpty) return;

    final RenderBox? navBarBox = navBarContext.findRenderObject() as RenderBox?;
    if (navBarBox == null) return;

    final newPositions = iconKeys.map((key) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        // center of the icon in global coordinates
        final globalCenter =
            box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
        // convert to local coordinates of the navbar
        final localCenter = navBarBox.globalToLocal(globalCenter);
        return localCenter.dx;
      }
      return 0.0;
    }).toList();

    _positions = newPositions;

    // Only sync draggable position if we aren't currently moving it!
    if (_currentIndex < _positions.length && !(_isDragging || _isPressed)) {
      _draggablePosition = _positions[_currentIndex];
    }
    notifyListeners();
  }

  void setCurrentIndex(int index, {bool animate = true}) {
    if (index < 0 || index >= _positions.length) return;

    _currentIndex = index;
    _draggablePosition = _positions[index];
    _isDragging =
        false; // Ensure we are NOT dragging when setting index (snapping/tapping)
    notifyListeners();
  }

  void setDraggablePosition(double position) {
    _draggablePosition = position;
    _isDragging = true;
    notifyListeners();
  }

  void setIsDragging(bool dragging) {
    if (_isDragging != dragging) {
      _isDragging = dragging;
      if (!dragging) _isPressed = false; // Reset pressed when drag ends
      notifyListeners();
    }
  }

  void setIsPressed(bool pressed) {
    if (_isPressed != pressed) {
      _isPressed = pressed;
      notifyListeners();
    }
  }

  /// Finds the nearest snap position for the current draggable position
  int getNearestIndex() {
    if (_positions.isEmpty) return _currentIndex;

    double closest = _positions[0];
    double minDist = (_draggablePosition - closest).abs();
    int closestIndex = 0;

    for (int i = 0; i < _positions.length; i++) {
      final dist = (_draggablePosition - _positions[i]).abs();
      if (dist < minDist) {
        minDist = dist;
        closest = _positions[i];
        closestIndex = i;
      }
    }
    return closestIndex;
  }
}
