package task_generation

import "fmt"

type Formula interface {
	String() string
}

type Variable struct {
	Name string
}

type Unary struct {
	Op  string
	Sub Formula
}

type Binary struct {
	Op    string
	Left  Formula
	Right Formula
}

type PropositionalLogicTask struct {
	OriginalFormula           string   `json:"originalFormula"`
	CorrectTransformedFormula string   `json:"correctTransformedFormula"`
	WrongTransformedFormulas  []string `json:"wrongTransformedFormulas"`
}

func (v Variable) String() string {
	return v.Name
}

func (u Unary) String() string {
	return fmt.Sprintf("(NOT %s)", u.Sub.String())
}

func (b Binary) String() string {
	return fmt.Sprintf("(%s %s %s)", b.Left.String(), b.Op, b.Right.String())
}

// Finds all sub-formulas and replace formulas with "↔" operator with OR and AND operators
// e.g. (A ↔ B) becomes ((¬A ∨ B) ∧ (¬B ∨ A))
func (b Binary) IfAndOnlyIfToOrAndAndFormula() Binary {
	if b.Op == "↔" {
		b = Binary{"AND", Binary{"OR", b.Left, Unary{"NOT", b.Right}}, Binary{"OR", Unary{"NOT", b.Left}, b.Right}}
	}
	if left, ok := b.Left.(Binary); ok {
		b = Binary{b.Op, left.IfAndOnlyIfToOrAndAndFormula(), b.Right}
	}
	if right, ok := b.Right.(Binary); ok {
		b = Binary{b.Op, b.Left, right.IfAndOnlyIfToOrAndAndFormula()}
	}
	return b
}

// Finds all sub-formulas and replace formulas with "→" operator with OR operator
// e.g. (A → B) becomes (¬A ∨ B)
func (b Binary) ImpliesToOrFormula() Binary {
	if b.Op == "→" {
		b = Binary{"OR", Unary{"NOT", b.Left}, b.Right}
	}
	if left, ok := b.Left.(Binary); ok {
		b = Binary{b.Op, left.ImpliesToOrFormula(), b.Right}
	}
	if left, ok := b.Left.(Unary); ok {
		b = Binary{b.Op, left.ImpliesToOrFormula(), b.Right}
	}
	if right, ok := b.Right.(Binary); ok {
		b = Binary{b.Op, b.Left, right.ImpliesToOrFormula()}
	}
	if right, ok := b.Right.(Unary); ok {
		b = Binary{b.Op, b.Left, right.ImpliesToOrFormula()}
	}
	return b
}

// Finds all sub-formulas and replace formulas with "→" operator with OR operator
// e.g. ¬(A → B) becomes ¬(¬A ∨ B)
func (u Unary) ImpliesToOrFormula() Unary {
	if sub, ok := u.Sub.(Binary); ok {
		u = Unary{u.Op, sub.ImpliesToOrFormula()}
	}
	if sub, ok := u.Sub.(Unary); ok {
		u = Unary{u.Op, sub.ImpliesToOrFormula()}
	}
	return u
}
