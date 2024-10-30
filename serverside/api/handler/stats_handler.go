package api

import (
	api_models "logic_app_backend/api/models"
	db "logic_app_backend/internal/database"
	"net/http"
	"strconv"
	"time"

	middlewareJWT "github.com/appleboy/gin-jwt/v2"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgtype"
)

func (s *APIServer) addQuizRun(c *gin.Context) {
	claims := middlewareJWT.ExtractClaims(c)

	var json api_models.QuizRun
	if err := c.ShouldBindJSON(&json); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user_id := claims[s.config.JWT_IDENTITY_KEY].(float64)

	quizRun, err := s.addQuizRunToDatabase(false, int64(user_id), json, c)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"id": quizRun})
}

func (s *APIServer) addAnonymQuizRun(c *gin.Context) {
	var json api_models.QuizRun
	if err := c.ShouldBindJSON(&json); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	quizRun, err := s.addQuizRunToDatabase(true, 0, json, c)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"id": quizRun})
}

func (s *APIServer) addQuizRunToDatabase(anonym bool, userID int64, json api_models.QuizRun, c *gin.Context) (*db.UserQuizRun, error) {
	var dbUserID pgtype.Int8
	if !anonym {
		dbUserID = pgtype.Int8{
			Int64: userID,
			Valid: true,
		}
	} else {
		dbUserID = pgtype.Int8{
			Int64: 0,
			Valid: false,
		}
	}
	quizRun, err := s.queries.AddQuizRun(c, dbUserID)
	if err != nil {
		return nil, err
	}
	var quizRunID pgtype.Int8

	for _, question := range json.QuizRunQuestions {
		quizRunID = pgtype.Int8{
			Int64: int64(quizRun.ID),
			Valid: true,
		}
		s.queries.AddQuizQuestion(c, db.AddQuizQuestionParams{
			UserQuizRunID: quizRunID,
			Question:      question.Question,
			WrongAnswers:  question.WrongAnswers,
			CorrectAnswer: question.CorrectAnswer,
			GivenAnswer: pgtype.Text{
				String: question.GivenAnswer,
				Valid:  question.GivenAnswer != "",
			},
			TimeNeeded: pgtype.Float8{
				Float64: float64(question.TimeSpentCentiseconds),
				Valid:   question.GivenAnswer != "",
			},
		})
	}
	return &quizRun, nil
}

func (s *APIServer) getQuizRuns(c *gin.Context) {
	claims := middlewareJWT.ExtractClaims(c)

	user_id := claims[s.config.JWT_IDENTITY_KEY].(float64)

	limit_query, has_limit_query := c.GetQuery("limit")

	if !has_limit_query {
		limit_query = "10"
	}

	limit, err := strconv.ParseInt(limit_query, 10, 32)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	dbUserID := pgtype.Int8{
		Int64: int64(user_id),
		Valid: true,
	}
	quizRuns, err := s.queries.GetQuizRunsWithLimit(c, db.GetQuizRunsWithLimitParams{UserID: dbUserID, Limit: int32(limit)})
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	allQuizRuns := make([]api_models.QuizRun, 0)

	for _, quizRun := range quizRuns {
		allQuizRunQuestions := make([]api_models.QuizRunQuestion, 0)
		quizRunQuestions, err := s.queries.GetQuizQuestions(c, pgtype.Int8{
			Int64: int64(quizRun.ID),
			Valid: true,
		})
		if err != nil {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		for _, quizRunQuestion := range quizRunQuestions {
			apiQuizRunQuestion := api_models.QuizRunQuestion{
				Question:              quizRunQuestion.Question,
				GivenAnswer:           quizRunQuestion.GivenAnswer.String,
				WrongAnswers:          quizRunQuestion.WrongAnswers,
				CorrectAnswer:         quizRunQuestion.CorrectAnswer,
				TimeSpentCentiseconds: quizRunQuestion.TimeNeeded.Float64,
			}
			allQuizRunQuestions = append(allQuizRunQuestions, apiQuizRunQuestion)
		}
		allQuizRuns = append(allQuizRuns, api_models.QuizRun{
			ID:               quizRun.ID,
			CreatedAt:        quizRun.CreatedAt,
			QuizRunQuestions: allQuizRunQuestions,
		})
	}

	c.JSON(http.StatusOK, allQuizRuns)

}

func (s *APIServer) getLast30DaysStatistics(c *gin.Context) {
	claims := middlewareJWT.ExtractClaims(c)

	user_id := claims[s.config.JWT_IDENTITY_KEY].(float64)

	dbUserID := pgtype.Int8{
		Int64: int64(user_id),
		Valid: true,
	}

	userQuizRuns, err := s.queries.GetQuizRunsRatioAndTimeSinceDateFromUser(c, db.GetQuizRunsRatioAndTimeSinceDateFromUserParams{
		UserID: dbUserID,
		CreatedAt: pgtype.Timestamptz{
			Time:  time.Now().AddDate(0, 0, -30),
			Valid: true,
		},
	})
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	totalTime := 0
	totalCorrectAnswers := 0
	totalQuestions := 0

	for _, userQuizRun := range userQuizRuns {
		totalTime += int(userQuizRun.TotalTime)
		totalCorrectAnswers += int(userQuizRun.CorrectAnswersCount)
		totalQuestions += int(userQuizRun.TotalQuestionsCount)
	}

	var averageCorrectAnswers float64
	var averageTimePerQuiz float64
	if len(userQuizRuns) > 0 {
		averageCorrectAnswers = float64(totalCorrectAnswers) / float64(totalQuestions)
		averageTimePerQuiz = float64(totalTime) / float64(len(userQuizRuns))
	}

	c.JSON(http.StatusOK, api_models.Last30DaysStatistic{
		TotalTime:             totalTime,
		TotalCorrectAnswers:   totalCorrectAnswers,
		TotalQuestions:        totalQuestions,
		TotalQuizRuns:         len(userQuizRuns),
		AverageTimePerQuiz:    averageTimePerQuiz,
		AverageCorrectAnswers: averageCorrectAnswers,
	})

}

func (s *APIServer) getLeaderboard(c *gin.Context) {
	amountOfRanksInLeaderboard := int32(5)
	quizRuns, err := s.queries.GetUserQuizRunRanking(c, amountOfRanksInLeaderboard)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	numExistingQuizRuns := len(quizRuns)
	numFillUp := int(amountOfRanksInLeaderboard) - numExistingQuizRuns
	for i := 0; i < numFillUp; i++ {
		quizRuns = append(quizRuns, db.GetUserQuizRunRankingRow{
			Rank:     int64(numExistingQuizRuns + i + 1),
			Username: "NO_USER",
		})
	}

	c.JSON(http.StatusOK, quizRuns)
}
