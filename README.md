# Vocabhub

A Flutter Template to clone and start working directly on your application.

This is created with an intention to save your time doing repetative work with your new project like creating folder structure, adding files to gitignore, adding localization networking capabilities.

Feel free to fork this repo and modify this template as you like. If this template helps you save even 15 mins on your new project the goal is reached.

## Things to do post fork

1.  Change the AppTitle

    **Android**

    a) navigate to file `android/app/src/main/AndroidManifest.xml`

    b) local for lable named `android:label`

    **IOS**

    a) navigate to file `ios/Runner/Info.plist`

    b) look for

    ```
      <key>CFBundleName</key>
      <string>App Name</string>
    ```

    Still stuck [look here](https://stackoverflow.com/questions/49353199/how-can-i-change-the-app-display-name-build-with-flutter)

2.  Change the package name, The default package name is (`com.vocabhub.app`)
    Use search and replace feature of your IDE to get this done.

3.  If your app does not need localization delete `lib/locales` directory and also delete the corresponding packages
    from pubspec.yaml

- flutter_localizations:
- flutter_cupertino_localizations

4.  Look for `lib/models/user_model.dart` an example for generating json serializable is given there

```
flutter pub run build_runner build

flutter pub run build_runner watch // watches the file changes
```

_for more look at the example file at `lib/models/user_model.dart`_

## Contributing

You feel this template needs some modification or has issues feel free to create one.This will help improve this template with time.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
