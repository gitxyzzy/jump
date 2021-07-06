import 'dart:math';
import 'dart:ui';

import 'box_path.dart';
import 'game_boxes.dart';

class DodgeGenerator {
  DodgeGenerator({
    required this.playAreaSize,
    required double separation,
    required this.initialVel,
    required this.velDelta,
    this.onGenerateDodge,
    this.onDiscardDodge,
  }) : _vel = initialVel {
    final n = playAreaSize.width ~/ separation;
    maxDodges = n <= 0 ? 1 : n;
    this.separation = playAreaSize.width / maxDodges;
  }

  final Size playAreaSize;
  final double initialVel;
  final double velDelta;
  final VoidCallback? onGenerateDodge;
  final VoidCallback? onDiscardDodge;

  late final int maxDodges;
  late final double separation;

  late double _vel;
  double get vel => _vel;

  List<DodgeBox> _boxes = [];
  List<DodgeBox> get boxes => [..._boxes];

  void increaseVel() {
    _vel += velDelta;
  }

  late final double dodgeWidth = max(playAreaSize.width / 30, 40);

  void tick() {
    var maxX = 0.0;
    final newBoxes = <DodgeBox>[];

    for (final db in boxes) {
      final box = _move(db);
      if (box != null) {
        newBoxes.add(box);
        maxX = max(maxX, box.rightMostPt.dx);
      } else {
        onDiscardDodge?.call();
      }
    }

    _boxes = newBoxes;

    if (_boxes.isEmpty ||
        (_boxes.length < maxDodges &&
            (playAreaSize.width - maxX) >= separation)) {
      onGenerateDodge?.call();
      _boxes.add(_randomDodge());
    }
  }

  DodgeBox? _move(DodgeBox db) {
    final center = db.center - Offset(vel, 0);
    if (center.dx < 0) {
      return null;
    }

    final roundedCorners = <RoundCorner>{};

    final reqLeft = center.dx - dodgeWidth / 2;
    late final double left;
    if (reqLeft < 0) {
      left = 0;
    } else {
      left = reqLeft;
      if (db.isHanging) {
        roundedCorners.add(RoundCorner.bl);
      } else {
        roundedCorners.add(RoundCorner.tl);
      }
    }

    final reqRight = center.dx + dodgeWidth / 2;
    late final double right;
    if (reqRight > playAreaSize.width) {
      right = playAreaSize.width;
    } else {
      right = reqRight;
      if (db.isHanging) {
        roundedCorners.add(RoundCorner.br);
      } else {
        roundedCorners.add(RoundCorner.tr);
      }
    }

    return db.copyWith(
      center: center,
      roundedCorners: roundedCorners,
      width: right - left,
    );
  }

  DodgeBox _randomDodge() {
    final offset = _randomOffset();
    final isHanging = _isHanging(offset);

    late final double height;
    late final Offset center;
    if (isHanging) {
      height = offset.dy;
      center = offset - Offset(0, height / 2);
    } else {
      height = playAreaSize.height - offset.dy;
      center = offset + Offset(0, height / 2);
    }

    return DodgeBox.zero(
      center: center,
      height: height,
      isHanging: isHanging,
    );
  }

  final _random = Random();

  Offset _randomOffset() {
    final x = playAreaSize.width;
    final h = playAreaSize.height;
    final y = h * 0.3 + (h * 0.4) * _random.nextDouble();
    return Offset(x, y);
  }

  bool _isHanging(Offset offset) =>
      offset.dy.toInt() < (playAreaSize.height ~/ 2);
}
