/// APP CONSTANTS GO HERE IN THIS FILE

const BASE_URL = '';
const VERSION = 'v0.3.5';
const VERSION_KEY = 'version';
const BUILD_NUMBER_KEY = 'buildNumber';
const SOURCE_CODE_URL = 'https://github.com/maheshmnj/vocabhub';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.vocabhub.app';
const AMAZON_APP_STORE_URL =
    'http://www.amazon.com/gp/mas/dl/android?p=com.vocabhub.app';
const REPORT_URL = 'https://github.com/maheshmnj/vocabhub/issues/new/choose';
const String signInScopeUrl =
    'https://www.googleapis.com/auth/contacts.readonly';
// const SHEET_URL =
//     'https://docs.google.com/spreadsheets/d/1G1RtQfsEDqHhHP4cgOpO9x_ZtQ1dYa6QrGCq3KFlu50';

const PRIVACY_POLICY = 'https://maheshmnj.github.io/privacy';
const String profileUrl = 'assets/profile.png';
const Duration wordCountAnimationDuration = Duration(seconds: 3);
const FEEDBACK_EMAIL_TO = 'maheshmn121@gmail.com';

/// TABLES
const VOCAB_TABLE_NAME = 'vocabsheet_mobile';
const USER_TABLE_NAME = 'users_mobile';
// const VOCAB_TABLE_NAME = 'vocabsheet_copy';
// const USER_TABLE_NAME = 'users_test';
const FEEDBACK_TABLE_NAME = 'feedback';

const EDIT_HISTORY_TABLE = 'edit_history';
const WORD_STATE_TABLE_NAME = 'word_state';
const WORD_OF_THE_DAY_TABLE_NAME = 'word_of_the_day';

/// VOCAB TABLE COLUMNS
const WORD_COLUMN = 'word';
const ID_COLUMN = 'id';
const SYNONYM_COLUMN = 'synonyms';
const MEANING_COLUMN = 'meaning';
const EXAMPLE_COLUMN = 'example';
const NOTE_COLUMN = 'notes';
const STATE_COLUMN = 'state';
const CREATED_AT_COLUMN = 'created_at';

/// USER TABLE COLUMNS
const USERID_COLUMN = 'id';
const USER_NAME_COLUMN = 'name';
const USER_EMAIL_COLUMN = 'email';
const USERNAME_COLUMN = 'username';
const USER_BOOKMARKS_COLUMN = 'bookmarks';
const USER_CREATED_AT_COLUMN = 'created_at';
const USER_LOGGEDIN_COLUMN = 'isLoggedIn';

/// EDIT HISTORY TABLE COLUMNS
const EDIT_ID_COLUMN = 'edit_id';
const EDIT_USER_ID_COLUMN = 'user_id';
const EDIT_WORD_ID_COLUMN = 'word_id';

const String dateFormatter = 'MMMM dd, y';
const String timeFormatter = 'hh:mm a';

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
