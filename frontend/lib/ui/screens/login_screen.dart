import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/routing/router.dart';
import 'package:formal_logic_quiz_app/services/authentication/token_authentication.dart';
import 'package:formal_logic_quiz_app/ui/screens/statistics_screen.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';
import 'package:formal_logic_quiz_app/ui/widgets/text_with_link.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String username = '';
    String password = '';

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextWithLink(
                onTap: () => {
                      context.go(registerScreen),
                    },
                text: "Don't have an account? Register",
                tapText: "here")),
      ),
      body: SafeArea(
        child: ListView(children: [
          const PageHeader(
            title: "Login",
            subtitle: "Login to your account",
          ),
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    onChanged: (value) {
                      username = value;
                    },
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Username',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Password',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () async {
                      final (success, errorMessage) =
                          await login(username, password);
                      if (success) {
                        context.go(quizStartingScreen);
                        if (errorMessage == 'offline') {
                          toastification.show(
                            context: context,
                            type: ToastificationType.info,
                            title: const Text('Offline login successful'),
                            description: const Text(
                                "User statistics won't be saved beside anonymous statistics"),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                        } else {
                          toastification.show(
                            context: context,
                            type: ToastificationType.success,
                            title: const Text('Login successful'),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                        }
                        // Make sure no old statistics are shown
                        ref.invalidate(quizRunProvider);
                        ref.invalidate(leaderBoardProvider);
                        ref.invalidate(last30DaysStatisticsProvider);
                      } else {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          title: const Text('Login failed'),
                          description: Text(errorMessage),
                          autoCloseDuration: const Duration(seconds: 5),
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
