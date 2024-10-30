package database

import (
	"context"
	"log"
	"logic_app_backend/config"

	"github.com/jackc/pgx/v5/pgxpool"
)

func Connect(config *config.Config) *pgxpool.Pool {
	dbUrl := "postgres://" + config.DB_USERNAME + ":" + config.DB_PASSWORD + "@" + config.DB_HOST + ":" + config.DB_PORT + "/" + config.DB_NAME
	pool, err := pgxpool.New(context.Background(), dbUrl)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	return pool
}

func Close(conn *pgxpool.Pool) {
	conn.Close()
}
