/// APP CONSTANTS GO HERE IN THIS FILE

const BASE_URL = '';
const VERSION = 'v0.3.5';
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

/// TABLES
// const VOCAB_TABLE_NAME = 'vocabsheet';
// const USER_TABLE_NAME = 'users';
const VOCAB_TABLE_NAME = 'vocabsheet_copy';
const USER_TABLE_NAME = 'users_test';

/// VOCAB TABLE COLUMNS
const WORD_COLUMN = 'word';
const ID_COLUMN = 'id';
const SYNONYM_COLUMN = 'synonyms';
const MEANING_COLUMN = 'meaning';
const EXAMPLE_COLUMN = 'example';
const NOTE_COLUMN = 'notes';

/// USER TABLE COLUMNS
const USERID_COLUMN = 'id';
const USER_NAME_COLUMN = 'name';
const USER_EMAIL_COLUMN = 'email';
const USER_BOOKMARKS_COLUMN = 'bookmarks';
const USER_CREATED_AT_COLUMN = 'created_at';
const USER_LOGGEDIN_COLUMN = 'isLoggedIn';
const String dateFormatter = 'MMMM dd, y';

enum WordUpdate { pending, approved, rejected }

enum WordState { known, unknown, unanswered }
