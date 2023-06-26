/// APP CONSTANTS GO HERE IN THIS FILE
class Constants {
  static const APP_TITLE = 'Vocabhub';
  static const ORGANIZATION = 'Widget Media Labs';
  static const BASE_URL = '';
  static const VERSION = 'v0.5.0';
  static const VERSION_KEY = 'version';
  static const BUILD_NUMBER_KEY = 'buildNumber';
  static const SOURCE_CODE_URL = 'https://github.com/maheshmnj/vocabhub';
  static const PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.vocabhub.app';
  static const AMAZON_APP_STORE_URL = 'http://www.amazon.com/gp/mas/dl/android?p=com.vocabhub.app';
  static const REPORT_URL = 'https://github.com/maheshmnj/vocabhub/issues/new/choose';
  static const String SIGN_IN_SCOPE_URL = 'https://www.googleapis.com/auth/contacts.readonly';
// static const SHEET_URL =
//     'https://docs.google.com/spreadsheets/d/1G1RtQfsEDqHhHP4cgOpO9x_ZtQ1dYa6QrGCq3KFlu50';
  /// API KEYS
  static const SUPABASE_API_KEY = String.fromEnvironment('SUPABASE_API_KEY');
  static const SUPABASE_URL = String.fromEnvironment('SUPABASE_PROJECT_URL');
  static const REDIRECT_URL = String.fromEnvironment('SUPABASE_REDIRECT_URL');
  static const FIREBASE_VAPID_KEY = String.fromEnvironment('FIREBASE_VAPID_KEY');
  static const PRIVACY_POLICY_TITLE = 'Privacy Policy';

  static const PRIVACY_POLICY = 'https://maheshjamdade.com/vocabhub/privacy';
  static const String PROFILE_AVATAR_ASSET = 'assets/profile.png';
  static const Duration wordCountAnimationDuration = Duration(seconds: 3);
  static const FEEDBACK_EMAIL_TO = 'maheshmn121@gmail.com';

  /// TABLES
  static const VOCAB_TABLE_NAME = 'vocabsheet_mobile';
  static const USER_TABLE_NAME = 'users_mobile';
// static const VOCAB_TABLE_NAME = 'vocabsheet_copy';
// static const USER_TABLE_NAME = 'users_test';
  static const FEEDBACK_TABLE_NAME = 'feedback';

  static const EDIT_HISTORY_TABLE = 'edit_history';
  static const WORD_STATE_TABLE_NAME = 'word_state';
  static const WORD_OF_THE_DAY_TABLE_NAME = 'word_of_the_day';

  /// VOCAB TABLE COLUMNS
  static const WORD_COLUMN = 'word';
  static const ID_COLUMN = 'id';
  static const SYNONYM_COLUMN = 'synonyms';
  static const MEANING_COLUMN = 'meaning';
  static const EXAMPLE_COLUMN = 'example';
  static const NOTE_COLUMN = 'notes';
  static const STATE_COLUMN = 'state';
  static const CREATED_AT_COLUMN = 'created_at';

  /// USER TABLE COLUMNS
  static const USERID_COLUMN = 'id';
  static const USER_NAME_COLUMN = 'name';
  static const USER_EMAIL_COLUMN = 'email';
  static const USERNAME_COLUMN = 'username';
  static const USER_BOOKMARKS_COLUMN = 'bookmarks';
  static const USER_CREATED_AT_COLUMN = 'created_at';
  static const USER_LOGGEDIN_COLUMN = 'isLoggedIn';
  static const USER_TOKEN_COLUMN = 'token';

  /// EDIT HISTORY TABLE COLUMNS
  static const EDIT_ID_COLUMN = 'edit_id';
  static const EDIT_USER_ID_COLUMN = 'user_id';
  static const EDIT_WORD_ID_COLUMN = 'word_id';

  static const String dateFormatter = 'MMMM dd, y';
  static const String timeFormatter = 'hh:mm a';
  static const int ratingAskInterval = 7;
  static const int scrollMessageShownInterval = 7;
  static const Duration timeoutDuration = Duration(seconds: 6);
}

enum EditState {
  approved('approved'),

  /// Admin has rejected the request
  rejected('rejected'),
  pending('pending'),

  /// user can cancel the edit request
  cancelled('cancelled');

  final String state;
  const EditState(this.state);

  String toName() => "$state";
}

enum WordState { known, unknown, unanswered }

enum EditType {
  /// request to add a new word
  add,

  /// request to edit an existing word
  edit,

  /// request to delete an existing word
  delete,
}

enum Status { success, notfound, error }

enum RequestState { active, done, error, none }

const int HOME_INDEX = 0;
const int SEARCH_INDEX = 1;
const int EXPLORE_INDEX = 2;
const int PROFILE_INDEX = 3;

int maxExampleCount = 3;
int maxSynonymCount = 5;
int maxMnemonicCount = 5;
