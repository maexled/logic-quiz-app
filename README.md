# Logic App Quiz

This folder contains the code for the Logic Quiz App.
The App contains of several components:
- The [frontend](./frontend/) 
- The [serverside](./serverside/)
- The [task generator](./generator/) which is implemented in the [serverside](./serverside/task_generation/).
- The database which can be started with a docker compose file in the [docker](./docker/) folder.

To start these components have a look at the respective READMEs.
When you want to start all components, you should start them in the following order:
1. Database (Docker). Switch to the [docker](./docker/) folder and follow the README. The database schema gets imported automatically if you keep the current folder structure.
2. Serverside. Switch to the [serverside](./serverside/) folder and follow the README. This will start the backend on port 5000. Additionally, the database will be filled up with 200 tasks.
3. (Optional) If you want to generate more tasks, you can use the task generator. Switch to the [generator README](./generator/README.md) for more information.
4. Frontend. Switch to the [frontend](./frontend/) folder and follow the README. The frontend can also run without the serverside, but much is persisted in the database and some features like the statistics or more tasks beside the 10 offline tasks will not work.
