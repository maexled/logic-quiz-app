import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/models/question.dart';
import 'package:formal_logic_quiz_app/models/quiz.dart';
import 'package:formal_logic_quiz_app/ui/screens/quiz_screen.dart';
import 'package:formal_logic_quiz_app/ui/widgets/error_message_box.dart';
import 'package:formal_logic_quiz_app/ui/widgets/loading_spinner.dart';
import 'package:formal_logic_quiz_app/ui/widgets/timer.dart';

class QuizTask extends ConsumerWidget {
  const QuizTask({
    super.key,
  });

  Function()? onAnswerPressed(Quiz quiz, String answer, WidgetRef ref) {
    if (quiz.currentQuestion.isAnswered) {
      return null;
    }
    return () {
      final timer = ref.read(timerProvider.notifier);
      ref.read(selectedAnswerProvider.notifier).state = answer;
      int timeSpentForQuestionCentiseconds =
          timer.state - timer.getLastPauseTime();
      quiz.answerCurrentQuestion(answer, timeSpentForQuestionCentiseconds);
      timer.pause();
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingQuiz = ref.watch(loadingQuizProvider);
    if (loadingQuiz.isLoading) {
      return const LoadingSpinner();
    } else if (loadingQuiz.hasError) {
      return ErrorMessageBox(
          message: "Error loading quiz: ${loadingQuiz.error}");
    }
    final quiz = loadingQuiz.asData!.value;
    Question currentQuestion = quiz.currentQuestion;

    List<String> currentAnswers = quiz.currentQuestion.getAnswers();

    final selectedAnswer = ref.watch(selectedAnswerProvider);

    List<Widget> answers = [];
    for (String answer in currentAnswers) {
      answers.add(
        ElevatedButton(
          onPressed: onAnswerPressed(quiz, answer, ref),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(400, 80),
            side: BorderSide(
              color: selectedAnswer == answer
                  ? (currentQuestion.isCorrect(selectedAnswer!)
                      ? Colors.green
                      : Colors.red)
                  : currentQuestion.isCorrect(answer) &&
                          currentQuestion.isAnswered
                      ? Colors.green
                      : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: Text(answer),
        ),
      );
      answers.add(const SizedBox(height: 10));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Question ${quiz.currentQuestionIndex + 1} of ${quiz.questions.length}",
              style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 176, 176, 176)),
            ),
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            for (Widget answer in answers) answer
          ],
        ),
      ),
    );
  }
}
