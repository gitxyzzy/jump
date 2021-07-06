import 'dart:ui';

import 'package:flutter/material.dart';

import 'box_path.dart';

class RotBox extends BoxPath {
  RotBox({
    required Offset center,
    required double angle,
    this.color = Colors.blue,
    required double width,
  }) : super(
          angle: angle,
          center: center,
          radius: 10,
          roundedCorners: {...RoundCorner.values},
          size: Size(width, width),
        );

  final Color color;
}

class DodgeBox extends BoxPath {
  DodgeBox({
    required Size size,
    required Offset center,
    required Set<RoundCorner> roundedCorners,
    this.color = Colors.brown,
    required this.isHanging,
  }) : super(
          angle: 0,
          center: center,
          radius: 3,
          roundedCorners: roundedCorners,
          size: size,
        );

  factory DodgeBox.zero({
    required Offset center,
    required double height,
    required bool isHanging,
  }) {
    return DodgeBox(
      size: Size(0, height),
      center: center,
      roundedCorners: const {},
      isHanging: isHanging,
    );
  }

  final Color color;
  final bool isHanging;

  DodgeBox copyWith({
    double? width,
    double? height,
    Offset? center,
    Set<RoundCorner>? roundedCorners,
    Color? color,
    bool? isHanging,
  }) {
    return DodgeBox(
      size: Size(width ?? size.width, height ?? size.height),
      center: center ?? this.center,
      roundedCorners: roundedCorners ?? this.roundedCorners,
      color: color ?? this.color,
      isHanging: isHanging ?? this.isHanging,
    );
  }
}
