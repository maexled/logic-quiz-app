class Question {
  String question;

  List<String> wrongAnswers;
  String correctAnswer;

  List<String> answers;

  String? givenAnswer;
  int? timeSpentCentiseconds;

  Question(
    {required this.question,
    required this.wrongAnswers,
    required this.correctAnswer}) 
    : answers = [] {
    List<String> answers = List.from(wrongAnswers);
    answers.add(correctAnswer);
    answers.shuffle();
    this.answers = answers;
  }

  List<String> getAnswers() {
    return answers;
  }

  bool isCorrect(String answer) {
    return answer == correctAnswer;
  }

  bool answer(String answer, int timeSpentCentiseconds) {
    if (givenAnswer != null) {
      throw Exception('Cannot answer a question twice');
    }
    givenAnswer = answer;
    this.timeSpentCentiseconds = timeSpentCentiseconds;
    return isCorrect(answer);
  }

  bool get isAnswered => givenAnswer != null;

  String get givenAnswerText => givenAnswer ?? 'Not answered';

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

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'givenAnswer': givenAnswer,
      'wrongAnswers': wrongAnswers,
      'correctAnswer': correctAnswer,
      'timeSpentCentiseconds': timeSpentCentiseconds,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> possibleAnswers = json['possibleAnswers'].cast<String>();
    return Question(question: json['question'], wrongAnswers: possibleAnswers, correctAnswer: json['correctAnswer']);
  }

  static List<Question> listFromJson(List<dynamic> json) {
    return json.map<Question>((question) => Question.fromJson(question)).toList();
  }
}
