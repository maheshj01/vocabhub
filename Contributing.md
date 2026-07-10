Vocabhub uses Supabase and Firebase for backend services. The project is built using Flutter and Dart.
So you will need to have Flutter installed on your machine to run the project locally. You also need to setup Firebase project and Supabase project with a database to run the project locally.

Below are the steps to setup the project locally:

#### Setting up Firebase

You can skip step 1-3 if you have firebase_cli already installed and activated on your machine.

1. Install firebase tools and activate firebase_cli locally by following instructions here https://firebase.google.com/docs/cli#mac-linux-standalone-binary ()
2. login to firebase `firebase login`
3. activate flutterfire_cli by running `dart pub global activate flutterfire_cli`

4. Create a new firebase project by visiting https://console.firebase.google.com/
5. Run `firebase projects:list` to get the list of projects in your account.
6. Run `firebase use <project_id>` to use the project you created in step 4.
7. Run `flutterfire configure` to configure the flutter project with the firebase project.
   > Note: If flutterfire is not found you need to add the flutterfire_cli to your system path. see [Instructons here](https://stackoverflow.com/a/70325312)
8. Do not use existing firebae.json by answering 'n`,This step will configure your firebase project for selected platforms(android, ios, web etc).
9. Now you should have firebase_options.dart file in your libr folder, move the file to `lib/utils` folder.
10. Go to firebase console -> Run -> RemoteConfig and add the following keys

- `buildNumber`: <from pubspec.yaml>
- `version`: <from pubspec.yaml>

e.g if pubspec has 0.7.9+31 - `buildNumber`: 31 - `version`: 0.7.9
and click Publish Changes

11. Setting up Supabase project see [Supabase setup instructions](./supabase_setup.md)