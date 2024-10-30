package server

import (
	"encoding/json"
	"logic_app_backend/config"
	db "logic_app_backend/internal/database"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestHealth(t *testing.T) {

	mockQueries := new(db.MockQuerier)

	config := config.LoadConfig("test", "../../env/")

	gin.SetMode(gin.ReleaseMode)
	server := NewServer(config, mockQueries)

	server.SetupRouter(false, false)

	request := httptest.NewRequest(http.MethodGet, "/health", nil)
	response := httptest.NewRecorder()

	server.router.ServeHTTP(response, request)

	var got map[string]string
	err := json.Unmarshal(response.Body.Bytes(), &got)
	if err != nil {
		t.Fatalf("Failed to unmarshal response body: %v", err)
	}
	want := map[string]string{"message": "healthy"}

	assert.Equal(t, want, got)
}
