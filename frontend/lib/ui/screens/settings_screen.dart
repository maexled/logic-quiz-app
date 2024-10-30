import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/main.dart';
import 'package:formal_logic_quiz_app/services/authentication/token_storage.dart';
import 'package:formal_logic_quiz_app/services/settings/settings_storage.dart';
import 'package:formal_logic_quiz_app/ui/widgets/bottom_navigation_bar.dart';
import 'package:formal_logic_quiz_app/ui/widgets/page_header.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Function()? onLogoutPressed(BuildContext context) {
    return () {
      TokenStorage.removeToken();
      context.go('/login');
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    final List<String> themes = ['light', 'dark', 'system'];
    final initialTheme = theme.when(
      data: (data) => data,
      error: (error, stackTrace) => 'system',
      loading: () => 'system',
    );

    return Scaffold(
      bottomNavigationBar: const QuizBottomNavigationBar(),
      body: SafeArea(
        child: Column(children: [
          const PageHeader(
            title: "Settings",
            subtitle: "App settings",
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: onLogoutPressed(context),
                      child: const Text('Logout')),
                  const Divider(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Change Theme',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        DropdownMenu<String>(
                          initialSelection: initialTheme,
                          onSelected: (String? value) async {
                            if (value == null) {
                              return;
                            }
                            await SettingsStorage.setTheme(value);
                            ref.invalidate(themeProvider);
                          },
                          dropdownMenuEntries:
                              themes.map<DropdownMenuEntry<String>>(
                            (String value) {
                              return DropdownMenuEntry<String>(
                                value: value,
                                label: value,
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
