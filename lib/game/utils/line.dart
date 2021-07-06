import 'dart:ui';

class Line {
  Line(this.pt1, this.pt2);

  final Offset pt1;
  final Offset pt2;

  bool areOnSameSide(Offset point1, Offset point2) {
    final a = _sameSideEqn(point1);
    final b = _sameSideEqn(point2);
    return a.sign == b.sign;
  }

  double _sameSideEqn(Offset pt) {
    return ((pt2.dy - pt1.dy) * (pt.dx - pt1.dx) / (pt2.dx - pt1.dx)) -
        (pt.dy - pt1.dy);
  }
}
