import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'utils/utils.dart';

export 'utils/game_boxes.dart';

class GameController
    with AnimationLocalListenersMixin, AnimationLazyListenerMixin {
  GameController({required this.playAreaSize}) {
    _angleProvider = AngleProvider(
      initialAngle: 0,
      clockwise: true,
      dampFactor: 1.2,
      changeDirectionDelta: 20 * kOneDeg,
    );

    _heightProvider = HeightProvider(
      initialHeight: playAreaSize.height / 2,
      acceleration: 0.3,
      jumpVel: playAreaSize.height / 60,
    );

    _dodgeGenerator = DodgeGenerator(
      playAreaSize: playAreaSize,
      separation: 400,
      initialVel: playAreaSize.width / 100,
      velDelta: playAreaSize.width / 1100,
      onDiscardDodge: _increasePoints,
    );

    _timerManager = TimerManager(const Duration(milliseconds: 20), _tick);
  }

  final Size playAreaSize;
  final increaseVelForPts = 5;

  late final AngleProvider _angleProvider;
  late final HeightProvider _heightProvider;
  late final DodgeGenerator _dodgeGenerator;
  late final TimerManager _timerManager;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;
  set isGameOver(bool v) {
    if (v == _isGameOver) {
      return;
    }

    _isGameOver = v;
    if (v) {
      _timerManager.pause();
    } else {
      _timerManager.resume();
    }
  }

  int _points = 0;
  int get points => _points;

  late double rotBoxWidth = max(playAreaSize.height / 13, 40);

  void _increasePoints() {
    _points++;
    if (_points % increaseVelForPts == 0 &&
        _dodgeGenerator.vel < _dodgeGenerator.initialVel * 1.7) {
      _dodgeGenerator.increaseVel();
    }
  }

  void tapAction() {
    _angleProvider.changeDirection();
    _heightProvider.jump();
  }

  void _tick(int tick) {
    _angleProvider.tick();
    _heightProvider.tick();
    _dodgeGenerator.tick();
    notifyListeners();
  }

  late RotBox rotBox = _getRotBox();

  late List<DodgeBox> dodgeBoxes = _getDodgeBoxes();

  @override
  void notifyListeners() {
    rotBox = _getRotBox();
    dodgeBoxes = _getDodgeBoxes();
    _checkGameOver();
    super.notifyListeners();
  }

  void _checkGameOver() {
    isGameOver = !_isRotBoxInPlayArea() || _didRotBoxCollide();
  }

  bool _isRotBoxInPlayArea() {
    return rotBox.isBetweenY(0, playAreaSize.height);
  }

  bool _didRotBoxCollide() {
    for (final db in dodgeBoxes) {
      if (_doesCollideWith(db)) {
        return true;
      }
    }
    return false;
  }

  bool _doesCollideWith(DodgeBox db) {
    if (rotBox.hasX(db.leftMostPt.dx) ||
        rotBox.hasX(db.rightMostPt.dx) ||
        rotBox.isBetweenX(db.leftMostPt.dx, db.rightMostPt.dx)) {
      if (db.isHanging) {
        if (db.bottomMostPt.dy < rotBox.topMostPt.dy) {
          return false;
        } else if (db.hasX(rotBox.rightMostPt.dx)) {
          return rotBox.topToRightLine.areOnSameSide(playAreaSize.bl, db.bl);
        } else {
          return rotBox.topToLeftLine.areOnSameSide(playAreaSize.br, db.br);
        }
      } else {
        if (db.topMostPt.dy > rotBox.bottomMostPt.dy) {
          return false;
        } else if (db.hasX(rotBox.rightMostPt.dx)) {
          return rotBox.bottomToRightLine.areOnSameSide(playAreaSize.tl, db.tl);
        } else {
          return rotBox.bottomToLeftLine.areOnSameSide(playAreaSize.tr, db.tr);
        }
      }
    }
    return false;
  }

  void dispose() {
    _timerManager.pause();
  }

  @override
  void didStartListening() {
    _timerManager.resume();
  }

  @override
  void didStopListening() {
    _timerManager.pause();
  }

  RotBox _getRotBox() {
    return RotBox(
      angle: _angleProvider.angle,
      center: Offset(
        (rotBoxWidth / 2) + playAreaSize.width * 0.1,
        playAreaSize.height - _heightProvider.height,
      ),
      width: rotBoxWidth,
    );
  }

  List<DodgeBox> _getDodgeBoxes() {
    return _dodgeGenerator.boxes;
  }
}

extension on RotBox {
  bool isBetweenY(double top, double bottom) =>
      top < topMostPt.dy && bottomMostPt.dy < bottom;

  bool isBetweenX(double left, double right) =>
      left < leftMostPt.dx && rightMostPt.dx < right;

  bool hasX(double x) => leftMostPt.dx < x && x < rightMostPt.dx;

  Line get topToLeftLine => Line(topMostPt, leftMostPt);

  Line get topToRightLine => Line(topMostPt, rightMostPt);

  Line get bottomToLeftLine => Line(bottomMostPt, leftMostPt);

  Line get bottomToRightLine => Line(bottomMostPt, rightMostPt);
}

extension on DodgeBox {
  bool hasX(double x) => leftMostPt.dx < x && x < rightMostPt.dx;

  Offset get tl => Offset(leftMostPt.dx, topMostPt.dy);

  Offset get bl => Offset(leftMostPt.dx, bottomMostPt.dy);

  Offset get tr => Offset(rightMostPt.dx, topMostPt.dy);

  Offset get br => Offset(rightMostPt.dx, bottomMostPt.dy);
}

extension on Size {
  Offset get tl => Offset.zero;

  Offset get tr => Offset(width, 0);

  Offset get bl => Offset(0, height);

  Offset get br => Offset(width, height);
}
