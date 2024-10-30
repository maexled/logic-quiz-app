import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formal_logic_quiz_app/constants.dart';
import 'package:formal_logic_quiz_app/routing/router.dart';
import 'package:formal_logic_quiz_app/services/settings/settings_storage.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
  level: LOGGER_LEVEL,
);

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

final themeProvider = FutureProvider<String>((ref) {
  return SettingsStorage.getTheme();
});

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  ThemeMode getThemeMode(String? theme) {
    if (theme == 'light') {
      return ThemeMode.light;
    } else if (theme == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<String?> theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Formal Logic Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: theme.when(
        data: (data) => getThemeMode(data),
        error: (error, stackTrace) => ThemeMode.system,
        loading: () => ThemeMode.system,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
