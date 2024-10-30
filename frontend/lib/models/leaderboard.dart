class UserRank {
  int? userId;
  String username;
  int totalTimeCentiseconds;
  int correctAnswersCount;
  int totalQuestionsCount;
  int rank;

  UserRank({
    this.userId,
    required this.username,
    required this.totalTimeCentiseconds,
    required this.correctAnswersCount,
    required this.totalQuestionsCount,
    required this.rank,
  });

  factory UserRank.fromJson(Map<String, dynamic> json) {
    return UserRank(
      userId: json['userId'],
      username: json['username'] ?? 'NO_USER',
      totalTimeCentiseconds: json['totalTime'] ?? 0,
      correctAnswersCount: json['correctAnswersCount'] ?? 0,
      totalQuestionsCount: json['totalQuestionsCount'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}

class LeaderBoard {
  List<UserRank> ranks;

  LeaderBoard({required this.ranks});

  factory LeaderBoard.fromJson(List<dynamic> json) {
    List<UserRank> ranks = [];
    for (var rank in json) {
      ranks.add(UserRank.fromJson(rank));
    }
    return LeaderBoard(ranks: ranks);
  }
}