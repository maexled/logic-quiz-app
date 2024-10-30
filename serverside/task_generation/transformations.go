package task_generation

// De Morgan's Law
func applyDeMorgansLaw(f Formula) Formula {
	if u, ok := f.(Unary); ok {
		if b, ok := u.Sub.(Binary); ok {
			if b.Op == "AND" {
				return Binary{"OR", Unary{"NOT", b.Left}, Unary{"NOT", b.Right}}
			} else if b.Op == "OR" {
				return Binary{"AND", Unary{"NOT", b.Left}, Unary{"NOT", b.Right}}
			}
		}
	}
	return f
}

// De Morgan's Law with a wrong transformation by swapping AND and OR
func applyDeMorgansLawWrong(f Formula) Formula {
	if u, ok := f.(Unary); ok {
		if b, ok := u.Sub.(Binary); ok {
			if b.Op == "AND" {
				return Binary{"AND", Unary{"NOT", b.Left}, Unary{"NOT", b.Right}}
			} else if b.Op == "OR" {
				return Binary{"OR", Unary{"NOT", b.Left}, Unary{"NOT", b.Right}}
			}
		}
	}
	return f
}

// Commutative Law
func applyCommutativeLaw(f Formula) Formula {
	if b, ok := f.(Binary); ok {
		if b.Op == "AND" || b.Op == "OR" {
			return Binary{b.Op, b.Right, b.Left}
		}
	}
	return f
}

// Distributive Law
func applyDistributiveLaw(f Formula) Formula {
	if b, ok := f.(Binary); ok {
		if b.Op == "AND" {
			// A AND (B OR C) -> (A AND B) OR (A AND C)
			if inner, ok := b.Right.(Binary); ok && inner.Op == "OR" {
				return Binary{"OR", Binary{"AND", b.Left, inner.Left}, Binary{"AND", b.Left, inner.Right}}
			}
		} else if b.Op == "OR" {
			// A OR (B AND C) -> (A OR B) AND (A OR C)
			if inner, ok := b.Right.(Binary); ok && inner.Op == "AND" {
				return Binary{"AND", Binary{"OR", b.Left, inner.Left}, Binary{"OR", b.Left, inner.Right}}
			}
		}
	}
	return f
}

func applyDistributiveLawWrong(f Formula) Formula {
	if b, ok := f.(Binary); ok {
		if b.Op == "AND" {
			if inner, ok := b.Right.(Binary); ok && inner.Op == "OR" {
				return Binary{"AND", Binary{"OR", b.Left, inner.Left}, Binary{"OR", b.Left, inner.Right}}
			}
		} else if b.Op == "OR" {
			if inner, ok := b.Right.(Binary); ok && inner.Op == "AND" {
				return Binary{"OR", Binary{"AND", b.Left, inner.Left}, Binary{"AND", b.Left, inner.Right}}
			}
		}
	}
	return f
}

// Idempotent Law
func applyIdempotentLaw(f Formula) Formula {
	if b, ok := f.(Binary); ok {
		// A AND A -> A
		// A OR A -> A
		if b.Left.String() == b.Right.String() {
			return b.Left
		}
	}
	return f
}
