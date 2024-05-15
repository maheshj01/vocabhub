// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';

class Analytics {
//   FirebaseAnalyticsObserver observer;
//   FirebaseAnalytics analytics;

  // singleton boilerplate
  static final Analytics _instance = Analytics._internal();

  static Analytics get instance {
    return _instance;
  }

  Analytics._internal();

  Future<void> logWordSelection(Word word) async {
    await firebaseAnalytics.logEvent(name: 'word_selected', parameters: {'word': word.word});
  }

  Future<void> logRouteView(String routeName) async {
    await firebaseAnalytics.logEvent(name: 'route_view', parameters: {'route': routeName});
  }

  /// Platform is either Desktop or Web(PWA)
  Future<void> logRedirectToStore(String platform) async {
    await firebaseAnalytics.logEvent(name: 'play_store', parameters: {'Platform': '$platform'});
  }

  Future<void> logWordEdit(Word word, String email) async {
    await firebaseAnalytics
        .logEvent(name: 'word_edit', parameters: {'word': word.word, 'email': email});
  }

  Future<void> logWordDelete(Word word, String email) async {
    await firebaseAnalytics
        .logEvent(name: 'word_delete', parameters: {'word': word.word, 'email': email});
  }

  Future<void> logWordAddSubmit(Word word, String status) async {
    await firebaseAnalytics
        .logEvent(name: 'word_add_submit', parameters: {'word': word.word, 'status': status});
  }

  Future<void> logNewUser(UserModel user) async {
    await firebaseAnalytics.logEvent(name: 'sign_up', parameters: {
      'email': user.email,
      'name': user.name,
      'platform': kIsWeb ? 'web' : 'mobile'
    });
  }

  Future<void> logSignIn(UserModel user) async {
    await firebaseAnalytics.logEvent(name: 'sign_in', parameters: {
      'email': user.email,
      'name': user.name,
      'platform': kIsWeb ? 'web' : 'mobile'
    });
  }

  Future<void> logAppUpdate(String version) async {
    await firebaseAnalytics.logEvent(name: 'app_update_click', parameters: {'version': version});
  }

//   Future<void> logInitiateSignup(String signupMethod) async {
//     await analytics.logSignUp(signUpMethod: signupMethod);
//   }

//   Future<void> logLogin(String loginMethod) async {
//     await analytics.logLogin(loginMethod: loginMethod);
//   }

//   Future<void> logAddToCart(String id) async {
//     await analytics.logAddToCart(itemId: id);
//   }
}
