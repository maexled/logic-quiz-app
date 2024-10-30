import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/models/question.dart';
import 'package:formal_logic_quiz_app/models/quiz.dart';
import 'package:formal_logic_quiz_app/ui/screens/quiz_screen.dart';
import 'package:formal_logic_quiz_app/ui/widgets/quiz/quiz_task.dart';

/// A testing utility which creates a [ProviderContainer] and automatically
/// disposes it at the end of the test.
/// Source: https://riverpod.dev/de/docs/essentials/testing#mocking-providers
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  // Create a ProviderContainer, and optionally allow specifying parameters.
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );

  // When the test ends, dispose the container.
  addTearDown(container.dispose);

  return container;
}

void main() {
  group('QuizScreen tests', () {
    Quiz testQuiz = Quiz.loadDummyQuiz();
    testWidgets('QuizScreen loads questions correctly',
        (WidgetTester tester) async {
      final container = createContainer(
        overrides: [
          loadingQuizProvider.overrideWith((ref) => testQuiz),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loadingQuizProvider.overrideWith((ref) => testQuiz),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: QuizScreen(),
            ),
          ),
        ),
      );

      expect(find.byType(QuizTask), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);

      final loadingQuiz = container.read(loadingQuizProvider);
      loadingQuiz.when(
        data: (quiz) {
          expect(quiz.questions.length, testQuiz.questions.length);
        },
        loading: () {
          fail('loadingQuizProvider should have loaded the quiz');
        },
        error: (error, stackTrace) {
          fail('loadingQuizProvider should not have errored');
        },
      );
      Quiz quiz = loadingQuiz.asData!.value;
      expect(quiz.currentQuestionIndex, 0);
      Question currentQuestion = quiz.currentQuestion;
      for (String answer in currentQuestion.answers) {
        expect(find.text(answer), findsOneWidget);
      }
      expect(currentQuestion.isAnswered, false);
      expect(find.text("Next Question"), findsNothing);

      expect(find.text(currentQuestion.correctAnswer), findsOneWidget);
      await tester.tap(find.text(currentQuestion.correctAnswer));
      await tester.pumpAndSettle();

      expect(currentQuestion.isAnswered, true);
      expect(currentQuestion.givenAnswer!, currentQuestion.correctAnswer);
    });
  });
}
