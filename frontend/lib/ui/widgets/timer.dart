import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0);

  StreamSubscription<int>? _subscription;
  int lastPauseTime = 0;

  void _startTimer() {
    final stream = Stream<int>.periodic(
        const Duration(milliseconds: 100), (count) => count);
    _subscription = stream.listen((event) {
      state = event;
    });
  }

  void resetTimer() {
    _subscription?.cancel();
    state = 0;
    lastPauseTime = 0;
    _startTimer();
  }

  void pause() {
    _subscription?.pause();
    lastPauseTime = state;
  }

  void resume() {
    _subscription?.resume();
  }

  int getLastPauseTime() {
    return lastPauseTime;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final totalCentiseconds = state;
    final minutes = (totalCentiseconds ~/ 600).toString();
    final seconds =
        ((totalCentiseconds % 600) ~/ 10).toString().padLeft(2, '0');
    final centiseconds = (totalCentiseconds % 10).toString();
    return "$minutes:$seconds.$centiseconds";
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, int>((ref) {
  return TimerNotifier();
});

class QuizTimer extends ConsumerWidget {
  const QuizTimer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(timerProvider);
    final formattedTime = ref.read(timerProvider.notifier).formattedTime;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color color = colorScheme.primary;

    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer),
        Text(
          formattedTime,
          style: TextStyle(fontSize: 20, color: color),
        ),
      ],
    ));
  }
}
