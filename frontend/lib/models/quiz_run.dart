import 'package:formal_logic_quiz_app/models/question.dart';

class QuizRun {
  int id;
  List<QuizRunQuestion> questions;
  DateTime createdAt;

  QuizRun(
      {required this.id, required this.questions, required this.createdAt});

  int get totalTimeSpentCentiseconds {
    return questions
        .map((question) => question.timeSpentCentiseconds ?? 0)
        .reduce((a, b) => a + b);
  }

  int get totalQuestions {
    return questions.length;
  }

  int get totalCorrectAnswers {
    return questions
        .where((question) => question.correctAnswer == question.givenAnswer)
        .length;
  }

  factory QuizRun.fromJson(Map<String, dynamic> json) {
    List<QuizRunQuestion> questions = [];
    for (var question in json['questions']) {
      questions.add(QuizRunQuestion.fromJson(question));
    }
    return QuizRun(
        id: json['id'],
        createdAt: DateTime.parse(json['createdAt']),
        questions: questions);
  }

  static List<QuizRun> listFromJson(List<dynamic> json) {
    return json.map<QuizRun>((quizRun) => QuizRun.fromJson(quizRun)).toList();
  }

  String get formattedTime {
    final totalCentiseconds = totalTimeSpentCentiseconds;
    final minutes = (totalCentiseconds ~/ 600).toString();
    final seconds =
        ((totalCentiseconds % 600) ~/ 10).toString().padLeft(2, '0');
    final centiseconds = (totalCentiseconds % 10).toString();
    if (minutes == '0') {
      return "$seconds.$centiseconds seconds";
    }
    return "$minutes:$seconds.$centiseconds minutes";
  }

}

class QuizRunQuestion {
  String question;
  List<String> wrongAnswers;
  String correctAnswer;
  String? givenAnswer;
  int? timeSpentCentiseconds;

  QuizRunQuestion(
      {required this.question,
      required this.wrongAnswers,
      required this.correctAnswer,
      required this.givenAnswer,
      required this.timeSpentCentiseconds});

  factory QuizRunQuestion.fromJson(Map<String, dynamic> json) {
    return QuizRunQuestion(
      question: json['question'],
      wrongAnswers: List<String>.from(json['wrongAnswers'] as List<dynamic>),
      correctAnswer: json['correctAnswer'],
      givenAnswer: json['givenAnswer'],
      timeSpentCentiseconds: json['timeSpentCentiseconds'],
    );
  }

  bool get isCorrect {
    return correctAnswer == givenAnswer;
  }

  List<String> getAnswers() {
    List<String> answers = List.from(wrongAnswers);
    answers.add(correctAnswer);
    answers.shuffle();
    return answers;
  }

  String get formattedTime {
    if (timeSpentCentiseconds == null) {
      return 'Not answered';
    }
    final totalCentiseconds = timeSpentCentiseconds!;
    final minutes = (totalCentiseconds ~/ 600).toString();
    final seconds =
        ((totalCentiseconds % 600) ~/ 10).toString().padLeft(2, '0');
    final centiseconds = (totalCentiseconds % 10).toString();
    if (minutes == '0') {
      return "$seconds.$centiseconds seconds";
    }
    return "$minutes:$seconds.$centiseconds minutes";
  }

  factory QuizRunQuestion.fromQuestion(Question question) {
    return QuizRunQuestion(
      question: question.question,
      wrongAnswers: question.wrongAnswers,
      correctAnswer: question.correctAnswer,
      givenAnswer: question.givenAnswer,
      timeSpentCentiseconds: question.timeSpentCentiseconds,
    );
  }

  static List<QuizRunQuestion> listFromQuestions(List<Question> questions) {
    return questions
        .map((question) => QuizRunQuestion.fromQuestion(question))
        .toList();
  }


}
