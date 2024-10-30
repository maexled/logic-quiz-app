import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/services/authentication/token_storage.dart';
import 'package:formal_logic_quiz_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';

class UserGuideScreen extends ConsumerWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      bottomNavigationBar: const QuizBottomNavigationBar(),
      body: SafeArea(
        child: Column(children: [
          const PageHeader(
            title: "User Guide",
            subtitle: "How to use the app",
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Text("Running a quiz",
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 5),
                    Text(
                      "To start a quiz, click on the 'Start Quiz' button on the Quiz screen. You will be presented with a series of questions about propositional logic. A starting formular will be given, your task is to find the right equivalent formular. Answer each question by selecting the correct answer. After selecting the answer, it is show whether the answer is correct or not. At the end of the quiz, you will be shown the result of the quiz.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Text("Viewing statistics",
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 5),
                    Text(
                      "To view your quiz statistics, change to the Statistics screen over the navigation bar on the bottom. You will be presented with a list of your quiz runs (last 10) and a leaderboard of the top quiz takers. The tiles of the quiz runs are clickable and can provide more detailed information about the quiz run. The leaderboard is calculated first on the highest number of correct answers and then on the shortest time taken to complete the quiz.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    FutureBuilder<bool>(
                      future: TokenStorage.hasOfflineToken(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("");
                        } else if (snapshot.hasError) {
                          return const Text("");
                        } else {
                          if (snapshot.data == true) {
                            return const Text("You have an offline token. Statistics are loaded from the backend server, thus the statistics will not load if you are using an offline user",
                                style: TextStyle(color: Colors.red));
                          }
                          return const Text("");
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Text("Changing the theme",
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 5),
                    Text(
                      "To change the theme of the app, go to the Settings screen. You can choose between a light, dark or system theme. The system theme will follow the system settings of your device.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Text("Logging out",
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 5),
                    Text(
                      "To log out of the app, go to the Settings screen and click on the 'Logout' button. You will be logged out of the app and redirected to the login screen.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                )),
          ),
        ]),
      ),
    );
  }
}
