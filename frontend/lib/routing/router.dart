import 'package:formal_logic_quiz_app/main.dart';
import 'package:formal_logic_quiz_app/models/quiz_run.dart';
import 'package:formal_logic_quiz_app/services/authentication/token_storage.dart';
import 'package:formal_logic_quiz_app/ui/screens/login_screen.dart';
import 'package:formal_logic_quiz_app/ui/screens/quiz_result_screen.dart';
import 'package:formal_logic_quiz_app/ui/screens/quiz_screen.dart';
import 'package:formal_logic_quiz_app/ui/screens/quiz_starting_screen.dart';
import 'package:formal_logic_quiz_app/ui/screens/register_screen.dart';
import 'package:formal_logic_quiz_app/ui/screens/settings_screen.dart';
import 'package:formal_logic_quiz_app/ui/screens/statistics_screen.dart';
import 'package:formal_logic_quiz_app/ui/screens/user_guide_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

const String quizStartingScreen = '/';

const String statisticsScreen = '/statistics';
const String quizResultScreen = '/statistics/detail';

const String userGuideScreen = '/guide';
const String settingsScreen = '/settings';

const String loginScreen = '/login';
const String registerScreen = '/register';

const String quizScreen = '/quiz';

/// Check if the token is valid
/// May throw an exception if the server which the token is checked against is not reachable
Future<bool> checkAuthentication() async {
  final token = await TokenStorage.getToken();
  if (token == null) return false;
  if (token == 'offline') return true;
  DateTime expirationDate = JwtDecoder.getExpirationDate(token);
  logger.d('Token expiration date: $expirationDate');
  //return await isTokenValid(token);
  return !JwtDecoder.isExpired(token);
}

// GoRouter configuration
final router = GoRouter(
  redirect: (context, state) async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await checkAuthentication();
    } catch (e) {
      logger.e('Error checking authentication: $e');
    }

    final goingToLogin = [
      loginScreen,
      registerScreen,
    ].contains(state.fullPath);
    if (!isAuthenticated && !goingToLogin) {
      return loginScreen;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: loginScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: registerScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: RegisterScreen()),
    ),
    GoRoute(
      path: quizStartingScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: QuizStartingScreen()),
    ),
    GoRoute(
      path: statisticsScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: StatisticsScreen()),
    ),
    GoRoute(
      path: userGuideScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: UserGuideScreen()),
    ),
    GoRoute(
      path: settingsScreen,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SettingsScreen()),
    ),
    GoRoute(
      path: quizScreen,
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      name: "quizResultScreen",
      path: quizResultScreen,
      builder: (context, state) {
        final bool normalBack =
            (state.uri.queryParameters['normalBack'] ?? '') != "false";
        QuizRun quizRun = state.extra as QuizRun;

        return QuizResultScreen(
          quizRun: quizRun,
          normalBack: normalBack,
        );
      },
    ),
  ],
);
