# Tasks generator

The tasks generator is part of the [serverside](../serverside/) folder.
To generate tasks, you need to run `go run cmd/task_generation/main.go` in the [serverside](../serverside/) folder.
Make sure the environment variables are set correctly for the database, as the generator will save the tasks in the database.
The default environment file used when the project is started is [../serverside/env/dev.env](../serverside/env/dev.env).
When nothing changed so far the default values should be fine.

Additionally, the generator will create a `tasks.json` in the folder from where it was executed to see the generated tasks.

## Modify the generator

Have a look into the `main.go` file in the [task generation cmd folder](../serverside/cmd/task_generation/) folder.
You will see something similar like this:
```go
taskGenerator := task_generation.TaskGenerator{
	Rng:         rng,
	Connectives: []string{"AND", "OR"},
	// Connectives:         []string{"AND", "OR", "↔", "→"} // this works also but we do not have transformation rules for ↔ and → yet
	Variables:           []string{"P", "Q", "R", "S", "T"},
	NotProbability:      0.3,
	MinDepth:            1,
	MaxDepth:            2,
	AmountOfLawsToApply: 3,
	AmountWrongFormulas: 3,
	MaxFailedTries:      10,
}
```

| Parameter    | Explanation |
| -------- | ------- |
| Connectives  | The connectives with which the formulas should be randomly generated. There are the following: `AND`, `OR`, `↔` (if and only if), `→` (implies). All can be used, but transformation rules exist only for `AND` and `OR`.   |
| Variables | The variables to be used to generate randomly the formulas. Variables are randomly used, so not all variables will be used for each formula.    |
| NotProbability    | The probability that when a random variable is added to the formula that is negated.    |
| MinDepth | Minimum amount of iterations.    |
| MaxDepth    | Maximum amount of iterations.     |
| AmountOfLawsToApply    | Amount of laws/transformations should be applied to generate an equivalent or wrong formulas.     |
| AmountWrongFormulas    | How many wrong formulas should be generated for a formula (the quiz expects typically 3)     |
| MaxFailedTries    | How often to try to generate an equivalent formula or wrong formulas. For example, for wrong transformations, transformations are applied with small errors, but it is possible that the formula is still equivalent.     |

Then the tasks are generated with the given parameters and saved in the database.
The amount of tasks to generate can be set by changing the parameter of the GenerateTasks function.

```go
tasks := taskGenerator.GenerateTasks(200)
```