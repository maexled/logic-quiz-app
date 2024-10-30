import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/routing/router.dart';
import 'package:go_router/go_router.dart';

final indexProvider = StateProvider((ref) => 0);

class QuizBottomNavigationBar extends ConsumerWidget {
  const QuizBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = {
      0: quizStartingScreen,
      1: statisticsScreen,
      2: userGuideScreen,
      3: settingsScreen,
    };

    final index = ref.watch(indexProvider);

    void onTap(int index) {
      ref.read(indexProvider.notifier).state = index;
      context.go(pages[index]!);
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: 'Quiz',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'User Guide',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: index,
      onTap: onTap,
    );
  }
}
