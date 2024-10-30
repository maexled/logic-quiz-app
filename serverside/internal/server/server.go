package server

import (
	"log"
	"net/http"
	"sort"
	"time"

	api "logic_app_backend/api/handler"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgtype"

	"logic_app_backend/config"
	db "logic_app_backend/internal/database"
)

type Server struct {
	config  config.Config
	router  *gin.Engine
	queries db.Querier
}

func NewServer(config config.Config, queries db.Querier) *Server {
	engine := gin.Default()
	corsConfig := cors.DefaultConfig()
	// should be set to false in production, but since testing with chrome should work...
	corsConfig.AllowAllOrigins = true
	corsConfig.AddAllowHeaders("Authorization")
	engine.Use(cors.New(corsConfig))
	server := &Server{
		config:  config,
		router:  engine,
		queries: queries,
	}
	log.Println("Server created at port 5000")
	return server
}

func (s *Server) SetupRouter(loadTemplates bool, createDummyQuestionsIfNeeded bool) {
	authMiddleware := s.SetupJWTMiddleware()

	// TODO: Make HTML template loading work in tests
	// panic: html/template: pattern matches no files: `web/templates/*` [recovered]
	//  	panic: html/template: pattern matches no files: `web/templates/*`
	if loadTemplates {
		s.router.LoadHTMLGlob("web/templates/*")
	}
	s.router.Static("/assets", "web/static")

	s.router.GET("/", s.Index)
	s.router.GET("/tasks", s.Tasks)
	s.router.GET("/users", s.Users)
	s.router.GET("/statistics", s.Statistics)

	s.router.POST("/auth", authMiddleware.LoginHandler)
	s.router.GET("/refresh_token", authMiddleware.RefreshHandler)

	s.router.GET("/health", s.health)

	apiRouter := s.router.Group("/api")

	apiServer := api.NewAPIServer(s.queries, s.config, createDummyQuestionsIfNeeded)
	apiServer.SetupAPIRoutes(apiRouter, authMiddleware)
	log.Println("API routes created")
}

func (s *Server) Router() *gin.Engine {
	return s.router
}

func (s *Server) Start(addr string) error {
	return s.router.Run(addr)
}

func (s *Server) health(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "healthy",
	})
}

func (s *Server) Index(c *gin.Context) {
	c.HTML(http.StatusOK, "index.html", gin.H{
		"title": "Logic App Backend",
		"sites": []gin.H{
			{"name": "Tasks", "url": "/tasks"},
			{"name": "Users", "url": "/users"},
			{"name": "Statistics", "url": "/statistics"},
		},
	})
}

func (s *Server) Tasks(c *gin.Context) {
	questions, err := s.queries.ListQuestions(c)
	if err != nil {
		c.HTML(http.StatusInternalServerError, "error.html", gin.H{
			"error": err.Error(),
		})
		return
	}
	c.HTML(http.StatusOK, "tasks.html", gin.H{
		"tasks": questions,
	})
}

func (s *Server) Users(c *gin.Context) {
	users, err := s.queries.ListUsers(c)
	if err != nil {
		c.HTML(http.StatusInternalServerError, "error.html", gin.H{
			"error": err.Error(),
		})
		return
	}
	c.HTML(http.StatusOK, "users.html", gin.H{
		"users": users,
	})
}

func (s *Server) Statistics(c *gin.Context) {

	now := time.Now()

	thirtyDaysAgo := time.Date(now.Year(), now.Month(), now.Day()-30, 0, 0, 0, 0, now.Location())

	quiz_runs, err := s.queries.GetQuizRunsSinceDate(c, pgtype.Timestamptz{Time: thirtyDaysAgo, Valid: true})

	if err != nil {
		c.HTML(http.StatusInternalServerError, "error.html", gin.H{
			"error": err.Error(),
		})
		return
	}

	var quiz_runs_IDs []int32
	for _, quiz_run := range quiz_runs {
		quiz_runs_IDs = append(quiz_runs_IDs, int32(quiz_run.ID))
	}

	user_quiz_questions, err := s.queries.GetQuizQuestionsWhereIDIsIn(c, quiz_runs_IDs)

	correct_answers := 0.0

	for _, user_quiz_question := range user_quiz_questions {
		if user_quiz_question.GivenAnswer.String == user_quiz_question.CorrectAnswer {
			correct_answers = correct_answers + 1
		}
	}
	error_rate := (1 - (correct_answers / float64(len(user_quiz_questions)))) * 100

	if err != nil {
		c.HTML(http.StatusInternalServerError, "error.html", gin.H{
			"error": err.Error(),
		})
		return
	}

	quiz_runs_per_day, err := s.queries.GetAmountQuizRunsPerDaySinceDate(c, pgtype.Timestamptz{Time: thirtyDaysAgo, Valid: true})

	if err != nil {
		c.HTML(http.StatusInternalServerError, "error.html", gin.H{
			"error": err.Error(),
		})
		return
	}

	// Fill in missing days
	for i := 0; i < 31; i++ {
		date := thirtyDaysAgo.AddDate(0, 0, i)
		found := false
		for _, quiz_run_per_day := range quiz_runs_per_day {
			found = false
			if quiz_run_per_day.Date.Time.Day() == date.Day() {
				found = true
				break
			}
		}
		if !found {
			quiz_runs_per_day = append(quiz_runs_per_day, db.GetAmountQuizRunsPerDaySinceDateRow{
				Date:   pgtype.Date{Time: date, Valid: true},
				Amount: 0,
			})
		}
	}
	sort.Slice(quiz_runs_per_day, func(i, j int) bool {
		return quiz_runs_per_day[i].Date.Time.Before(quiz_runs_per_day[j].Date.Time)
	})

	mostDifficultQuestions, err := s.queries.GetMostDifficultQuestions(c, 5)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	mostEasiestQuestions, err := s.queries.GetMostEasiestQuestions(c, 5)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.HTML(http.StatusOK, "statistics.html", gin.H{
		"quiz_runs":                quiz_runs,
		"user_quiz_questions":      user_quiz_questions,
		"error_rate":               error_rate,
		"quiz_runs_per_day":        quiz_runs_per_day,
		"most_difficult_questions": mostDifficultQuestions,
		"most_easiest_questions":   mostEasiestQuestions,
	})
}
