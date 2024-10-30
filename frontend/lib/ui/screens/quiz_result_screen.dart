import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/models/quiz_run.dart';
import 'package:formal_logic_quiz_app/routing/router.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({
    super.key,
    required this.quizRun,
    this.normalBack = true,
  });

  final QuizRun quizRun;
  final bool normalBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> answerWidgets = [];

    for (QuizRunQuestion question in quizRun.questions) {
      // Adding the main question and the given answer
      answerWidgets.add(
        ListTile(
          title: Text(question.question),
          subtitle: Text('Your Answer: ${question.givenAnswer}'),
          trailing: question.isCorrect
              ? const Icon(Icons.check, color: Colors.green)
              : const Icon(Icons.close, color: Colors.red),
        ),
      );

      answerWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: question.getAnswers().map((answer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      question.givenAnswer == answer
                          ? (question.correctAnswer == answer
                              ? Icons.check_circle
                              : Icons.cancel)
                          : (question.correctAnswer == answer
                              ? Icons.check_circle_outline
                              : Icons.circle),
                      color: question.givenAnswer == answer
                          ? (question.correctAnswer == answer
                              ? Colors.green
                              : Colors.red)
                          : (question.correctAnswer == answer
                              ? Colors.green
                              : null),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(child: Text(answer)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );

      answerWidgets.add(const SizedBox(height: 10.0));

      answerWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer),
            const SizedBox(width: 4.0),
            Text(question.formattedTime),
          ],
        ),
      );

      answerWidgets.add(const Divider());
    }

    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) =>
              normalBack ? context.pop() : context.go(quizStartingScreen),
          child: ListView(children: [
            PageHeader(
              title: "Formal Logic Quiz",
              subtitle: "Quiz Results",
              back: true,
              onBack: () =>
                  normalBack ? context.pop() : context.go(quizStartingScreen),
              backText: normalBack ? "Back" : "Back to Home",
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Text(
                  "Quiz results of ${DateFormat('yyyy-MM-dd – kk:mm').format(quizRun.createdAt.toLocal())}",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Text("You needed ${quizRun.formattedTime} for the Quiz.",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Column(
                  children: answerWidgets,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
