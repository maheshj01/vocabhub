import 'package:vocabhub/constants/const.dart';

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
    "Vocabhub is a free and open-source project designed to aid in expanding vocabulary and learning new words. This project was started as fun personal side project, this app aims to provide a helpful resource for users to enhance their linguistic skills, We hope this app helps in your journey.\nThis is a crowdsourced platform and we need your help to make it better. We highly encourage contributors to enhance the word database on the platform. Your contributions will play a vital role in improving the overall quality and usefulness of Vocabhub for all. The platform encourages contributions from users on this platform to improve its quality and benefit others. You can contribute by adding new words, refining existing ones, or reporting any bugs you encounter. We thrive on criticism and suggestions, so please feel free to reach out to us with any feedback you may have through the report section.\n\nVocabhub though is a free and open-source project, But it is governed by apache license 2.0. Please read the license before you use the source code for your own project.\n\nThank you for using our app, We are improving the experience every week, so stay tuned for more updates.";

const String ratingDescription =
    "If you've been finding value in your experience with ${Constants.APP_TITLE}, we kindly request a moment of your time to rate the app on the Play Store. We genuinely appreciate your support and feedback, and it will only take a minute. Thank you for choosing ${Constants.APP_TITLE}!";

const String exploreScrollMessage = 'Swipe up to explore more words';

const String NETWORK_ERROR = 'Please check your internet connectivity!';
const String SOMETHING_WENT_WRONG = 'Something Went Wrong!';

const String WORD_SUBMITTED =
    'Your edit is under review, We will notifiy you once there is an update';
List<String> onBoardingTitles = [
  'Word Power Unleashed',
  'Collaborative Learning Community',
  'Word of the Day',
  'Explore curated words',
  'Dark Mode and color themes'
];

List<String> onBoardingDescriptions = [
  "Supercharge your vocabulary with 800+ curated GRE words, synonyms, mnemonics, and examples for comprehensive language learning.",
  'Join our language community, contribute words, suggest edits, and share examples to build a platform for continuous learning and improvement.',
  'Stay inspired with our captivating "Word of the Day" feature, discovering intriguing new words with definitions, examples, and insights every day, all year long.',
  "Explore a diverse range of captivating words in the 'Explore' section. We curate personalized learning experiences, empowering you to effectively expand your vocabulary and master new words.",
  "Personalize your app experience with Dark Mode and personalized color schemes. Enjoy a learning journey that's uniquely yours, with an app that matches your style and feels tailor-made for you"
];

String onDeviceCollectionsString =
    "Note: This collection will remain on your device only. Uninstalling the app will delete all your collections.";

String onDeviceCollectionsString2 =
    "Note The collections are retained on your device and will not be synced.";

String userNameConstraints =
    'Username should contain letters, numbers and underscores with minimum 3 characters';

String accountDeleted = 'This account is deleted. Please contact support at';

String registration_Failed = 'failed to register new user';

String accountActivationEmail =
    'mailto:${Constants.FEEDBACK_EMAIL_TO}?subject=Sign In Failure&body=Hi, I am facing issues while signing in. Please help me out.';
