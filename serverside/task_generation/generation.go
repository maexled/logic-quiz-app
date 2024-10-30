package task_generation

import (
	"errors"
	"log"
	"math/rand"
	"strconv"
)

type TaskGenerator struct {
	Rng                 *rand.Rand
	Connectives         []string
	Variables           []string
	NotProbability      float64
	MinDepth            int
	MaxDepth            int
	AmountOfLawsToApply int
	AmountWrongFormulas int
	MaxFailedTries      int
}

func (t TaskGenerator) randomVariable() Variable {
	return Variable{t.Variables[t.Rng.Intn(len(t.Variables))]}
}

func (t TaskGenerator) isValidOperator(op string) bool {
	for _, val := range t.Connectives {
		if val == op {
			return true
		}
	}
	return false
}

func (t TaskGenerator) randomConnective() string {
	if t.isValidOperator("↔") && t.Rng.Float64() < 0.1 {
		return "↔"
	}
	if t.isValidOperator("→") && t.Rng.Float64() < 0.2 {
		return "→"
	}
	return t.Connectives[t.Rng.Intn(len(t.Connectives))]
}

func (t TaskGenerator) maybeAddNot(formula Formula) Formula {
	if t.Rng.Float64() < t.NotProbability {
		return Unary{Op: "NOT", Sub: formula}
	}
	return formula
}

// Recursive formula generation
func (t TaskGenerator) randomFormula(depth int) Formula {
	if depth == t.MaxDepth {
		return t.maybeAddNot(t.randomVariable())
	}

	if depth < t.MinDepth || t.Rng.Float64() < 0.5 {
		left := t.randomFormula(depth + 1)
		right := t.randomFormula(depth + 1)
		connective := t.randomConnective()
		return Binary{Op: connective, Left: left, Right: right}
	}

	return t.maybeAddNot(t.randomVariable())
}

// Apply several random transformation rules to create an equivalent formula
func (t TaskGenerator) applyRandomTransformation(f Formula, numberOfTransformations int) (Formula, []string) {
	lawsUsed := make([]string, numberOfTransformations)
	changedFormula := f
	for i := 0; i < numberOfTransformations; i++ {
		switch t.Rng.Intn(4) {
		case 0:
			changedFormula = applyDeMorgansLaw(changedFormula)
			lawsUsed[i] = "De Morgan's Law"
		case 1:
			changedFormula = applyCommutativeLaw(changedFormula)
			lawsUsed[i] = "Commutative Law"
		case 2:
			changedFormula = applyDistributiveLaw(changedFormula)
			lawsUsed[i] = "Distributive Law"
		case 3:
			changedFormula = applyIdempotentLaw(changedFormula)
			lawsUsed[i] = "Idempotent Law"
		default:

		}
	}
	return changedFormula, lawsUsed
}

// Tries to create a nearly equivalent formula by applying a random transformation with a wrong transformation at a random position
func (t TaskGenerator) applyWrongRandomTransformation(f Formula, numberOfTransformations int) (Formula, []string, error) {
	indexWrong := t.Rng.Intn(numberOfTransformations)
	lawsUsed := make([]string, 0)

	correctChangedFormula, laws := t.applyRandomTransformation(f, indexWrong)

	lawsUsed = append(lawsUsed, laws...)

	// apply a wrong transformation
	changedFormula := correctChangedFormula
	switch t.Rng.Intn(2) {
	case 0:
		changedFormula = applyDeMorgansLawWrong(correctChangedFormula)
		lawsUsed = append(lawsUsed, "De Morgan's Law WRONG")
	case 1:
		changedFormula = applyDistributiveLawWrong(correctChangedFormula)
		lawsUsed = append(lawsUsed, "Distributive Law WRONG")
	default:

	}

	currentTry := 0

	for ok := true; ok; ok = correctChangedFormula == changedFormula && currentTry < t.MaxFailedTries {
		switch t.Rng.Intn(2) {
		case 0:
			changedFormula = applyDeMorgansLawWrong(correctChangedFormula)
			lawsUsed = append(lawsUsed, "De Morgan's Law WRONG")
		case 1:
			changedFormula = applyDistributiveLawWrong(correctChangedFormula)
			lawsUsed = append(lawsUsed, "Distributive Law WRONG")
		default:

		}
		currentTry++
	}

	if correctChangedFormula == changedFormula {
		return nil, nil, errors.New("failed to transform the formula after " + strconv.Itoa(t.MaxFailedTries) + " tries to a wrong formula")
	}

	changedFormula, laws = t.applyRandomTransformation(changedFormula, numberOfTransformations-indexWrong-1)
	lawsUsed = append(lawsUsed, laws...)
	return changedFormula, lawsUsed, nil
}

func checkFormularIsSame(f1 Formula, formulas []Formula) bool {
	for _, f2 := range formulas {
		if f1 == f2 {
			return true
		}
	}
	return false
}

// Tries to transform a formula to an equivalent one
func (t TaskGenerator) getTransformedFormula(formula Formula) (Formula, []string, error) {
	currentTry := 0

	transformedFormula, laws := t.applyRandomTransformation(formula, t.AmountOfLawsToApply)
	for ok := true; ok; ok = formula == transformedFormula && currentTry < t.MaxFailedTries {
		transformedFormula, laws = t.applyRandomTransformation(formula, t.AmountOfLawsToApply)
		currentTry++
	}

	if formula == transformedFormula {
		return nil, nil, errors.New("failed to transform the Formula to an equivalent one")
	}
	if !AreFormulasEquivalent(formula, transformedFormula) {
		return nil, nil, errors.New("failed to transform the Formula to an equivalent one: Formulas are not equivalent")
	}
	return transformedFormula, laws, nil
}

// Generate a number of wrong transformed formulas.
//
// It is ensured that the wrong formulas are not the same as the correct formula
// and not the same as each other.
func (t TaskGenerator) getWrongTransformedFormulas(formula Formula) ([]Formula, error) {
	wrongFormulas := make([]Formula, t.AmountWrongFormulas)
	for i := 0; i < t.AmountWrongFormulas; i++ {
		wrongTransformedFormula, _, err := t.applyWrongRandomTransformation(formula, t.AmountOfLawsToApply)
		currentTry := 0

		// Loop as long as the wrong formula is
		// (- the same as an existing wrong formula
		//    OR
		// - equivalent to the correct formula)
		//    AND
		// the maximum number of tries is not reached
		for ok := true; ok; ok = (checkFormularIsSame(wrongTransformedFormula, wrongFormulas) || AreFormulasEquivalent(formula, wrongTransformedFormula)) && currentTry < t.MaxFailedTries {
			wrongTransformedFormula, _, err = t.applyWrongRandomTransformation(formula, t.AmountOfLawsToApply)
			currentTry++
		}

		if err != nil {
			return nil, err
		}

		if checkFormularIsSame(wrongTransformedFormula, wrongFormulas) {
			return nil, errors.New("Failed to Transform wrong the formula to " + strconv.Itoa(t.AmountWrongFormulas) + " wrong formulas: Wrong Formula is the same as an existing one")
		}
		if AreFormulasEquivalent(formula, wrongTransformedFormula) {
			return nil, errors.New("Failed to Transform wrong the formula to " + strconv.Itoa(t.AmountWrongFormulas) + " wrong formulas: Wrong Formula is the same as the correct one")
		}

		wrongFormulas[i] = wrongTransformedFormula
	}
	return wrongFormulas, nil
}

// Check if a starting formula of a task is already in the list of tasks
func isTaskAlreadyInSlice(task PropositionalLogicTask, tasks []PropositionalLogicTask) bool {
	for _, t := range tasks {
		if t.OriginalFormula == task.OriginalFormula {
			return true
		}
	}
	return false
}

// Generate a number of tasks.
//
// Each task consists of an original formula, an equivalent formula and a number (amountWrongFormulas) of wrong transformed formulas.
func (t TaskGenerator) GenerateTasks(amount int) []PropositionalLogicTask {
	if t.MaxDepth <= 1 {
		log.Fatal("MaxDepth must be greater than 1 to generate tasks")
		return nil
	}
	tasks := make([]PropositionalLogicTask, 0)
	for i := 0; i < amount; i++ {
		formula := t.randomFormula(0)

		if isTaskAlreadyInSlice(PropositionalLogicTask{OriginalFormula: formula.String()}, tasks) {
			i = i - 1
			continue
		}

		transformedFormula, _, err := t.getTransformedFormula(formula)

		if err != nil {
			i = i - 1
			continue
		}

		wrongFormulas, err := t.getWrongTransformedFormulas(formula)

		if err != nil {
			i = i - 1
			continue
		}
		wrongFormulasString := make([]string, 0)
		for _, wrongFormula := range wrongFormulas {
			wrongFormulasString = append(wrongFormulasString, wrongFormula.String())
		}

		tasks = append(tasks, PropositionalLogicTask{OriginalFormula: formula.String(), CorrectTransformedFormula: transformedFormula.String(), WrongTransformedFormulas: wrongFormulasString})

	}
	return tasks
}
