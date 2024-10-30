package api

import (
	"database/sql"
	"errors"
	api_models "logic_app_backend/api/models"
	db "logic_app_backend/internal/database"
	"net/http"
	"net/mail"
	"strconv"

	middlewareJWT "github.com/appleboy/gin-jwt/v2"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func (s *APIServer) registerUser(c *gin.Context) {
	var json api_models.Register
	if err := c.ShouldBindJSON(&json); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := mail.ParseAddress(json.Email)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "Invalid email"})
		return
	}

	_, err = s.queries.GetUserByUsername(c, json.Username)
	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	} else {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "Username already taken"})
		return
	}

	_, err = s.queries.GetUserByEmail(c, json.Email)
	if err != nil {
		if !errors.Is(err, sql.ErrNoRows) {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	} else {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "Email already taken"})
		return
	}

	hashedPassword, err := HashPassword(json.Password)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	user, err := s.queries.CreateUser(c, db.CreateUserParams{
		Username:     json.Username,
		Email:        json.Email,
		PasswordHash: hashedPassword,
	})
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, api_models.User{
		ID:       user.ID,
		Username: user.Username,
		Email:    user.Email,
	})
}

func HashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

func (s *APIServer) checkToken(c *gin.Context) {
	claims := middlewareJWT.ExtractClaims(c)

	c.JSON(http.StatusOK, gin.H{
		s.config.JWT_IDENTITY_KEY: claims[s.config.JWT_IDENTITY_KEY],
	})
}

func (s *APIServer) getUsers(c *gin.Context) {
	users, err := s.queries.ListUsers(c)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	var usersWithoutPassword []api_models.User

	for _, user := range users {
		usersWithoutPassword = append(usersWithoutPassword, api_models.User{
			ID:       user.ID,
			Username: user.Username,
			Email:    user.Email,
		})
	}

	c.JSON(http.StatusOK, usersWithoutPassword)
}

func (s *APIServer) deleteUser(c *gin.Context) {
	id := c.Param("id")

	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = s.queries.DeleteUser(c, idInt)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.Status(http.StatusOK)
}

func (s *APIServer) changePassword(c *gin.Context) {
	var json api_models.ChangePassword
	id := c.Param("id")

	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := c.ShouldBindJSON(&json); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	hashedPassword, err := HashPassword(json.Password)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	err = s.queries.UpdateCredentials(c, db.UpdateCredentialsParams{
		ID:           idInt,
		PasswordHash: hashedPassword,
	})

	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusOK)
}
