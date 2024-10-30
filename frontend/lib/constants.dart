import 'package:logger/logger.dart';

const BASE_API_URL = 'http://localhost:5000';

const LOGIN_URL = '$BASE_API_URL/auth';
const REGISTER_URL = '$BASE_API_URL/api/register';
const CHECK_TOKEN_URL = '$BASE_API_URL/api/check-token';

const QUIZ_RUN_URL = '$BASE_API_URL/api/quiz-runs';
const QUIZ_RUN_ANONYM_URL = '$BASE_API_URL/api/quiz-runs/anonym';
const LEADERBOARD_URL = '$BASE_API_URL/api/leaderboard';
const LAST_30_DAYS_STATISTICS_URL = '$BASE_API_URL/api/last-30-days-statistics';

const QUESTIONS_URL = '$BASE_API_URL/api/questions';
const QUESTIONS_PER_QUIZ = 10;

const LOGGER_LEVEL = Level.debug;