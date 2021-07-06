import 'dart:async';
import 'dart:math';

class TimerManager {
  TimerManager(this.duration, this.onTick);

  final Duration duration;
  final Function(int) onTick;

  Timer? _timer;
  int _tickOrigin = 0;

  int _tick = 0;
  int get tick => _tick;

  void pause() {
    _tickOrigin = max(_tickOrigin, _timer?.tick ?? 0);
    _timer?.cancel();
    _timer = null;
  }

  void resume() {
    _timer ??= Timer.periodic(
      duration,
      (timer) {
        _tick = timer.tick + _tickOrigin;
        onTick(_tick);
      },
    );
  }
}
