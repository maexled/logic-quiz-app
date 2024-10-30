import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/ui/screens/statistics_screen.dart';
import 'package:formal_logic_quiz_app/ui/widgets/error_message_box.dart';
import 'package:formal_logic_quiz_app/ui/widgets/loading_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class QuizRunList extends ConsumerWidget {
  const QuizRunList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizRuns = ref.watch(quizRunProvider);
    return Column(
      children: [
        const Column(
          children: [
            Text("Your last quiz results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20)
          ],
        ),
        quizRuns.when(
          data: (data) {
            List<Widget> list = data
                .map((quizRun) => ListTile(
                      leading: const Icon(Icons.quiz_rounded),
                      title: Text(DateFormat('yyyy-MM-dd – kk:mm')
                          .format(quizRun.createdAt.toLocal())),
                      subtitle: Text(
                          "Score: ${quizRun.totalCorrectAnswers} / ${quizRun.totalQuestions}"),
                      onTap: () => context.pushNamed("quizResultScreen",
                          extra: quizRun,
                          queryParameters: {"normalBack": "true"}),
                    ))
                .toList();
            if (list.isEmpty) {
              list = [];
              list.add(Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width - 300,
                child: const Text(
                  "No quiz results yet",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),));
            }
            return Column(
              children: list,
            );
          },
          loading: () => const LoadingSpinner(),
          error: (error, stackTrace) => Center(
            child: ErrorMessageBox(
              message: "Error loading quiz results: $error",
            ),
          ),
        )
      ],
    );
  }
}
