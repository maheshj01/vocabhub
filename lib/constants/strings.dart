/// app string constants  from the UI go here in this page
/// e.g
const String GITHUB_ASSET_PATH = 'assets/github.png';
const String GITHUB_WHITE_ASSET_PATH = 'assets/github_white.png';
const String GOOGLE_ASSET_PATH = 'assets/google.png';
const String WALLPAPER_1 = 'assets/wallpaper1.jpg';
const String WALLPAPER_2 = 'assets/wallpaper2.jpg';

final List<String> tips = [
  'Do you know you can search by synonyms?\n Try searching for "reduce"',
  'Do you know you can copy the word by just tapping on it?',
  'Do you see a mistake in a word? or want to help improve it click on the edit icon to improve it',
  'Do you have a common GRE word thats missing?\n consider contributing by adding a word',
  "You don't remember the word but know what it means?\nTry searching for its meaning."
];

Map<String, List<String>> popupMenu = {
  'signout': ['Add word', 'Source code', 'Privacy Policy', 'Report', 'Sign Out'],
  'signin': ['Add word', 'Source code', 'Privacy Policy', 'Report', 'Sign In'],
  'admin': ['Add word', 'Source code', 'Download file', 'Privacy Policy', 'Report', 'Sign Out'],
};

const String unKnownWord = 'We will try out best to help you master this word';
const String knownWord = 'We will try not to show that word again';
const String signInFailure = 'failed to sign in User, please try again later';

const String ABOUT_TEXT =
    "Vocabhub is a free and open-source project designed to aid in expanding vocabulary and earning new words. Developed as a personal side project by a single individual, this app aims to provide a helpful resource for users to enhance their linguistic skills. Personally, I have found the words available on this platform to be extremely beneficial, and I hope that you will find them useful as well.\nThe platform encourages contributions from users like yourself to improve its quality and benefit others. You can contribute by adding new words, refining existing ones, or reporting any bugs you encounter. Your suggestions and feedback are highly appreciated, and you can provide them through the report section of the app.\nI am always seeking contributors to enhance the word database on the platform. Your contributions will play a vital role in improving the overall quality and usefulness of Vocabhub. Vocabhub is licensed under the MIT License on GitHub, and you can access the source code by following the link provided.\nThank you for using Vocabhub, and I eagerly await your valuable feedback.";
