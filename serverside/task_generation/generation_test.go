package task_generation

import (
	"math/rand"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestTransformation(t *testing.T) {
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	numberOfTransformations := 3
	taskGenerator := TaskGenerator{
		Rng:                 rng,
		Connectives:         []string{"AND", "OR"},
		Variables:           []string{"A", "B", "C", "D", "E"},
		NotProbability:      0.3,
		MinDepth:            1,
		MaxDepth:            2,
		AmountOfLawsToApply: numberOfTransformations,
		AmountWrongFormulas: 3,
		MaxFailedTries:      10,
	}
	// A AND (B OR C)
	startingFormula := Binary{"AND", Variable{"A"}, Binary{"OR", Variable{"B"}, Variable{"C"}}}
	equivalentFormula, lawsUsed, err := taskGenerator.getTransformedFormula(startingFormula)
	if err != nil {
		t.Error(err)
	}

	assert.Equal(t, len(lawsUsed), numberOfTransformations)
	assert.NotEqual(t, startingFormula.String(), equivalentFormula.String())
	assert.Equal(t, AreStringFormulasEquivalent(startingFormula.String(), equivalentFormula.String()), true)

	wrongFormulas, err := taskGenerator.getWrongTransformedFormulas(startingFormula)
	if err != nil {
		t.Error(err)
	}
	for _, wrongFormula := range wrongFormulas {
		assert.NotEqual(t, startingFormula.String(), wrongFormula.String())
		assert.NotEqual(t, equivalentFormula.String(), wrongFormula.String())
	}
}

func TestTaskGeneration(t *testing.T) {
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	numberOfTransformations := 3
	numberOfWrongFormulas := 3
	taskGenerator := TaskGenerator{
		Rng:                 rng,
		Connectives:         []string{"AND", "OR"},
		Variables:           []string{"A", "B", "C", "D", "E"},
		NotProbability:      0.3,
		MinDepth:            1,
		MaxDepth:            2,
		AmountOfLawsToApply: numberOfTransformations,
		AmountWrongFormulas: numberOfWrongFormulas,
		MaxFailedTries:      10,
	}
	tasks := taskGenerator.GenerateTasks(200)
	assert.Equal(t, len(tasks), 200)
	for _, task := range tasks {
		assert.Equal(t, len(task.WrongTransformedFormulas), numberOfWrongFormulas)
		assert.NotEqual(t, task.OriginalFormula, task.CorrectTransformedFormula)
		// Works as long connective contains not implies
		assert.True(t, AreStringFormulasEquivalent(task.OriginalFormula, task.CorrectTransformedFormula))
		for _, wrongFormula := range task.WrongTransformedFormulas {
			assert.False(t, AreStringFormulasEquivalent(task.OriginalFormula, wrongFormula))
		}
	}
}
