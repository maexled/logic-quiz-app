import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/ui/screens/statistics_screen.dart';
import 'package:formal_logic_quiz_app/ui/widgets/error_message_box.dart';
import 'package:formal_logic_quiz_app/ui/widgets/loading_spinner.dart';

class LeaderBoardList extends ConsumerWidget {
  const LeaderBoardList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderBoard = ref.watch(leaderBoardProvider);
    return Column(
      children: [
        const Column(
          children: [
            Text("Leaderboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        leaderBoard.when(
          data: (data) {
            List<Widget> list = data.ranks
                .map((rank) => ListTile(
                      leading: const Icon(Icons.emoji_events),
                      title: Text("${rank.rank}. ${rank.username}"),
                      subtitle: Text(
                          "Score: ${rank.correctAnswersCount} / ${rank.totalQuestionsCount}, Time: ${rank.totalTimeCentiseconds / 10}s"),
                    ))
                .toList();
            return Column(
              children: list,
            );
          },
          loading: () => const LoadingSpinner(),
          error: (error, stackTrace) => Center(
            child: ErrorMessageBox(
              message: "Error loading leaderboard: $error",
            ),
          ),
        )
      ],
    );
  }
}
