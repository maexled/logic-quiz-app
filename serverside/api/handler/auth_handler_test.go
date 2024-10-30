package api

import (
	"bytes"
	"database/sql"
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

func TestRegister(t *testing.T) {
	mockQueries := new(db.MockQuerier)

	testUser := db.User{
		ID:       1,
		Username: "test",
		Email:    "test@test.com",
	}

	// Set expectations on the mock
	mockQueries.On("CreateUser", mock.Anything, mock.Anything).Return(testUser, nil)
	mockQueries.On("GetUserByUsername", mock.Anything, testUser.Username).Return(db.User{}, sql.ErrNoRows)
	mockQueries.On("GetUserByEmail", mock.Anything, testUser.Email).Return(db.User{}, sql.ErrNoRows)

	config := config.LoadConfig("test", "../../env/")

	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	apiRouter := router.Group("/api")
	apiServer := NewAPIServer(mockQueries, config, false)

	apiServer.SetupAPIRoutes(apiRouter, nil)

	user := api_models.Register{
		Username: "test",
		Password: "test",
		Email:    "test@test.com",
	}
	userJSON, err := json.Marshal(user)
	if err != nil {
		t.Fatalf("Failed to marshal user: %v", err)
	}

	request := httptest.NewRequest(http.MethodPost, "/api/register", bytes.NewReader(userJSON))
	response := httptest.NewRecorder()

	router.ServeHTTP(response, request)

	var got map[string]interface{}
	err = json.Unmarshal(response.Body.Bytes(), &got)
	if err != nil {
		t.Fatalf("Failed to unmarshal response body: %v", err)
	}
	assert.Equal(t, http.StatusOK, response.Code)
}
