# Vocabhub 0.5.6

Supercharge your vocabulary with our comprehensive app designed to help you excel in English! Whether you're preparing for the GRE or simply aiming to enhance your language skills, this app is your ultimate companion. Unlock the potential of over 800 meticulously curated GRE words, carefully selected to bolster your word power.

Our app goes beyond just presenting words; it empowers you to truly master them. Keep track of your progress as you conquer words, marking them as mastered and solidifying your understanding. With our intuitive interface, effortlessly navigate through your learned words while exploring exciting new vocabulary.

Stay motivated and inspired with our engaging 'Word of the Day' feature. Every day, discover a captivating new word accompanied by its definition, example usage, and additional insights to broaden your linguistic horizons.

What sets us apart is our commitment to collaboration and community. Our app is an open-source crowd platform, welcoming contributions from every user. Join our network of language enthusiasts, and contribute to our expanding database by suggesting edits, offering alternative definitions, or sharing additional examples. Together, we can collectively improve the quality and accuracy of our word collection, fostering a community-driven platform for continuous learning.

Download the app now and embark on an enriching vocabulary journey. Enhance your language skills, build your confidence, and embrace the power of words. Start expanding your linguistic repert`oire today.

Key Features:

- 800+ most common GRE words
- Synonyms, mnemonics, and examples provided for a comprehensive understanding of each word
- Intelligent search functionality allows you to search for a word based on its meaning or synonym.
- Supports dark mode and offers various themes to make learning an enjoyable experience
- Supports offline mode to help you learn on the go.
- Ability to suggest edits to improve the words on the platform
- Regular updates with new words and features to keep your vocabulary journey exciting and dynamic.

<a href="https://play.google.com/store/apps/details?id=com.vocabhub.app" target="_blank">
<img src="assets/googleplay.png" height="60">
</a>

<a href="http://www.amazon.com/gp/mas/dl/android?p=com.vocabhub.app" target="_blank">
<img src="assets/amazonappstore.png" height="60">
</a>

### Platform

| Android | iOS | MacOS | Web |
| :-----: | :-: | :---: | :-: |
|   ✅    | ✅  |  ❌   | ✅  |

### [Try it out on the web](https://vocabhub.web.app/)

### Mobile

|                                                           Preview 1                                                           |                                                           Preview 2                                                           |                                                           Preview 3                                                           |
| :---------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/244975971-0efb5a84-a65d-4bea-8518-ca2b50441ebb.png" width="600"> | <img src="https://user-images.githubusercontent.com/31410839/244975970-726972e8-4c90-431d-b148-42997925a41d.png" width="600"> | <img src="https://user-images.githubusercontent.com/31410839/244976016-d91bad90-f6bd-4a4c-85e6-2873768165f0.png" width="600"> |

|                                                           Preview 4                                                           |                                                           Preview 5                                                           |                                                           Preview 6                                                           |
| :---------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/244976020-c733ec5c-b3ee-421e-a85b-409d4b9fcd1e.png" width="600"> | <img src="https://user-images.githubusercontent.com/31410839/244976024-3587a34a-51f8-47c2-be0b-78c7a4446aa6.png" width="600"> | <img src="https://user-images.githubusercontent.com/31410839/244976121-16878a12-367a-4b11-85a7-6fd14af80428.png" width="600"> |

|                                                      Preview 7                                                      |                                                      Preview 8                                                      |
| :-----------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------: |
| ![preview 5](https://user-images.githubusercontent.com/31410839/244976125-a2b53e8e-8a8f-4d16-a4d3-499541606ca8.png) | ![preview 4](https://user-images.githubusercontent.com/31410839/244976128-6932df29-c6e3-4895-a305-e5c339f91ccd.png) |

### Running the app

The api keys in this project are managed using [--dart-define](https://dartcode.org/docs/using-dart-define-in-flutter/) flags passed to the flutter run command. You can also use the

```dart
flutter <command> --dart-define=SUPABASE_PROJECT_URL=<your project url here> --dart-define=SUPABASE_API_KEY=<your api key here> --dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>
```

command to run the app from the command line, or If you want to use the launch.json file to run the app, you can copy paste the below configuration to your `.vscode/launch.json` file and pass the keys from the Supabase settings.

```
 {
    "name": "Launch",
    "request": "launch",
    "type": "dart",
    "program": "lib/main.dart",
    "args": [
        "--dart-define=SUPABASE_PROJECT_URL=<your project url here>",
        "--dart-define=SUPABASE_API_KEY=<your api key here>",
        "--dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>",
        --dart-define=FIREBASE_VAPID_KEY=<vapid key from web push certificate in firebase>
    ]
  }
```

_Run the project using the command_

```
  flutter run --dart-define=SUPABASE_PROJECT_URL=<your project url here> --dart-define=SUPABASE_API_KEY=<your api key here> --dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>  --dart-define=FIREBASE_VAPID_KEY=<vapid key from web push certificate in firebase>
```

#### Build the app

```
  flutter build apk --dart-define=SUPABASE_PROJECT_URL=<your project url here> --dart-define=SUPABASE_API_KEY=<your api key here> --dart-define=SUPABASE_REDIRECT_URL=<your redirect url here>
  --dart-define=FIREBASE_VAPID_KEY=<vapid key from web push certificate in firebase>
```

The apk will be generated in the `build/app/outputs/flutter-apk/app-release.apk` folder.

### Redesigned for the Web v0.4.2

|                                                 v0.4.2                                                  |
| :-----------------------------------------------------------------------------------------------------: |
| <img src="https://github.com/maheshmnj/vocabhub/assets/31410839/a3eee2da-dd51-445c-bed7-45363ae9ed7f"/> |

## Adds Support for Dark Mode (Web only)

|                                                       v0.2.2                                                       |
| :----------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/125232197-be28a180-e2f9-11eb-82db-980325528b55.png"/> |

|                                                       v0.2.0                                                       |
| :----------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/121843891-b8429f00-cd00-11eb-8fc9-c242b8a6a19c.png"/> |

|                                                       v0.1.0                                                       |
| :----------------------------------------------------------------------------------------------------------------: |
| <img src="https://user-images.githubusercontent.com/31410839/120900881-131b2d00-c655-11eb-8c00-6aafade70d29.png"/> |

## Contributing

Feel Free to contribute to this app to make the platform better.

Design files for this project can be found here https://www.figma.com/file/xPCoi1IcW8M6TODTqjG9GZ/Vocabhub?node-id=0%3A1

Data is no longer being collected into [this sheet](https://docs.google.com/spreadsheets/d/1G1RtQfsEDqHhHP4cgOpO9x_ZtQ1dYa6QrGCq3KFlu50/edit#gid=0). Contribution does not necessarily mean sending a pull request you could also contribute by improving the sheet.

This problem can be solved using greedy approach. Let n be the total number of jobs with J = {1, 2, 3, 4 … n} with their finish times C = {c1, c2, c3,... cn} and corresponding weights W = {w1, w2, w3 … wn}

The idea is to sort the jobs in descending order of their ratio wi/ti and then calculate the weighted sum
