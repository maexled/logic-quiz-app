package api

import (
	"bytes"
	"encoding/json"
	api_models "logic_app_backend/api/models"
	"logic_app_backend/config"
	db "logic_app_backend/internal/database"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestAddQuizRun(t *testing.T) {
	mockQueries := new(db.MockQuerier)

	userID := pgtype.Int8{
		Int64: 0,
		Valid: false,
	}

	// Set expectations on the mock
	mockQueries.On("AddQuizRun", mock.Anything, mock.Anything).Return(db.UserQuizRun{
		ID:     1,
		UserID: userID,
		CreatedAt: pgtype.Timestamptz{
			Time:  time.Now(),
			Valid: true,
		},
	}, nil)
	mockQueries.On("AddQuizQuestion", mock.Anything, mock.Anything).Return(db.UserQuizQuestion{}, nil)

	config := config.LoadConfig("test", "../../env/")

	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	apiRouter := router.Group("/api")
	apiServer := NewAPIServer(mockQueries, config, false)

	apiServer.SetupAPIRoutes(apiRouter, nil)

	t.Run("it returns 200 on POST with quiz run", func(t *testing.T) {
		quizRun := api_models.QuizRun{
			CreatedAt: pgtype.Timestamptz{
				Time:  time.Now(),
				Valid: true,
			},
			QuizRunQuestions: []api_models.QuizRunQuestion{
				{
					Question:              "What is 1 + 1",
					GivenAnswer:           "2",
					WrongAnswers:          []string{"4", "3", "11"},
					CorrectAnswer:         "2",
					TimeSpentCentiseconds: 25,
				},
				{
					Question:              "What is 2 + 2",
					GivenAnswer:           "2",
					WrongAnswers:          []string{"2", "3", "11"},
					CorrectAnswer:         "4",
					TimeSpentCentiseconds: 15,
				},
			},
		}

		quizRunJSON, err := json.Marshal(quizRun)
		if err != nil {
			t.Fatalf("Failed to marshal question: %v", err)
		}

		request := httptest.NewRequest(http.MethodPost, "/api/quiz-runs/anonym", bytes.NewReader(quizRunJSON))
		response := httptest.NewRecorder()

		router.ServeHTTP(response, request)

		assert.Equal(t, http.StatusOK, response.Code)

		var got map[string]interface{}
		err = json.Unmarshal(response.Body.Bytes(), &got)
		if err != nil {
			t.Fatalf("Failed to unmarshal response body: %v", err)
		}

		mockQueries.AssertExpectations(t)
	})
}
