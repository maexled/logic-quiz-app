# Logic App Frontend

![build status](https://theogit.fmi.uni-stuttgart.de/fapra_ss2024/fp_ss24_kaestnmx/badges/main/pipeline.svg?job=serverside-build&key_text=frontend%20build&key_width=85)

## Usage

To download the needed dependencies, you can run the following command in this directory:

```bash
flutter pub get
```

If you are familiar with Flutter Development and want to start the project in your IDE, you can simply open this folder in your IDE, switch to the `lib/main.dart` file and run the project.

Otherwise you can start the project by running the following command in this directory:

```bash
flutter run
```

To build the project, you can run the following command in this directory:

```bash
flutter build apk
```

## How the App works

The app is a simple frontend for the Logic App.
It allows a user to run logic quizzes which have the task to find and equivalent formula for a given formula.

Additionally the user will be provided with some statistics. 

The frontend is dependent on the [serverside](../serverside) for some features, but the core works also without the serverside.
When no backend available, the quiz has 10 default questions. If a backend is available, it will load the questions from the backend.
The statistics are loaded from the backend so the statistics page will just provide useful information if the serverside is running.

Additionally the app has a quick user guide.