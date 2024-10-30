import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/ui/widgets/timer.dart';

void main() {
  group('Timer tests', () {
    late TimerNotifier timerNotifier;

    setUp(() {
      timerNotifier = TimerNotifier();
    });

    test('TimerNotifier initializes with 0', () {
      expect(timerNotifier.state, 0);
    });

    test('TimerNotifier resets timer correctly', () async {
      timerNotifier.resetTimer();
      await Future.delayed(const Duration(seconds: 1));
      expect(timerNotifier.state > 0, true);
      timerNotifier.resetTimer();
      expect(timerNotifier.state, 0);
      expect(timerNotifier.lastPauseTime, 0);
    });

    test('TimerNotifier pauses and resumes correctly', () async {
      timerNotifier.resetTimer();
      await Future.delayed(const Duration(milliseconds: 500));
      final pauseTime = timerNotifier.state;
      expect(pauseTime > 0, true);
      timerNotifier.pause();
      await Future.delayed(const Duration(milliseconds: 500));
      expect(timerNotifier.state, pauseTime);

      timerNotifier.resume();
      await Future.delayed(const Duration(seconds: 1));
      expect(timerNotifier.state > pauseTime, true);
      expect(timerNotifier.getLastPauseTime(), pauseTime);
    });

    test('TimerNotifier returns formatted time correctly', () {
      // 123.4 seconds = 2 minutes, 3 seconds, 4 centiseconds
      timerNotifier.state = 1234;
      expect(timerNotifier.formattedTime, '2:03.4');
    });

    testWidgets('QuizTimer widget displays formatted time correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuizTimer(),
            ),
          ),
        ),
      );

      // https://riverpod.dev/docs/essentials/testing#widget-tests
      final element = tester.element(find.byType(QuizTimer));
      final container = ProviderScope.containerOf(element);
      final timerState = container.read(timerProvider.notifier);

      final timeText = find.byType(Text);
      expect(timeText, findsOneWidget);

      timerState.resetTimer();
      await tester.pump(const Duration(seconds: 2));
      final currentTime = timerState.state;
      expect(currentTime > 10, true);
      expect(find.text(timerState.formattedTime), findsOneWidget);

      timerState.pause();
      String timeBeforeResume = timerState.formattedTime;
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(timeBeforeResume), findsOneWidget);

      timerState.resume();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(timeBeforeResume), findsNothing);
      expect(find.text(timerState.formattedTime), findsOneWidget);
    });
  });
}
