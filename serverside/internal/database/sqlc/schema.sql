CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  -- sqlc: json: "-"
  password_hash text NOT NULL
);

CREATE TABLE questions (
  id BIGSERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  possible_answers TEXT [] NOT NULL,
  correct_answer TEXT NOT NULL
);

CREATE TABLE user_quiz_runs (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE user_quiz_questions (
  id BIGSERIAL PRIMARY KEY,
  user_quiz_run_id BIGINT REFERENCES user_quiz_runs(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  wrong_answers TEXT [] NOT NULL,
  correct_answer TEXT NOT NULL,
  given_answer TEXT,
  time_needed FLOAT
);