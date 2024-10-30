package config

import (
	"log"

	"github.com/spf13/viper"
)

/***************************************************************************************
*    Title: Use of this config and LoadConfig function
*    Author: https://github.com/aliml92
*    Date: 2023
*    Code version: -
*    Availability: https://github.com/aliml92/realworld-gin-sqlc/blob/f01271b55086265c3e07191fff469f4b902ecf96/config/config.go
*	 Note: I have used the Config Struct (configured for my needs) and LoadConfig function from this repository
***************************************************************************************/

type Config struct {
	DB_USERNAME      string `mapstructure:"DB_USERNAME"`
	DB_PASSWORD      string `mapstructure:"DB_PASSWORD"`
	DB_HOST          string `mapstructure:"DB_HOST"`
	DB_PORT          string `mapstructure:"DB_PORT"`
	DB_NAME          string `mapstructure:"DB_NAME"`
	JWT_SECRET_KEY   string `mapstructure:"JWT_SECRET_KEY"`
	JWT_IDENTITY_KEY string `mapstructure:"JWT_IDENTITY_KEY"`
}

func LoadConfig(name string, path string) (config Config) {
	viper.AddConfigPath(path)
	viper.SetConfigName(name)
	viper.SetConfigType("env")

	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		log.Fatalf("config: %v", err)
		return
	}
	if err := viper.Unmarshal(&config); err != nil {
		log.Fatalf("config: %v", err)
		return
	}
	return
}
