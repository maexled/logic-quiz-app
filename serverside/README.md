# Logic App Backend

![build status](https://theogit.fmi.uni-stuttgart.de/fapra_ss2024/fp_ss24_kaestnmx/badges/main/pipeline.svg?job=serverside-build&key_text=serverside%20build&key_width=100)
![coverage](https://theogit.fmi.uni-stuttgart.de/fapra_ss2024/fp_ss24_kaestnmx/badges/main/coverage.svg?job=serverside-test)

This is the backend for the Logic App project. 
It is mainly a REST API that is used to interact with the Logic App frontend.
Additionally, it provides HTML pages for the admin interface.

## Usage

First ensure that the database is running.
For this, have a look at the [docker](../docker/) folder which provides a docker-compose file to start the database with the default schema.

Then check that all environment variables are set correctly.
The default environment file used when the project is started is [./env/dev.env](./env/dev.env).
When nothing changed so far the default values should be fine.

To start the backend, run the following command:
```bash
go run cmd/server/main.go
```

The server starts on port `5000` by default.

## What it contains

### Server

The server is the main entry point for the backend.
It provides the admin interface and the API.
Routes are defined in the [./internal/server/server.go](./internal/server/server.go) file.
The routes are defined in the `SetupRouter` function.

### API

The API is a REST API that provides endpoints to interact with the frontend.
The main API components can be found in the [./api](./api) folder.
The routes are defined in the [./api/handler/api_server.go](./api/handler/api_server.go) file in the function `SetupAPIRoutes` with the default prefix `/api`.

## Database Schema

For creating type safe database queries, the [sqlc](https://github.com/sqlc-dev/sqlc) library is used.
The schema is defined in the [./internal/database/sqlc/schema.sql](./internal/database/sqlc/schema.sql) file.
