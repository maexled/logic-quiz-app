package server

import (
	"database/sql"
	"log"
	"logic_app_backend/config"
	db "logic_app_backend/internal/database"
	"time"

	jwt "github.com/appleboy/gin-jwt/v2"
	"golang.org/x/crypto/bcrypt"

	"github.com/gin-gonic/gin"
)

func (s *Server) SetupJWTMiddleware() *jwt.GinJWTMiddleware {
	authMiddleware, err := jwt.New(initParams(s.config, s.queries))
	if err != nil {
		log.Fatal("JWT Error:" + err.Error())
	}

	// register middleware
	s.router.Use(handlerMiddleWare(authMiddleware))
	return authMiddleware
}

type login struct {
	Username string `form:"username" json:"username" binding:"required"`
	Password string `form:"password" json:"password" binding:"required"`
}

type User struct {
	ID       int64
	Username string
	Email    string
}

/***************************************************************************************
*    Title: Authentication Middleware for Gin
*    Author: Bo-Yi Wu and the contributors
*    Date: 2024
*    Code version: 2.10.0
*    Availability: https://github.com/appleboy/gin-jwt/blob/6e78f18d09bb38bed2678a9e58afcf7002bb00af/README.md#example
*	 Note: The methods below are based on the example code from the GitHub repository. The logic of the authenticator is my work.
***************************************************************************************/

func initParams(config config.Config, queries db.Querier) *jwt.GinJWTMiddleware {
	return &jwt.GinJWTMiddleware{
		Realm:       "logic_app",
		Key:         []byte(config.JWT_SECRET_KEY),
		Timeout:     time.Hour,
		MaxRefresh:  time.Hour,
		IdentityKey: config.JWT_IDENTITY_KEY,
		PayloadFunc: payloadFunc(config.JWT_IDENTITY_KEY),

		IdentityHandler: identityHandler(config.JWT_IDENTITY_KEY),
		Authenticator:   authenticator(queries),
		Authorizator:    authorizator(),
		Unauthorized:    unauthorized(),
		TokenLookup:     "header: Authorization, query: token, cookie: jwt",
		// TokenLookup: "query:token",
		// TokenLookup: "cookie:token",
		TokenHeadName: "Bearer",
		TimeFunc:      time.Now,
	}
}

func handlerMiddleWare(authMiddleware *jwt.GinJWTMiddleware) gin.HandlerFunc {
	return func(context *gin.Context) {
		errInit := authMiddleware.MiddlewareInit()
		if errInit != nil {
			log.Fatal("authMiddleware.MiddlewareInit() Error:" + errInit.Error())
		}
	}
}

func payloadFunc(identityKey string) func(data interface{}) jwt.MapClaims {
	return func(data interface{}) jwt.MapClaims {
		if v, ok := data.(*User); ok {
			return jwt.MapClaims{
				identityKey: v.ID,
			}
		}
		return jwt.MapClaims{}
	}
}

func identityHandler(identityKey string) func(c *gin.Context) interface{} {
	return func(c *gin.Context) interface{} {
		claims := jwt.ExtractClaims(c)
		return &User{
			ID: int64(claims[identityKey].(float64)),
		}
	}
}

func authenticator(queries db.Querier) func(c *gin.Context) (interface{}, error) {
	return func(c *gin.Context) (interface{}, error) {
		var loginVals login
		if err := c.ShouldBind(&loginVals); err != nil {
			log.Println("authenticator error")
			return "", jwt.ErrMissingLoginValues
		}
		username := loginVals.Username
		password := loginVals.Password

		user, err := queries.GetUserByUsername(c, username)
		if err != nil {
			if err == sql.ErrNoRows {
				return nil, jwt.ErrFailedAuthentication
			}
			return nil, jwt.ErrFailedAuthentication
		}
		err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password))
		if err != nil {
			return nil, jwt.ErrFailedAuthentication
		}

		return &User{
			ID:       user.ID,
			Username: user.Username,
			Email:    user.Email,
		}, nil
	}
}

func authorizator() func(data interface{}, c *gin.Context) bool {
	return func(data interface{}, c *gin.Context) bool {
		if _, ok := data.(*User); ok {
			return true
		}
		return false
	}
}

func unauthorized() func(c *gin.Context, code int, message string) {
	return func(c *gin.Context, code int, message string) {
		c.JSON(code, gin.H{
			"error": message,
		})
	}
}
