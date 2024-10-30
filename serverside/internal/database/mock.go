package database

import (
	"context"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/stretchr/testify/mock"
)

type MockQuerier struct {
	mock.Mock
}

// All Methods needs to be listed here from the Querier interface in order the mock to work
// https://github.com/stretchr/testify/#mock-package

func (m *MockQuerier) AddQuizQuestion(ctx context.Context, arg AddQuizQuestionParams) (UserQuizQuestion, error) {
	args := m.Called(ctx, arg)
	return args.Get(0).(UserQuizQuestion), args.Error(1)
}

func (m *MockQuerier) AddQuizRun(ctx context.Context, userID pgtype.Int8) (UserQuizRun, error) {
	args := m.Called(ctx, userID)
	return args.Get(0).(UserQuizRun), args.Error(1)
}

func (m *MockQuerier) CreateQuestion(ctx context.Context, arg CreateQuestionParams) (Question, error) {
	args := m.Called(ctx, arg)
	return args.Get(0).(Question), args.Error(1)
}

func (m *MockQuerier) CreateUser(ctx context.Context, arg CreateUserParams) (User, error) {
	args := m.Called(ctx, arg)
	return args.Get(0).(User), args.Error(1)
}

func (m *MockQuerier) DeleteQuestion(ctx context.Context, id int64) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockQuerier) DeleteUser(ctx context.Context, id int64) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockQuerier) GetAllQuizRuns(ctx context.Context) ([]UserQuizRun, error) {
	args := m.Called(ctx)
	return args.Get(0).([]UserQuizRun), args.Error(1)
}

func (m *MockQuerier) GetAmountQuizRunsPerDaySinceDate(ctx context.Context, createdAt pgtype.Timestamptz) ([]GetAmountQuizRunsPerDaySinceDateRow, error) {
	args := m.Called(ctx, createdAt)
	return args.Get(0).([]GetAmountQuizRunsPerDaySinceDateRow), args.Error(1)
}

func (m *MockQuerier) GetQuizQuestions(ctx context.Context, userQuizRunID pgtype.Int8) ([]UserQuizQuestion, error) {
	args := m.Called(ctx, userQuizRunID)
	return args.Get(0).([]UserQuizQuestion), args.Error(1)
}

func (m *MockQuerier) GetQuizQuestionsWhereIDIsIn(ctx context.Context, dollar_1 []int32) ([]UserQuizQuestion, error) {
	args := m.Called(ctx, dollar_1)
	return args.Get(0).([]UserQuizQuestion), args.Error(1)
}

func (m *MockQuerier) GetQuizRuns(ctx context.Context, userID pgtype.Int8) ([]UserQuizRun, error) {
	args := m.Called(ctx, userID)
	return args.Get(0).([]UserQuizRun), args.Error(1)
}

func (m *MockQuerier) GetQuizRunsSinceDate(ctx context.Context, createdAt pgtype.Timestamptz) ([]UserQuizRun, error) {
	args := m.Called(ctx, createdAt)
	return args.Get(0).([]UserQuizRun), args.Error(1)
}

func (m *MockQuerier) GetQuizRunsWithLimit(ctx context.Context, arg GetQuizRunsWithLimitParams) ([]UserQuizRun, error) {
	args := m.Called(ctx, arg)
	return args.Get(0).([]UserQuizRun), args.Error(1)
}

func (m *MockQuerier) GetUser(ctx context.Context, id int64) (User, error) {
	args := m.Called(ctx, id)
	return args.Get(0).(User), args.Error(1)
}

func (m *MockQuerier) GetUserByEmail(ctx context.Context, email string) (User, error) {
	args := m.Called(ctx, email)
	return args.Get(0).(User), args.Error(1)
}

func (m *MockQuerier) GetUserByUsername(ctx context.Context, username string) (User, error) {
	args := m.Called(ctx, username)
	return args.Get(0).(User), args.Error(1)
}

func (m *MockQuerier) GetUserQuizRunRanking(ctx context.Context, limit int32) ([]GetUserQuizRunRankingRow, error) {
	args := m.Called(ctx, limit)
	return args.Get(0).([]GetUserQuizRunRankingRow), args.Error(1)
}

func (m *MockQuerier) ListQuestions(ctx context.Context) ([]Question, error) {
	args := m.Called(ctx)
	return args.Get(0).([]Question), args.Error(1)
}

func (m *MockQuerier) ListQuestionsRandomWithLimit(ctx context.Context, limit int32) ([]Question, error) {
	args := m.Called(ctx, limit)
	return args.Get(0).([]Question), args.Error(1)
}

func (m *MockQuerier) ListUsers(ctx context.Context) ([]User, error) {
	args := m.Called(ctx)
	return args.Get(0).([]User), args.Error(1)
}

func (m *MockQuerier) UpdateCredentials(ctx context.Context, arg UpdateCredentialsParams) error {
	args := m.Called(ctx, arg)
	return args.Error(0)
}

func (m *MockQuerier) GetMostDifficultQuestions(ctx context.Context, limit int32) ([]GetMostDifficultQuestionsRow, error) {
	args := m.Called(ctx, limit)
	return args.Get(0).([]GetMostDifficultQuestionsRow), args.Error(1)
}

func (m *MockQuerier) GetMostEasiestQuestions(ctx context.Context, limit int32) ([]GetMostEasiestQuestionsRow, error) {
	args := m.Called(ctx, limit)
	return args.Get(0).([]GetMostEasiestQuestionsRow), args.Error(1)
}

func (m *MockQuerier) GetQuizRunsRatioAndTimeSinceDateFromUser(ctx context.Context, arg GetQuizRunsRatioAndTimeSinceDateFromUserParams) ([]GetQuizRunsRatioAndTimeSinceDateFromUserRow, error) {
	args := m.Called(ctx, arg)
	return args.Get(0).([]GetQuizRunsRatioAndTimeSinceDateFromUserRow), args.Error(1)
}
