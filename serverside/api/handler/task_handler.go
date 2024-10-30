package api

import (
	api_models "logic_app_backend/api/models"
	db "logic_app_backend/internal/database"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func (s *APIServer) getQuestions(c *gin.Context) {
	var questions []db.Question
	var err error
	limit := c.Query("limit")
	if limit == "" {
		questions, err = s.queries.ListQuestions(c)
	} else {
		limitInt, conversionErr := strconv.ParseInt(limit, 10, 32)
		if conversionErr != nil {
			c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": conversionErr.Error()})
			return
		}
		questions, err = s.queries.ListQuestionsRandomWithLimit(c, int32(limitInt))
	}
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, questions)
}

func (s *APIServer) addQuestion(c *gin.Context) {
	var json api_models.PostQuestion
	if err := c.ShouldBindJSON(&json); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	question, err := s.queries.CreateQuestion(c, db.CreateQuestionParams{
		Question:        json.Question,
		CorrectAnswer:   json.CorrectAnswer,
		PossibleAnswers: json.PossibleAnswers,
	})

	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, question)
}

func (s *APIServer) deleteQuestion(c *gin.Context) {
	id := c.Param("id")

	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = s.queries.DeleteQuestion(c, idInt)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusOK)
}
