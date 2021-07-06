class HeightProvider {
  HeightProvider({
    required double initialHeight,
    required this.acceleration,
    required this.jumpVel,
  })   : _h0 = initialHeight,
        _height = initialHeight;

  final double acceleration;
  final double jumpVel;

  double _h0;
  double _height;
  int _t = 0;

  double get height => _height;

  void jump() {
    _h0 = _height;
    _t = 0;
  }

  double tick() {
    _t++;
    _height = _h0 + jumpVel * _t - acceleration * _t * _t;
    if (_height < 0) {
      _height = 0;
    }
    return height;
  }
}
