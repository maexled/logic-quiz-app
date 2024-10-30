class Last30DaysStatistics {
  
  final num averageTimePerQuizCentiseconds;
  final num averageCorrectAnswers;

  Last30DaysStatistics({
    required this.averageTimePerQuizCentiseconds,
    required this.averageCorrectAnswers,
  });

  factory Last30DaysStatistics.fromJson(Map<String, dynamic> json) {
    return Last30DaysStatistics(
      averageTimePerQuizCentiseconds: json['averageTimePerQuiz'],
      averageCorrectAnswers: json['averageCorrectAnswers'],
    );
  }
}
