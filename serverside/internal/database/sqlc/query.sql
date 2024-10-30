-- name: GetUser :one
SELECT
  *
FROM
  users
WHERE
  id = $1
LIMIT
  1;

-- name: ListUsers :many
SELECT
  *
FROM
  users;

-- name: CreateUser :one
INSERT INTO
  users (username, email, password_hash)
VALUES
  ($1, $2, $3) RETURNING *;

-- name: UpdateCredentials :exec
UPDATE
  users
set
  password_hash = $2
WHERE
  id = $1;

-- name: DeleteUser :exec
DELETE FROM
  users
WHERE
  id = $1;

-- name: GetUserByEmail :one
SELECT
  *
FROM
  users
WHERE
  email = $1
LIMIT
  1;

-- name: GetUserByUsername :one
SELECT
  *
FROM
  users
WHERE
  username = $1
LIMIT
  1;

-- name: ListQuestions :many
SELECT
  *
FROM
  questions;

-- name: ListQuestionsRandomWithLimit :many
SELECT
  *
FROM
  questions
ORDER BY
  RANDOM()
LIMIT
  $1;

-- name: CreateQuestion :one
INSERT INTO
  questions (question, possible_answers, correct_answer)
VALUES
  ($1, $2, $3) RETURNING *;

-- name: DeleteQuestion :exec
DELETE FROM questions WHERE id = $1;

-- name: AddQuizRun :one
INSERT INTO
  user_quiz_runs (user_id)
VALUES
  ($1) RETURNING *;

-- name: AddQuizQuestion :one
INSERT INTO
  user_quiz_questions (
    user_quiz_run_id,
    question,
    wrong_answers,
    correct_answer,
    given_answer,
    time_needed
  )
VALUES
  ($1, $2, $3, $4, $5, $6) RETURNING *;

-- name: GetQuizRuns :many
SELECT
  *
FROM
  user_quiz_runs
WHERE
  user_id = $1
ORDER BY 
  created_at DESC;

-- name: GetAllQuizRuns :many
SELECT
  *
FROM
  user_quiz_runs
ORDER BY 
  created_at DESC;

-- name: GetQuizRunsSinceDate :many
SELECT
  *
FROM
  user_quiz_runs
WHERE
  created_at >= $1
ORDER BY 
  created_at DESC;

-- name: GetQuizRunsRatioAndTimeSinceDateFromUser :many
SELECT
  user_quiz_runs.id AS quiz_run_id,
  COUNT(*) FILTER (
    WHERE
      user_quiz_questions.given_answer = user_quiz_questions.correct_answer
  ) AS correct_answers_count,
  COUNT(*) AS total_questions_count,
  SUM(user_quiz_questions.time_needed) AS total_time
FROM
  user_quiz_runs JOIN user_quiz_questions ON user_quiz_runs.id = user_quiz_questions.user_quiz_run_id
WHERE
  user_id = $1
AND
  created_at >= $2
GROUP BY
  user_quiz_runs.id
ORDER BY
  created_at DESC;

-- name: GetAmountQuizRunsPerDaySinceDate :many
SELECT
  DATE(created_at) AS date,
  COUNT(*) AS amount
FROM
  user_quiz_runs
WHERE
  created_at >= $1
GROUP BY
  date;

-- name: GetQuizRunsWithLimit :many
SELECT
  *
FROM
  user_quiz_runs
WHERE
  user_id = $1
ORDER BY
  created_at DESC
LIMIT
  $2;

-- name: GetQuizQuestions :many
SELECT
  *
FROM
  user_quiz_questions
WHERE
  user_quiz_run_id = $1;

-- name: GetMostDifficultQuestions :many
SELECT
  question, 
  correct_answer, 
  SUM(CASE WHEN correct_answer = given_answer THEN 1 ELSE 0 END) AS correct_count,
  COUNT(question) AS total_count,
  (SUM(CASE WHEN correct_answer = given_answer THEN 1 ELSE 0 END) * 100 / COUNT(question))::float AS ratio
FROM
  user_quiz_questions
GROUP BY
  question, correct_answer
ORDER BY
  ratio DESC
LIMIT
  $1;

-- name: GetMostEasiestQuestions :many
SELECT
  question, 
  correct_answer, 
  SUM(CASE WHEN correct_answer = given_answer THEN 1 ELSE 0 END) AS correct_count,
  COUNT(question) AS total_count,
  (SUM(CASE WHEN correct_answer = given_answer THEN 1 ELSE 0 END) * 100 / COUNT(question))::float AS ratio
FROM
  user_quiz_questions
GROUP BY
  question, correct_answer
ORDER BY
  ratio ASC
LIMIT
  $1;

-- name: GetQuizQuestionsWhereIDIsIn :many
SELECT
  *
FROM
  user_quiz_questions
WHERE
  user_quiz_run_id = ANY($1::int[]);

-- name: GetUserQuizRunRanking :many
WITH user_quiz_runs_aggregate AS (
  SELECT
    user_quiz_runs.user_id AS user_id,
    users.username AS username,
    user_quiz_runs.id AS quiz_run_id,
    SUM(user_quiz_questions.time_needed) AS total_time,
    COUNT(*) FILTER (
      WHERE
        user_quiz_questions.given_answer = user_quiz_questions.correct_answer
    ) AS correct_answers_count,
    COUNT(*) AS total_questions_count
  FROM
    user_quiz_questions
    JOIN user_quiz_runs ON user_quiz_runs.id = user_quiz_questions.user_quiz_run_id
    JOIN users ON users.id = user_quiz_runs.user_id
  WHERE 
    user_id IS NOT NULL
  GROUP BY
    user_quiz_runs.user_id,
    users.username,
    user_quiz_runs.id
),
ranked_user_quiz_runs AS (
  SELECT
    user_id,
    username,
    total_time,
    correct_answers_count,
    total_questions_count,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY
        correct_answers_count DESC,
        total_time ASC
    ) AS user_quiz_rank -- rank per user their quiz runs
  FROM
    user_quiz_runs_aggregate
)
SELECT
  user_id,
  username,
  total_time,
  correct_answers_count,
  total_questions_count,
  RANK () OVER (
    ORDER BY
      correct_answers_count DESC,
      total_time ASC
  ) AS rank -- rank each user based on each users best quiz run
FROM
  ranked_user_quiz_runs
WHERE
  user_quiz_rank = 1 -- select per user only their best quiz run
ORDER BY
  correct_answers_count DESC
LIMIT
  $1;