package main

import (
	"logic_app_backend/config"
	db "logic_app_backend/internal/database"
	"logic_app_backend/internal/server"

	"github.com/gin-gonic/gin"
)

func main() {
	config := config.LoadConfig("test", "./env/")

	dbConn := db.Connect(&config)
	defer db.Close(dbConn)

	queries := db.New(dbConn)

	gin.SetMode(gin.ReleaseMode) // Comment out to enable debug mode
	newServer := server.NewServer(config, queries)

	newServer.SetupRouter(true, true)

	newServer.Start(":5000")
}
