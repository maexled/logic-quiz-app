import 'package:formal_logic_quiz_app/models/question.dart';

class Quiz {
  List<Question> questions;

  int currentQuestionIndex = 0;

  Quiz({required this.questions});

  Question get currentQuestion => questions[currentQuestionIndex];

  void answerCurrentQuestion(String answer, int timeSpentCentiseconds) {
    currentQuestion.answer(answer, timeSpentCentiseconds);
  }

  void nextQuestion() {
    if (!hasNextQuestion) {
      throw Exception('No more questions');
    }
    currentQuestionIndex++;
  }

  bool get hasNextQuestion => currentQuestionIndex < questions.length - 1;

  bool get isFinished => !hasNextQuestion && currentQuestion.isAnswered;

  bool get completedQuiz => questions.every((question) => question.isAnswered);

  int get totalTimeSpentCentiseconds {
    return questions
        .map((question) => question.timeSpentCentiseconds ?? 0)
        .reduce((a, b) => a + b);
  }

  factory Quiz.loadDummyQuiz() {
    return Quiz(
      questions: [
        Question(
          question: 'What is the equivalent formula to (Q OR ((NOT R) AND R))?',
          wrongAnswers: [
            "(((Q OR R) OR Q) AND ((Q OR R) OR (NOT R)))",
            "(((Q OR (NOT R)) OR Q) AND ((Q OR (NOT R)) OR R))",
            "(((Q OR (NOT R)) OR R) AND ((Q OR (NOT R)) OR Q))"
          ],
          correctAnswer: "(((Q OR (NOT R)) AND Q) OR ((Q OR (NOT R)) AND R))",
        ),
        Question(
          question:
              'What is the equivalent formula to (((NOT P) AND S) AND (Q OR R))?',
          wrongAnswers: [
            "((((NOT P) AND S) OR R) AND (((NOT P) AND S) OR Q))",
            "(((((NOT P) AND S) OR Q) AND ((NOT P) AND S)) OR ((((NOT P) AND S) OR Q) AND R))",
            "(((((NOT P) AND S) OR R) AND ((NOT P) AND S)) OR ((((NOT P) AND S) OR R) AND Q))"
          ],
          correctAnswer: "((Q OR R) AND ((NOT P) AND S))",
        ),
        Question(
          question:
              'What is the equivalent formula to ((NOT P) OR ((NOT S) AND S))?',
          wrongAnswers: [
            "(((((NOT P) OR (NOT S)) OR (NOT P)) AND ((NOT P) OR (NOT S))) OR ((((NOT P) OR (NOT S)) OR (NOT P)) AND S))",
            "((((NOT P) OR (NOT S)) OR (NOT P)) AND (((NOT P) OR (NOT S)) OR S))",
            "((((NOT P) OR (NOT S)) OR S) AND (((NOT P) OR (NOT S)) OR (NOT P)))"
          ],
          correctAnswer: "(((NOT P) OR (NOT S)) AND ((NOT P) OR S))",
        ),
        Question(
          question:
              'What is the equivalent formula to (((NOT T) OR T) AND ((NOT S) OR P))?',
          wrongAnswers: [
            "((((NOT T) OR T) OR (NOT S)) AND (((NOT T) OR T) OR P))",
            "(((((NOT T) OR T) OR P) AND ((NOT T) OR T)) OR ((((NOT T) OR T) OR P) AND (NOT S)))",
            "((((((NOT T) OR T) AND (NOT S)) AND ((NOT T) OR T)) OR (((NOT T) OR T) AND (NOT S))) AND (((((NOT T) OR T) AND (NOT S)) AND ((NOT T) OR T)) OR P))"
          ],
          correctAnswer:
              "((((NOT T) OR T) AND (NOT S)) OR (((NOT T) OR T) AND P))",
        ),
        Question(
          question:
              'What is the equivalent formula to ((NOT Q) OR (P AND (NOT R)))?',
          wrongAnswers: [
            "((((NOT Q) OR P) OR (NOT Q)) AND (((NOT Q) OR P) OR (NOT R)))",
            "((((NOT Q) OR P) OR (NOT R)) AND (((NOT Q) OR P) OR (NOT Q)))",
            "(((NOT Q) AND (NOT R)) OR ((NOT Q) AND P))"
          ],
          correctAnswer:
              "(((((NOT Q) OR P) AND (NOT Q)) OR ((NOT Q) OR P)) AND ((((NOT Q) OR P) AND (NOT Q)) OR (NOT R)))",
        ),
        Question(
          question:
              'What is the equivalent formula to (((NOT T) AND P) OR (P OR Q))?',
          wrongAnswers: [
            "((((P OR Q) AND (NOT T)) OR (P OR Q)) AND (((P OR Q) AND (NOT T)) OR P))",
            "((((P OR Q) OR (NOT T)) OR (P OR Q)) AND (((P OR Q) OR (NOT T)) OR P))",
            "(((P OR Q) AND (NOT T)) OR ((P OR Q) AND P))"
          ],
          correctAnswer: "(((P OR Q) OR (NOT T)) AND ((P OR Q) OR P))",
        ),
        Question(
          question:
              'What is the equivalent formula to (((NOT R) OR R) OR (P AND Q))?',
          wrongAnswers: [
            "((((NOT R) OR R) AND P) OR (((NOT R) OR R) AND Q))",
            "(((((NOT R) OR R) AND P) OR ((NOT R) OR R)) AND ((((NOT R) OR R) AND P) OR Q))",
            "((((NOT R) OR R) AND Q) OR (((NOT R) OR R) AND P))"
          ],
          correctAnswer:
              "(((((NOT R) OR R) OR P) AND ((NOT R) OR R)) OR ((((NOT R) OR R) OR P) AND Q))",
        ),
        Question(
          question:
              'What is the equivalent formula to ((NOT T) OR (T AND Q))?',
          wrongAnswers: [
            "((((NOT T) AND T) OR (NOT T)) AND (((NOT T) AND T) OR Q))",
            "(((NOT T) AND T) OR ((NOT T) AND Q))",
            "((((NOT T) OR T) OR Q) AND (((NOT T) OR T) OR (NOT T)))"
          ],
          correctAnswer:
              "(((NOT T) OR T) AND ((NOT T) OR Q))"
        ),
        Question(
          question:
              'What is the equivalent formula to ((Q OR (NOT S)) OR (R AND P))?',
          wrongAnswers: [
            "(((Q OR (NOT S)) AND R) OR ((Q OR (NOT S)) AND P))",
            "(((Q OR (NOT S)) AND P) OR ((Q OR (NOT S)) AND R))",
            "((((Q OR (NOT S)) OR R) OR (Q OR (NOT S))) AND (((Q OR (NOT S)) OR R) OR P))"
          ],
          correctAnswer:
              "((((Q OR (NOT S)) OR R) AND (Q OR (NOT S))) OR (((Q OR (NOT S)) OR R) AND P))",
        ),
        Question(
          question:
              'What is the equivalent formula to ((T OR (NOT Q)) AND (NOT S))?',
          wrongAnswers: [
            "((((NOT S) OR T) AND (NOT S)) OR (((NOT S) OR T) AND (NOT Q)))",
            "((((NOT S) AND T) AND (NOT S)) OR (((NOT S) AND T) AND (NOT Q)))",
            "(((NOT S) OR T) AND ((NOT S) OR (NOT Q)))"
          ],
          correctAnswer:
              "(((NOT S) AND T) OR ((NOT S) AND (NOT Q)))",
        ),
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}
