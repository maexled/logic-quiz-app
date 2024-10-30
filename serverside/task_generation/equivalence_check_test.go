package task_generation

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestAreStringFormulasEquivalent(t *testing.T) {
	// Test equivalent formulas
	assert.Equal(t, AreStringFormulasEquivalent("A AND B", "B AND A"), true)

	assert.Equal(t, AreStringFormulasEquivalent("A AND B", "A OR B"), false)

	assert.Equal(t, AreStringFormulasEquivalent("A AND B", "A AND B OR C"), false)

	// for our use case this should be not equivalent
	assert.Equal(t, AreStringFormulasEquivalent("A AND B", "C AND D"), false)

	assert.Equal(t, AreStringFormulasEquivalent("A ↔ B", "(A AND B) || ((NOT A) AND (NOT B))"), true)
	assert.Equal(t, AreStringFormulasEquivalent("A ↔ B", "((NOT A) OR B) AND ((NOT B) OR A)"), true)

	assert.Equal(t, AreFormulasEquivalent(Binary{"→", Variable{"A"}, Variable{"B"}}, Binary{"OR", Unary{"NOT", Variable{"A"}}, Variable{"B"}}), true)
	assert.Equal(t, AreFormulasEquivalent(Binary{"→", Variable{"A"}, Variable{"B"}}, Binary{"OR", Unary{"NOT", Variable{"B"}}, Variable{"A"}}), false)
}
