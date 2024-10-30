package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"logic_app_backend/config"
	db "logic_app_backend/internal/database"
	"logic_app_backend/task_generation"
	"math/rand"
	"os"
	"time"
)

func main() {
	config := config.LoadConfig("test", "./env/")

	dbConn := db.Connect(&config)
	defer db.Close(dbConn)

	queries := db.New(dbConn)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	taskGenerator := task_generation.TaskGenerator{
		Rng:         rng,
		Connectives: []string{"AND", "OR"},
		// Connectives:         []string{"AND", "OR", "↔", "→"}, // this works also but we do not have transformation rules for ↔ and → yet
		Variables:           []string{"P", "Q", "R", "S", "T"},
		NotProbability:      0.3,
		MinDepth:            1,
		MaxDepth:            2,
		AmountOfLawsToApply: 3,
		AmountWrongFormulas: 3,
		MaxFailedTries:      10,
	}
	tasks := taskGenerator.GenerateTasks(200)

	for task := range tasks {
		question := "What is the equivalent formula to " + tasks[task].OriginalFormula + "?"
		queries.CreateQuestion(ctx, db.CreateQuestionParams{Question: question, PossibleAnswers: tasks[task].WrongTransformedFormulas, CorrectAnswer: tasks[task].CorrectTransformedFormula})
	}
	fmt.Println("Tasks successfully generated and saved to the database")

	saveAsJson(tasks)
}

func saveAsJson(tasks []task_generation.PropositionalLogicTask) {
	content, err := json.MarshalIndent(tasks, "", "    ")
	if err != nil {
		fmt.Println(err)
	}

	err = os.WriteFile("tasks.json", content, 0644)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Data successfully written to tasks.json")
}
