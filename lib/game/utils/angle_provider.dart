import 'dart:math';

const kOneDeg = pi / 180;

class AngleProvider {
  AngleProvider({
    required double initialAngle,
    required bool clockwise,
    required this.dampFactor,
    required this.changeDirectionDelta,
  })   : _angle = initialAngle,
        _clockwise = clockwise;

  double _angle;
  bool _clockwise;
  final double dampFactor;
  final double changeDirectionDelta;

  double _delta = 0;

  double get angle => _angle;

  void changeDirection() {
    _delta = changeDirectionDelta;
    _clockwise = !_clockwise;
  }

  double tick() {
    final change = kOneDeg + _delta;
    _angle += _clockwise ? change : -change;
    _delta /= dampFactor;
    return _angle;
  }
}
