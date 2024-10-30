import 'package:formal_logic_quiz_app/models/question.dart';
import 'package:formal_logic_quiz_app/models/quiz.dart';
import 'package:test/test.dart';

void main() {
  group('Quiz test', () {
    late Quiz quiz;

    setUp(() {
      quiz = Quiz.loadDummyQuiz();
    });

    test('Quiz question index should start at 0', () {
      expect(quiz.currentQuestionIndex, 0);
    });

    test('Quiz question index should increment on next question', () {
      Question firstQuestion = quiz.currentQuestion;
      expect(quiz.currentQuestionIndex, 0);
      quiz.nextQuestion();
      expect(quiz.currentQuestionIndex, 1);
      // Question was not answered
      expect(firstQuestion.isAnswered, false);
      expect(quiz.currentQuestion.isAnswered, false);
      expect(quiz.currentQuestion != firstQuestion, true);
    });
    test('Answer quiz questions fills given answer in question', () {
      Question firstQuestion = quiz.currentQuestion;
      expect(quiz.currentQuestionIndex, 0);
      quiz.answerCurrentQuestion(firstQuestion.wrongAnswers[0], 13);
      quiz.nextQuestion();
      expect(quiz.currentQuestionIndex, 1);
      // Question was answered
      expect(firstQuestion.isAnswered, true);
      expect(firstQuestion.givenAnswer, firstQuestion.wrongAnswers[0]);
      expect(firstQuestion.isCorrect(firstQuestion.wrongAnswers[0]), false);
    });
    test('Quiz is finished after answering all questions', () {
      expect(quiz.isFinished, false);
      for (int i = 0; i < quiz.questions.length - 1; i++) {
        quiz.answerCurrentQuestion(quiz.currentQuestion.wrongAnswers[0], 13);
        quiz.nextQuestion();
        expect(quiz.isFinished, false);
      }
      quiz.answerCurrentQuestion(quiz.currentQuestion.wrongAnswers[0], 13);
      expect(quiz.isFinished, true);
      expect(quiz.totalTimeSpentCentiseconds, 13 * 10);
      expect(quiz.completedQuiz, true);
    });
    test('Quiz throws error when getting next question but no question left',
        () {
      expect(quiz.isFinished, false);
      for (int i = 0; i < quiz.questions.length - 1; i++) {
        quiz.answerCurrentQuestion(quiz.currentQuestion.wrongAnswers[0], 13);
        quiz.nextQuestion();
        expect(quiz.isFinished, false);
      }
      quiz.answerCurrentQuestion(quiz.currentQuestion.wrongAnswers[0], 13);
      expect(() => quiz.nextQuestion(), throwsA(isA<Exception>()));
    });
  });
}
