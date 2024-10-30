package task_generation

import (
	"fmt"
	"slices"
	"strings"

	"github.com/Knetic/govaluate"
	"github.com/zaataylor/cartesian/cartesian"
)

func getExpressionFromString(text string) *govaluate.EvaluableExpression {
	text = strings.ReplaceAll(text, "AND", "&&")
	text = strings.ReplaceAll(text, "OR", "||")
	text = strings.ReplaceAll(text, "NOT", "!")
	text = strings.ReplaceAll(text, "↔", "==")
	expression, _ := govaluate.NewEvaluableExpression(text)
	return expression
}

// Returns all unique variables in the expression
func getVariables(expression *govaluate.EvaluableExpression) []string {
	variables := expression.Vars()
	slices.Sort(variables)
	variables = slices.Compact(variables)
	return variables
}

// Returns the truth table of the expression as a map with the parameters as keys and the result as values
func getTruthTable(expression *govaluate.EvaluableExpression, variables []string) map[string]interface{} {
	cartesianProductInputSlices := make([]interface{}, 0)
	for range variables {
		cartesianProductInputSlices = append(cartesianProductInputSlices, []bool{true, false})
	}

	cartesianProduct := cartesian.NewCartesianProduct(cartesianProductInputSlices)
	cartesianProductIterator := cartesianProduct.Iterator()

	truthTable := make(map[string]interface{}, 0)
	for cartesianProductIterator.HasNext() {
		parameters := make(map[string]interface{}, len(variables))
		value := cartesianProductIterator.Next()
		for i, p := range value {
			parameters[variables[i]] = p.(bool)
		}
		result, err := expression.Evaluate(parameters)
		if err != nil {
			fmt.Println("Error evaluating expression")
			fmt.Println("Parameters: " + fmt.Sprint(parameters))
			fmt.Println("Expression: " + expression.String())
			fmt.Println(err)
		}
		truthTable[fmt.Sprint(parameters)] = result
	}
	return truthTable
}

// Returns true if the two truth tables are the same
func isSameTruthTable(truthTable1 map[string]interface{}, truthTable2 map[string]interface{}) bool {
	if len(truthTable1) != len(truthTable2) {
		return false
	}
	for k, v := range truthTable1 {
		if v != truthTable2[k] {
			return false
		}
	}
	return true
}

// Returns true if the two formulas are equivalent but must not be necessarily the same
//
// String formulas only support the following operators:
// - AND
// - OR
// - NOT
// - ↔ (if and only if)
func AreStringFormulasEquivalent(formula1 string, formula2 string) bool {
	expression1 := getExpressionFromString(formula1)
	variables1 := getVariables(expression1)
	truthTable1 := getTruthTable(expression1, variables1)

	expression2 := getExpressionFromString(formula2)
	variables2 := getVariables(expression2)
	truthTable2 := getTruthTable(expression2, variables2)

	return isSameTruthTable(truthTable1, truthTable2)
}

func AreFormulasEquivalent(formula1 Formula, formula2 Formula) bool {
	// need to remove all → operators because the govaluate library can not handle this operator
	if b, ok := formula1.(Binary); ok {
		formula1 = b.ImpliesToOrFormula()
	}
	if u, ok := formula1.(Unary); ok {
		formula1 = u.ImpliesToOrFormula()
	}
	if b, ok := formula2.(Binary); ok {
		formula2 = b.ImpliesToOrFormula()
	}
	if u, ok := formula2.(Unary); ok {
		formula2 = u.ImpliesToOrFormula()
	}
	return AreStringFormulasEquivalent(formula1.String(), formula2.String())
}
