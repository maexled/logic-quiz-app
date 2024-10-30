import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/routing/router.dart';
import 'package:formal_logic_quiz_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';
import 'package:go_router/go_router.dart';
import 'quiz_screen.dart';

class QuizStartingScreen extends ConsumerWidget {
  const QuizStartingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: const QuizBottomNavigationBar(),
      body: SafeArea(
        child: Column(children: [
          const PageHeader(
            title: "Formal Logic Quiz",
            subtitle: "Test your formal logic skills",
          ),
          Expanded(
              child: Center(
            child: ElevatedButton(
              onPressed: () => {
                startQuiz(ref),
                context.push(quizScreen),
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(500, 100),
              ),
              child: const Text('Start Quiz', style: TextStyle(fontSize: 30)),
            ),
          )),
        ]),
      ),
    );
  }
}
