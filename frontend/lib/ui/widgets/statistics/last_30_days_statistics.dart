import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/ui/screens/statistics_screen.dart';
import 'package:formal_logic_quiz_app/ui/widgets/error_message_box.dart';
import 'package:formal_logic_quiz_app/ui/widgets/loading_spinner.dart';

class Last30DaysStatisticsWidget extends ConsumerWidget {
  const Last30DaysStatisticsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last30DaysStatistics = ref.watch(last30DaysStatisticsProvider);
    return Column(
      children: [
        const Column(
          children: [
            Text("Your last 30 days statistics", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        last30DaysStatistics.when(
          data: (data) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Average success rate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("${(data.averageCorrectAnswers * 100).toStringAsFixed(2)}%", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Average time per quiz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("${(data.averageTimePerQuizCentiseconds / 10).toStringAsFixed(2)} seconds", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const LoadingSpinner(),
          error: (error, stackTrace) => Center(
            child: ErrorMessageBox(
              message: "Error loading last 30 days statistics: $error",
            ),
          ),
        )
      ],
    );
  }
}
