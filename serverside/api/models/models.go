package api_models

import "github.com/jackc/pgx/v5/pgtype"

type Register struct {
	Username string `form:"username" json:"username" xml:"username"  binding:"required"`
	Email    string `form:"email" json:"email" xml:"email" binding:"required"`
	Password string `form:"password" json:"password" xml:"password" binding:"required"`
}

type Login struct {
	Username string `form:"username" json:"username" xml:"username"`
	Email    string `form:"email" json:"email" xml:"email"`
	Password string `form:"password" json:"password" xml:"password" binding:"required"`
}

type User struct {
	ID       int64  `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
}

type QuizRun struct {
	ID               int64              `form:"id" json:"id" xml:"id"`
	CreatedAt        pgtype.Timestamptz `form:"createdAt" json:"createdAt" xml:"createdAt"`
	QuizRunQuestions []QuizRunQuestion  `form:"questions" json:"questions" xml:"questions" binding:"required"`
}

type QuizRunQuestion struct {
	Question              string   `form:"question" json:"question" xml:"question" binding:"required"`
	GivenAnswer           string   `form:"givenAnswer" json:"givenAnswer" xml:"givenAnswer"`
	WrongAnswers          []string `form:"wrongAnswers" json:"wrongAnswers" xml:"wrongAnswers" binding:"required"`
	CorrectAnswer         string   `form:"correctAnswer" json:"correctAnswer" xml:"correctAnswer" binding:"required"`
	TimeSpentCentiseconds float64  `form:"timeSpentCentiseconds" json:"timeSpentCentiseconds" xml:"timeSpentCentiseconds"`
}

type PostQuestion struct {
	Question        string   `form:"question" json:"question" xml:"question" binding:"required"`
	PossibleAnswers []string `form:"possibleAnswers" json:"possibleAnswers" xml:"possibleAnswers" binding:"required"`
	CorrectAnswer   string   `form:"correctAnswer" json:"correctAnswer" xml:"correctAnswer" binding:"required"`
}

type ChangePassword struct {
	Password string `form:"password" json:"password" xml:"password" binding:"required"`
}

type Last30DaysStatistic struct {
	TotalTime             int     `json:"totalTime"`
	TotalCorrectAnswers   int     `json:"totalCorrectAnswers"`
	TotalQuestions        int     `json:"totalQuestions"`
	TotalQuizRuns         int     `json:"totalQuizRuns"`
	AverageTimePerQuiz    float64 `json:"averageTimePerQuiz"`
	AverageCorrectAnswers float64 `json:"averageCorrectAnswers"`
}
