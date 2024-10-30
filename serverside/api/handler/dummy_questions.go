package api

import db "logic_app_backend/internal/database"

var DUMMY_QUESTIONS = []db.CreateQuestionParams{
	{
		Question:      "What is the equivalent formula to ((NOT P) AND (S OR Q))?",
		CorrectAnswer: "(((NOT P) AND S) OR ((NOT P) AND Q))",
		PossibleAnswers: []string{
			"(((NOT P) OR Q) AND ((NOT P) OR S))",
			"((((NOT P) AND S) AND (NOT P)) OR (((NOT P) AND S) AND Q))",
			"((((NOT P) OR S) AND (NOT P)) OR (((NOT P) OR S) AND Q))",
		},
	},
	{
		Question:      "What is the equivalent formula to ((NOT S) AND (R OR T))?",
		CorrectAnswer: "(((NOT S) AND R) OR ((NOT S) AND T))",
		PossibleAnswers: []string{
			"((((NOT S) OR R) AND (NOT S)) OR (((NOT S) OR R) AND T))",
			"(((NOT S) OR R) AND ((NOT S) OR T))",
			"((((NOT S) AND R) AND (NOT S)) OR (((NOT S) AND R) AND T))",
		},
	},
	{
		Question:      "What is the equivalent formula to (((NOT P) OR S) AND (T OR Q))?",
		CorrectAnswer: "(((T OR Q) AND (NOT P)) OR ((T OR Q) AND S))",
		PossibleAnswers: []string{
			"((((NOT P) OR S) OR T) AND (((NOT P) OR S) OR Q))",
			"(((((NOT P) OR S) OR T) AND ((NOT P) OR S)) OR ((((NOT P) OR S) OR T) AND Q))",
			"(((T OR Q) OR (NOT P)) AND ((T OR Q) OR S))",
		},
	},
	{
		Question:      "What is the equivalent formula to ((S OR S) AND (P AND R))?",
		CorrectAnswer: "((P AND R) AND (S OR S))",
		PossibleAnswers: []string{
			"(((P AND R) OR S) AND ((P AND R) OR S))",
			"((P AND R) OR S)",
			"((((P AND R) OR S) AND (P AND R)) OR (((P AND R) OR S) AND S))",
		},
	},
	{
		Question:      "What is the equivalent formula to (T AND (S OR S))?",
		CorrectAnswer: "((T AND S) OR (T AND S))",
		PossibleAnswers: []string{
			"((T OR S) AND (T OR S))",
			"(((T OR S) AND T) OR ((T OR S) AND S))",
			"(((T OR S) AND S) OR ((T OR S) AND T))",
		},
	},
	{
		Question:      "What is the equivalent formula to ((NOT T) AND ((NOT P) OR T))?",
		CorrectAnswer: "(((NOT T) AND (NOT P)) OR ((NOT T) AND T))",
		PossibleAnswers: []string{
			"(((NOT T) OR (NOT P)) AND ((NOT T) OR T))",
			"(((NOT T) OR T) AND ((NOT T) OR (NOT P)))",
			"((((NOT T) OR (NOT P)) AND (NOT T)) OR (((NOT T) OR (NOT P)) AND T))",
		},
	},
	{
		Question:      "What is the equivalent formula to ((S AND Q) OR (Q AND R))?",
		CorrectAnswer: "((((S AND Q) OR R) AND (S AND Q)) OR (((S AND Q) OR R) AND Q))",
		PossibleAnswers: []string{
			"((((S AND Q) AND Q) OR (S AND Q)) AND (((S AND Q) AND Q) OR R))",
			"(((S AND Q) AND Q) OR ((S AND Q) AND R))",
			"(((S AND Q) AND R) OR ((S AND Q) AND Q))",
		},
	},
	{
		Question:      "What is the equivalent formula to ((S OR S) OR (Q AND P))?",
		CorrectAnswer: "(((S OR S) OR Q) AND ((S OR S) OR P))",
		PossibleAnswers: []string{
			"((((S OR S) OR P) OR (S OR S)) AND (((S OR S) OR P) OR Q))",
			"(((S OR S) AND Q) OR ((S OR S) AND P))",
			"(((S OR S) AND P) OR ((S OR S) AND Q))",
		},
	},
	{
		Question:      "What is the equivalent formula to ((T AND (NOT R)) OR (T OR (NOT T)))?",
		CorrectAnswer: "(((T OR (NOT T)) OR T) AND ((T OR (NOT T)) OR (NOT R)))",
		PossibleAnswers: []string{
			"(((T AND R) AND R) OR ((T AND R) AND R))",
			"((T AND R) AND R)",
			"((((T AND R) AND R) OR (T AND R)) AND (((T AND R) AND R) OR R))",
		},
	},
	{
		Question:      "What is the equivalent formula to ((NOT P) OR ((NOT T) AND S))?",
		CorrectAnswer: "(((NOT P) OR (NOT T)) AND ((NOT P) OR S))",
		PossibleAnswers: []string{
			"(((((NOT P) OR (NOT T)) AND (NOT P)) AND ((NOT P) OR (NOT T))) OR ((((NOT P) OR (NOT T)) AND (NOT P)) AND S))",
			"(((NOT P) AND (NOT T)) OR ((NOT P) AND S))",
			"((((NOT P) AND (NOT T)) OR (NOT P)) AND (((NOT P) AND (NOT T)) OR S))",
		},
	},
}
