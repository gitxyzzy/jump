import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';

enum RoundCorner { tl, tr, bl, br }

class BoxPath extends Equatable {
  BoxPath({
    required this.size,
    required this.center,
    required this.angle,
    required this.roundedCorners,
    required double radius,
  }) {
    final w = size.width;
    final h = size.height;

    final shift = Offset(w / 2, h / 2);

    final tl = const Offset(0, 0) - shift;
    final tr = Offset(w, 0) - shift;
    final bl = Offset(0, h) - shift;
    final br = Offset(w, h) - shift;

    final r = this.radius = min(min(w / 2, h / 2), radius);

    void _addSharpCorner(Offset o) {
      final ro = _transform(o);
      _pathPoints.add([ro, ro]);
      _points.add(ro);
    }

    if (roundedCorners.contains(RoundCorner.tl)) {
      _pathPoints.add([
        _transform(Offset(tl.dx, tl.dy + r)),
        _transform(Offset(tl.dx + r, tl.dy)),
      ]);
      _points.add(_transform(tl));
    } else {
      _addSharpCorner(tl);
    }

    if (roundedCorners.contains(RoundCorner.tr)) {
      _pathPoints.add([
        _transform(Offset(tr.dx - r, tr.dy)),
        _transform(Offset(tr.dx, tr.dy + r)),
      ]);
      _points.add(_transform(tr));
    } else {
      _addSharpCorner(tr);
    }

    if (roundedCorners.contains(RoundCorner.br)) {
      _pathPoints.add([
        _transform(Offset(br.dx, br.dy - r)),
        _transform(Offset(br.dx - r, br.dy))
      ]);
      _points.add(_transform(br));
    } else {
      _addSharpCorner(br);
    }

    if (roundedCorners.contains(RoundCorner.bl)) {
      _pathPoints.add([
        _transform(Offset(bl.dx + r, bl.dy)),
        _transform(Offset(bl.dx, bl.dy - r))
      ]);
      _points.add(_transform(bl));
    } else {
      _addSharpCorner(bl);
    }
  }

  final Size size;
  final Offset center;
  final double angle;
  final Set<RoundCorner> roundedCorners;
  late final double radius;

  final _points = <Offset>[];
  final _pathPoints = <List<Offset>>[];

  @override
  List<Object> get props => [size, center, angle, roundedCorners, radius];

  Path get path {
    final firstPt = _pathPoints[0].first;

    final path = Path()..moveTo(firstPt.dx, firstPt.dy);

    for (var i = 0; i < _pathPoints.length; ++i) {
      final pt1 = _pathPoints[i].first;
      final pt2 = _pathPoints[i].last;

      path
        ..lineTo(pt1.dx, pt1.dy)
        ..arcToPoint(pt2, clockwise: true, radius: Radius.circular(radius));
    }

    return path..lineTo(firstPt.dx, firstPt.dy);
  }

  late final Offset leftMostPt = _points.fold(
    const Offset(double.infinity, 0),
    (p, o) => p.dx < o.dx ? p : o,
  );

  late final Offset rightMostPt = _points.fold(
    const Offset(double.negativeInfinity, 0),
    (p, o) => p.dx > o.dx ? p : o,
  );

  late final Offset topMostPt = _points.fold(
    const Offset(0, double.infinity),
    (p, o) => p.dy < o.dy ? p : o,
  );

  late final Offset bottomMostPt = _points.fold(
    const Offset(0, double.negativeInfinity),
    (p, o) => p.dy > o.dy ? p : o,
  );

  late final double _cos = cos(angle);
  late final double _sin = sin(angle);

  Offset _transform(Offset pt) {
    return Offset(
          pt.dx * _cos - pt.dy * _sin,
          pt.dx * _sin + pt.dy * _cos,
        ) +
        center;
  }
}
