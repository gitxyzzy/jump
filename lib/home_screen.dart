import 'package:flutter/material.dart';

import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen([this.points]);

  final int? points;

  static MaterialPageRoute route([int? points]) => MaterialPageRoute(
        builder: (_) => HomeScreen(points),
      );

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _playFocusNode = FocusNode();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1)).then((_) {
      _playFocusNode.requestFocus();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _playFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.points ?? 'Jump'}',
              style: Theme.of(context).textTheme.headline1,
            ),
            TextButton(
              focusNode: _playFocusNode,
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                GameScreen.route(),
                (_) => false,
              ),
              child: Text(widget.points != null ? 'Play Again' : 'Play'),
            ),
          ],
        ),
      ),
    );
  }
}
