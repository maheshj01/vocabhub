import 'dart:convert';

import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/history.dart';

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
  static const String teamworkAsset =
      'https://github.com/maheshmnj/vocabhub/assets/31410839/8288f317-f3cb-433f-94d6-83644cb0cb05';
// static const SHEET_URL =
//     'https://docs.google.com/spreadsheets/d/1G1RtQfsEDqHhHP4cgOpO9x_ZtQ1dYa6QrGCq3KFlu50';
  /// API KEYS
  static const SUPABASE_API_KEY = String.fromEnvironment('SUPABASE_API_KEY');
  static const SUPABASE_URL = String.fromEnvironment('SUPABASE_PROJECT_URL');
  static const REDIRECT_URL = String.fromEnvironment('SUPABASE_REDIRECT_URL');
  static const FIREBASE_VAPID_KEY = String.fromEnvironment('FIREBASE_VAPID_KEY');
  static const FCM_SERVER_KEY = String.fromEnvironment('FCM_SERVER_KEY');
  static const PRIVACY_POLICY_TITLE = 'Privacy Policy';

  static const PRIVACY_POLICY = 'https://maheshjamdade.com/vocabhub/privacy';
  static const String PROFILE_AVATAR_ASSET = 'assets/profile.png';
  static const Duration wordCountAnimationDuration = Duration(seconds: 3);
  static const FEEDBACK_EMAIL_TO = String.fromEnvironment('ADMIN_EMAIL');

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
  static const String dateTimeFormatter = 'MMMM dd, y hh:mm a';
  static const String timeFormatter = 'hh:mm a';
  static const int ratingAskInterval = 7;
  static const int scrollMessageShownInterval = 7;
  static const Duration timeoutDuration = Duration(seconds: 20);

  static const String LAUNCHER_ICON = '@mipmap/launcher_icon';

  /// Features

  static const String draftsFeature = 'drafts_feature';
  static const String collectionsFeature = 'collections_feature';

  // when a user makes a contribution, admin gets a notification
  static String constructEditPayload(EditHistory history) {
    final type = history.edit_type!.pastTense;
    return json.encode({
      "to": pushNotificationService.adminToken,
      "notification": {
        "body": "${history.users_mobile!.name} $type ${history.word}",
        "content_available": true,
        "priority": "high",
        "title": "New word ${history.edit_type!.name} request"
      },
      "data": {
        "priority": "high",
        "sound": "app_sound.wav",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "content_available": true,
        "id": "$history.id",
      }
    });
  }

  // payload for topic subscription
  static String constructTopicPayLoad(String topic, String title, String body) {
    return json.encode({
      "to": "/topics/$topic",
      "notification": {
        "body": "$body",
        "content_available": true,
        "priority": "high",
        "title": "$title"
      },
      "data": {
        "priority": "high",
        "sound": "app_sound.wav",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "content_available": true,
      }
    });
  }

  // payload when admin takes action on edit request
  static String constructEditStatusChangePayload(
      String? token, EditHistory history, EditState state) {
    return json.encode({
      "to": "$token",
      "notification": {
        "body": "Your contribution to ${history.word} has been ${state.toName()}",
        "content_available": true,
        "priority": "high",
        "title": "Your contribution has been ${state.toName()}"
      },
      "data": {
        "priority": "high",
        "sound": "app_sound.wav",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "content_available": true,
      }
    });
  }

  static String reportPayLoad(String title, String body) {
    return json.encode({
      "to": pushNotificationService.adminToken,
      "notification": {
        "body": "$body",
        "content_available": true,
        "priority": "high",
        "title": "$title"
      },
      "data": {
        "priority": "high",
        "sound": "app_sound.wav",
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "content_available": true,
      }
    });
  }
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
  add("added"),

  /// request to edit an existing word
  edit("edited"),

  /// request to delete an existing word
  delete("deleted");

  final String pastTense;

  const EditType(this.pastTense);

  String toPastTense() => "$pastTense";
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
