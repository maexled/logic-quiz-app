import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/main.dart';
import 'package:formal_logic_quiz_app/models/question.dart';
import 'package:formal_logic_quiz_app/models/quiz.dart';
import 'package:formal_logic_quiz_app/models/quiz_run.dart';
import 'package:formal_logic_quiz_app/services/tasks/task_service.dart';
import 'package:formal_logic_quiz_app/ui/screens/statistics_screen.dart';
import 'package:formal_logic_quiz_app/ui/widgets/error_message_box.dart';
import 'package:formal_logic_quiz_app/ui/widgets/loading_spinner.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';
import 'package:formal_logic_quiz_app/ui/widgets/quiz/quiz_task.dart';
import 'package:formal_logic_quiz_app/ui/widgets/timer.dart';
import 'package:go_router/go_router.dart';

final loadingQuizProvider = FutureProvider<Quiz>((ref) async {
  final quiz = await getQuestions().then((questions) {
    ref.read(selectedAnswerProvider.notifier).state = null;
    ref.read(_finishedProvider.notifier).state = false;
    ref.read(timerProvider.notifier).resetTimer();
    return Quiz(questions: questions);
  });
  return quiz;
});

final selectedAnswerProvider = StateProvider<String?>((ref) => null);

final _finishedProvider = StateProvider<bool>((ref) {
  return false;
});

void startQuiz(WidgetRef ref) {
  ref.invalidate(loadingQuizProvider);
}

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  Function()? onNextQuestionPressed(Quiz quiz, WidgetRef ref) {
    if (!quiz.currentQuestion.isAnswered) {
      return null;
    }
    return () {
      if (!quiz.hasNextQuestion) {
        finishQuiz(ref, quiz);

        return;
      }
      ref.read(selectedAnswerProvider.notifier).state = null;
      quiz.nextQuestion();
      ref.read(timerProvider.notifier).resume();
    };
  }

  void finishQuiz(WidgetRef ref, Quiz quiz) {
    ref.read(selectedAnswerProvider.notifier).state = null;
    ref.read(_finishedProvider.notifier).state = true;
    final timeNeededSeconds = ref.read(timerProvider.notifier).state / 10;
    logger.d("Time needed for quiz: $timeNeededSeconds seconds");
    sendQuizRun(quiz).then((value) {
      logger.d(
          "Quiz run sent, Request success: ${value.$1}, Message: ${value.$2}");
      // Refresh statistics
      ref.invalidate(quizRunProvider);
      ref.invalidate(leaderBoardProvider);
      ref.invalidate(last30DaysStatisticsProvider);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingQuiz = ref.watch(loadingQuizProvider);

    // When an answer gets picked
    ref.watch(selectedAnswerProvider);

    List<Widget> body;

    if (loadingQuiz.isLoading) {
      body = [const LoadingSpinner()];
    } else if (loadingQuiz.hasError) {
      body = [
        ErrorMessageBox(message: "Error loading quiz: ${loadingQuiz.error}"),
      ];
    } else {
      // Has quiz
      final quiz = loadingQuiz.asData!.value;
      final finished = ref.watch(_finishedProvider);
      if (finished) {
        QuizRun quizRun = QuizRun(
            id: -1,
            questions: QuizRunQuestion.listFromQuestions(quiz.questions),
            createdAt: DateTime.now());
        context.pushNamed("quizResultScreen",
            extra: quizRun, queryParameters: {"normalBack": "false"});
      }

      Question currentQuestion = quiz.currentQuestion;
      body = [
        const SizedBox(height: 20),
        const QuizTimer(),
        const SizedBox(height: 20),
        const QuizTask(),
        const SizedBox(height: 20),
        if (currentQuestion.isAnswered)
          ElevatedButton(
            onPressed: onNextQuestionPressed(quiz, ref),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 60),
            ),
            child: quiz.hasNextQuestion
                ? const Text('Next Question')
                : const Text('Finish Quiz'),
          ),
      ];
    }

    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            onLeaveQuizDialog(context);
          },
          child: ListView(children: [
            PageHeader(
              title: "Formal Logic Quiz",
              subtitle:
                  "Test your formal logic skills: NOW IS YOUR TIME TO SHINE!",
              back: true,
              backText: "Leave Quiz",
              onBack: () {
                onLeaveQuizDialog(context);
              },
            ),
            ...body
          ]),
        ),
      ),
    );
  }

  void onLeaveQuizDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('Are you sure you want to leave the quiz?'),
              content: const Text(
                  'You will lose your progress. In the future this might affect your statistics.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // first pop is to close the dialog, second to go to page before the quiz
                    Navigator.pop(context);
                    context.pop();
                  },
                  child: const Text('Leave Quiz'),
                ),
              ],
            ));
  }
}
