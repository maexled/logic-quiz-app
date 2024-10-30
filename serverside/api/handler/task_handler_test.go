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

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestGetQuestions(t *testing.T) {
	mockQueries := new(db.MockQuerier)

	testQuestions := []db.Question{
		{
			ID:              1,
			Question:        "What is the capital of France?",
			CorrectAnswer:   "Paris",
			PossibleAnswers: []string{"London", "Berlin", "Madrid"},
		},
		{
			ID:              2,
			Question:        "What is the capital of Germany?",
			CorrectAnswer:   "Berlin",
			PossibleAnswers: []string{"Paris", "London", "Madrid"},
		},
	}

	// Set expectations on the mock
	mockQueries.On("ListQuestions", mock.Anything).Return(testQuestions, nil)

	config := config.LoadConfig("test", "../../env/")

	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	apiRouter := router.Group("/api")
	apiServer := NewAPIServer(mockQueries, config, false)

	apiServer.SetupAPIRoutes(apiRouter, nil)

	request := httptest.NewRequest(http.MethodGet, "/api/questions", nil)
	response := httptest.NewRecorder()

	router.ServeHTTP(response, request)

	var got []interface{}
	err := json.Unmarshal(response.Body.Bytes(), &got)
	if err != nil {
		t.Fatalf("Failed to unmarshal response body: %v", err)
	}
	assert.Equal(t, http.StatusOK, response.Code)
	assert.Equal(t, len(testQuestions), len(got))

	mockQueries.AssertExpectations(t)
}

func TestAddQuestion(t *testing.T) {
	mockQueries := new(db.MockQuerier)

	testQuestion := db.Question{
		ID:              1,
		Question:        "What is the capital of France?",
		CorrectAnswer:   "Paris",
		PossibleAnswers: []string{"London", "Berlin", "Madrid"},
	}

	// Set expectations on the mock
	mockQueries.On("CreateQuestion", mock.Anything, db.CreateQuestionParams{
		Question:        testQuestion.Question,
		CorrectAnswer:   testQuestion.CorrectAnswer,
		PossibleAnswers: testQuestion.PossibleAnswers,
	}).Return(testQuestion, nil)

	config := config.LoadConfig("test", "../../env/")

	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	apiRouter := router.Group("/api")
	apiServer := NewAPIServer(mockQueries, config, false)

	apiServer.SetupAPIRoutes(apiRouter, nil)

	t.Run("it returns 200 on POST with valid question", func(t *testing.T) {
		question := api_models.PostQuestion{
			Question:        "What is the capital of France?",
			CorrectAnswer:   "Paris",
			PossibleAnswers: []string{"London", "Berlin", "Madrid"},
		}

		questionJSON, err := json.Marshal(question)
		if err != nil {
			t.Fatalf("Failed to marshal question: %v", err)
		}

		request := httptest.NewRequest(http.MethodPost, "/api/questions", bytes.NewReader(questionJSON))
		response := httptest.NewRecorder()

		router.ServeHTTP(response, request)

		var got map[string]interface{}
		err = json.Unmarshal(response.Body.Bytes(), &got)
		if err != nil {
			t.Fatalf("Failed to unmarshal response body: %v", err)
		}
		assert.Equal(t, http.StatusCreated, response.Code)
		assert.Equal(t, testQuestion.Question, got["question"])
		assert.Equal(t, testQuestion.CorrectAnswer, got["correctAnswer"])

		mockQueries.AssertExpectations(t)
	})

	t.Run("it returns 400 on POST with invalid question", func(t *testing.T) {
		request := httptest.NewRequest(http.MethodPost, "/api/questions", bytes.NewReader([]byte("{abc}")))
		response := httptest.NewRecorder()

		router.ServeHTTP(response, request)

		assert.Equal(t, http.StatusBadRequest, response.Code)
	})
}
