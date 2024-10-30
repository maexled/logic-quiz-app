import 'dart:convert';
import 'dart:io';

import 'package:formal_logic_quiz_app/constants.dart';
import 'package:formal_logic_quiz_app/main.dart';
import 'package:formal_logic_quiz_app/models/last_30_days_statistics.dart';
import 'package:formal_logic_quiz_app/models/leaderboard.dart';
import 'package:formal_logic_quiz_app/models/question.dart';
import 'package:formal_logic_quiz_app/models/quiz.dart';
import 'package:formal_logic_quiz_app/models/quiz_run.dart';
import 'package:formal_logic_quiz_app/services/authentication/token_storage.dart';

import 'package:http/http.dart' as http;

/// Send a quiz run to the server without authentication.
/// Returns a tuple with a boolean indicating success and a string with an error message.
Future<(bool, String)> sendAnonymQuizRun(Quiz quiz) async {
  logger.d("Sending anonym quiz run to $QUIZ_RUN_ANONYM_URL");
  String errorMessage = "";
  try {
    final response = await http.post(
      Uri.parse(QUIZ_RUN_ANONYM_URL),
      body: json.encode(quiz.toJson()),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      logger.d('Anonym quiz run sent successfully');
      return (true, errorMessage);
    } else {
      errorMessage = data['error'];
    }
  } catch (e) {
    if (e is SocketException) {
      errorMessage = 'Server not reachable';
    } else {
      errorMessage = e.toString();
    }
  }
  logger.e('Error sending anonym quiz run: $errorMessage');
  return (false, errorMessage);
}

/// Send a quiz run to the server with authentication.
/// Returns a tuple with a boolean indicating success and a string with an error message.
Future<(bool, String)> sendAuthorizedQuizRun(Quiz quiz) async {
  logger.d("Sending quiz run to $QUIZ_RUN_URL");
  String errorMessage = "";
  try {
    String? token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse(QUIZ_RUN_URL),
      headers: {'Authorization': "Bearer $token"},
      body: json.encode(quiz.toJson()),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      logger.d('Quiz run sent successfully');
      return (true, errorMessage);
    } else if (response.statusCode == 401) {
      logger.w('Token invalid, trying to send anonym quiz run');
      return sendAnonymQuizRun(quiz);
    } else {
      errorMessage = data['error'];
    }
  } catch (e) {
    if (e is SocketException) {
      errorMessage = 'Server not reachable';
    } else {
      errorMessage = e.toString();
    }
  }
  logger.e('Error sending quiz run: $errorMessage');
  return (false, errorMessage);
}

/// Send a quiz run to the server.
/// Returns a tuple with a boolean indicating success and a string with an error message.
/// If no token is available, an anonym quiz run is sent.
/// If the token is invalid, an anonym quiz run is sent.
/// If the token is valid, an authorized quiz run is sent.
Future<(bool, String)> sendQuizRun(Quiz quiz) async {
  String? token = await TokenStorage.getToken();
  if (token == null || token == 'offline') {
    return sendAnonymQuizRun(quiz);
  } else {
    return sendAuthorizedQuizRun(quiz);
  }
}

/// Returns a list of quiz runs from the server.
Future<List<QuizRun>> getQuizRuns() async {
  logger.d("Requesting quiz runs from $QUIZ_RUN_URL");
  try {
    String? token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse(QUIZ_RUN_URL),
      headers: {'Authorization': "Bearer $token"},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      List<QuizRun> quizRuns = QuizRun.listFromJson(data);
      return quizRuns;
    } else {
      if (response.statusCode == 401) {
        throw Exception('Could not get quiz runs since there is no valid token');
      }
    }
  } catch (e) {
    logger.e('Error getting quiz runs: $e');
    rethrow;
  }
  return [];
}

/// Returns the leaderboard from the server.
Future<LeaderBoard> getLeaderboard() async {
  logger.d("Requesting leaderboard from $LEADERBOARD_URL");
  try {
    final response = await http.get(
      Uri.parse(LEADERBOARD_URL),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      LeaderBoard leaderboard = LeaderBoard.fromJson(data);
      return leaderboard;
    } else {
      logger.e('Error getting leaderboard: ${data['error']}');
      throw Exception('Error getting leaderboard: ${data['error']}');
    }
  } catch (e) {
    logger.e('Error getting leaderboard: $e');
    rethrow;
  }
}

/// Returns the last 30 days statistics of the user
Future<Last30DaysStatistics> getLast30DaysStatistics() async {
  logger.d("Requesting last 30 days statistics from $LAST_30_DAYS_STATISTICS_URL");
  try {
    String? token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse(LAST_30_DAYS_STATISTICS_URL),
      headers: {'Authorization': "Bearer $token"},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Last30DaysStatistics last30DaysStatistics = Last30DaysStatistics.fromJson(data);
      return last30DaysStatistics;
    } else {
      if (response.statusCode == 401) {
        throw Exception('Could not get last 30 days statistics since there is no valid token');
      }
      logger.e('Error getting last 30 days statistics: ${data['error']}');
      throw Exception('Error getting last 30 days statistics: ${data['error']}');
    }
  } catch (e) {
    logger.e('Error getting last 30 days statistics: $e');
    rethrow;
  }
}

/// Returns a list of questions from the server.
/// The server is requested to provide [QUESTIONS_PER_QUIZ] questions.
/// If the server is not reachable, a dummy quiz is returned.
Future<List<Question>> getQuestions() async {
  logger.d("Requesting $QUESTIONS_PER_QUIZ questions from $QUESTIONS_URL");
  try {
    final response = await http.get(
      Uri.parse("$QUESTIONS_URL?limit=$QUESTIONS_PER_QUIZ"),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final questions = Question.listFromJson(data);
      return questions;
    }
  } catch (e) {
    if (e is SocketException) {
      logger.w('Server not reachable');
    } else {
      logger.e('Error getting questions: $e');
    }
  }
  return Quiz.loadDummyQuiz().questions;
}