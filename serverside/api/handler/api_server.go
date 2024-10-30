package api

import (
	"context"
	"log"
	"logic_app_backend/config"
	db "logic_app_backend/internal/database"
	"logic_app_backend/task_generation"
	"strconv"
	"time"

	"math/rand"

	jwt "github.com/appleboy/gin-jwt/v2"
	"github.com/gin-gonic/gin"
)

type APIServer struct {
	queries db.Querier
	config  config.Config
}

func NewAPIServer(queries db.Querier, config config.Config, createDummyQuestionsIfNeeded bool) *APIServer {
	apiServer := &APIServer{
		queries: queries,
		config:  config,
	}
	if createDummyQuestionsIfNeeded {
		apiServer.createQuestionsIfNeeded()
	}

	return apiServer
}

// Loads dummy questions into the database if there are less than 10 questions in the database
// After that, we fill the database up to 200 questions with the task generator
func (s *APIServer) createQuestionsIfNeeded() {
	questions, err := s.queries.ListQuestions(context.Background())
	if err != nil {
		log.Fatalf("Unable to get questions: %v\n", err)
	}
	numberOfExistingQuestions := len(questions)
	if numberOfExistingQuestions < 10 {
		numberOfDummyQuestionsToCreate := min(len(DUMMY_QUESTIONS), 10-numberOfExistingQuestions)
		for i := 0; i < numberOfDummyQuestionsToCreate; i++ {
			question := DUMMY_QUESTIONS[i]
			_, err := s.queries.CreateQuestion(context.Background(), question)
			if err != nil {
				log.Fatalf("Unable to create question: %v\n", err)
			}
		}
		if numberOfDummyQuestionsToCreate > 0 {
			log.Println("Filled database up with " + strconv.Itoa(min(len(DUMMY_QUESTIONS), 10-numberOfExistingQuestions)) + " dummy questions")
		}
	}
	questions, err = s.queries.ListQuestions(context.Background())
	if err != nil {
		log.Fatalf("Unable to get questions: %v\n", err)
	}
	numberOfExistingQuestions = len(questions)

	numberOfQuestionsToGenerate := 200 - numberOfExistingQuestions
	if numberOfQuestionsToGenerate > 0 {
		rng := rand.New(rand.NewSource(time.Now().UnixNano()))
		taskGenerator := task_generation.TaskGenerator{
			Rng:         rng,
			Connectives: []string{"AND", "OR"},
			// Connectives:         []string{"AND", "OR", "↔", "→"}, // this works also but we do not have transformation rules for ↔ and → yet
			Variables:           []string{"P", "Q", "R", "S", "T"},
			NotProbability:      0.3,
			MinDepth:            1,
			MaxDepth:            2,
			AmountOfLawsToApply: 3,
			AmountWrongFormulas: 3,
			MaxFailedTries:      10,
		}
		tasks := taskGenerator.GenerateTasks(numberOfQuestionsToGenerate)

		for task := range tasks {
			question := "What is the equivalent formula to " + tasks[task].OriginalFormula + "?"
			_, err := s.queries.CreateQuestion(context.Background(), db.CreateQuestionParams{Question: question, PossibleAnswers: tasks[task].WrongTransformedFormulas, CorrectAnswer: tasks[task].CorrectTransformedFormula})
			if err != nil {
				log.Fatalf("Unable to create question: %v\n", err)
			}
		}
		log.Println("Generated " + strconv.Itoa(numberOfQuestionsToGenerate) + " questions and saved them to the database")
	}
}

func (s *APIServer) SetupAPIRoutes(r *gin.RouterGroup, authMiddleware *jwt.GinJWTMiddleware) {
	r.POST("/register", s.registerUser)
	r.POST("/check-token", authMiddleware.MiddlewareFunc(), s.checkToken)
	r.GET("/users", s.getUsers)
	r.DELETE("/users/:id", s.deleteUser)
	r.PUT("/users/:id/change-password", s.changePassword)

	r.GET("/questions", s.getQuestions)
	r.POST("/questions", s.addQuestion)
	r.DELETE("/questions/:id", s.deleteQuestion)

	r.POST("/quiz-runs", authMiddleware.MiddlewareFunc(), s.addQuizRun)
	r.POST("/quiz-runs/anonym", s.addAnonymQuizRun)
	r.GET("/quiz-runs", authMiddleware.MiddlewareFunc(), s.getQuizRuns)
	r.GET("/last-30-days-statistics", authMiddleware.MiddlewareFunc(), s.getLast30DaysStatistics)
	r.GET("/leaderboard", s.getLeaderboard)
}
