import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/models/last_30_days_statistics.dart';
import 'package:formal_logic_quiz_app/models/leaderboard.dart';
import 'package:formal_logic_quiz_app/models/quiz_run.dart';
import 'package:formal_logic_quiz_app/services/tasks/task_service.dart';
import 'package:formal_logic_quiz_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';
import 'package:formal_logic_quiz_app/ui/widgets/statistics/last_30_days_statistics.dart';
import 'package:formal_logic_quiz_app/ui/widgets/statistics/leaderboard_list.dart';
import 'package:formal_logic_quiz_app/ui/widgets/statistics/quiz_run_list.dart';

final quizRunProvider = FutureProvider<List<QuizRun>>((ref) async {
  return getQuizRuns();
});
final leaderBoardProvider = FutureProvider<LeaderBoard>((ref) async {
  return getLeaderboard();
});
final last30DaysStatisticsProvider = FutureProvider<Last30DaysStatistics>((ref) async {
  return getLast30DaysStatistics();
});

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: const QuizBottomNavigationBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(quizRunProvider);
            ref.invalidate(leaderBoardProvider);
            ref.invalidate(last30DaysStatisticsProvider);
          },
          child: ListView(children: const[
            PageHeader(
              title: "Statistics",
              subtitle: "Your quiz statistics",
            ),
            SizedBox(height: 20),
            QuizRunList(),
            Divider(height: 60),
            Last30DaysStatisticsWidget(),
            Divider(height: 60),
            LeaderBoardList(),
            SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}
