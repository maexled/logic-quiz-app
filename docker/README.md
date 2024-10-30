# Docker

This folder contains a docker-compose file that will start a Postgres database and a pgAdmin instance.
On creation, the database will be filled with the schema of the serverside thanks to mounting the `schema.sql` file to the `docker-entrypoint-initdb.d` folder.

## Usage

To start the postgres database and pgAdmin, run the following command:

```bash
docker compose up -d
```

The database will be available on `localhost:5432` with the default credentials:
- Username: `postgres`
- Password: `postgres`
- Database: `postgres`

pgAdmin will be available on `localhost:8080` with the default credentials:
- Email: `admin@admin.com`
- Password: `admin`

To connect pgAdmin to the database, create a new server by following these steps:
1. Right click on `Servers` and select `Register` -> `Server`. A popup will appear.
2. In the `General` tab, fill in the name of the server. (you can choose any name)
3. In the `Connection` tab, fill in the following fields:
   - Host name/address: `db`
   - Port: `5432`
   - Maintenance database: `postgres`
   - Username: `postgres`
   - Password: `postgres`
   - Save password: `Yes`
4. Click `Save` to save the server.
5. The database will now appear on the right side. 
6. Click on db -> Databases -> postgres -> Schemas -> public -> Tables to see the tables.
