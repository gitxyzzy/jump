import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/game_controller.dart';
import 'home_screen.dart';

class GameScreen extends StatelessWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (_) => GameScreen(),
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final vi = mq.viewInsets;
    final width = mq.size.width - vi.left - vi.right;
    final height = mq.size.height - vi.top - vi.bottom;
    final playAreaSize = Size(width, height);

    return Scaffold(
      body: PlayArea(playAreaSize),
    );
  }
}

class PlayArea extends StatefulWidget {
  const PlayArea(this.playAreaSize);

  final Size playAreaSize;

  @override
  _PlayAreaState createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> {
  final _keyboardFocusNode = FocusNode();
  late final GameController _gameController;

  @override
  void initState() {
    _gameController = GameController(
      playAreaSize: widget.playAreaSize,
    )..addListener(() => setState(() {
          Future.delayed(Duration.zero).then((_) {
            if (_gameController.isGameOver) {
              Navigator.of(context).pushAndRemoveUntil(
                HomeScreen.route(_gameController.points),
                (_) => false,
              );
            }
          });
        }));

    _keyboardFocusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _gameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKey: (e) {
        if (e.isKeyPressed(LogicalKeyboardKey.space)) {
          _gameController.tapAction();
        }
      },
      child: GestureDetector(
        onTap: _gameController.tapAction,
        child: CustomPaint(
          size: widget.playAreaSize,
          painter: GamePainter(
            rotBox: _gameController.rotBox,
            dodgeBoxes: _gameController.dodgeBoxes,
            points: _gameController.points,
          ),
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  GamePainter({
    required this.rotBox,
    required this.dodgeBoxes,
    required this.points,
  });

  final RotBox rotBox;
  final List<DodgeBox> dodgeBoxes;
  final int points;

  @override
  void paint(Canvas canvas, Size size) {
    final rotPaint = Paint()..color = rotBox.color;
    canvas.drawPath(rotBox.path, rotPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$points',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final l = rotBox.size.width;
    final lhalf = l / 2;

    final textOffset = Offset(
          (l - textPainter.width) / 2,
          (l - textPainter.height) / 2,
        ) +
        Offset(-lhalf, -lhalf) +
        rotBox.center;

    textPainter.paint(canvas, textOffset);

    for (final box in dodgeBoxes) {
      canvas.drawPath(box.path, Paint()..color = box.color);
    }
  }

  @override
  bool shouldRepaint(GamePainter old) {
    return old.points != points || old.rotBox != rotBox;
  }
}
