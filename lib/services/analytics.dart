// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';

class Analytics {
//   FirebaseAnalyticsObserver observer;
//   FirebaseAnalytics analytics;

  Future<void> logWordSelection(Word word) async {
    await analytics
        .logEvent(name: 'word_selected', parameters: {'word': word.word});
  }

  /// Platform is either Desktop or Web(PWA)
  Future<void> logRedirectToStore(String platform) async {
    await analytics
        .logEvent(name: 'play_store', parameters: {'Platform': '$platform'});
  }

  Future<void> logWordEdit(Word word, String email) async {
    await analytics.logEvent(
        name: 'word_edit', parameters: {'word': word.word, 'email': email});
  }

  Future<void> logWordDelete(Word word, String email) async {
    await analytics.logEvent(
        name: 'word_delete', parameters: {'word': word.word, 'email': email});
  }

  Future<void> logWordAdd(Word word, [String email = '']) async {
    await analytics.logEvent(
        name: 'word_add', parameters: {'word': word.word, 'email': email});
  }

  Future<void> logNewUser(UserModel user) async {
    await analytics.logEvent(name: 'sign_up', parameters: {
      'email': user.email,
      'name': user.name,
      'platform': kIsWeb ? 'web' : 'mobile'
    });
  }

  Future<void> logSignIn(UserModel user) async {
    await analytics.logEvent(name: 'sign_in', parameters: {
      'email': user.email,
      'name': user.name,
      'platform': kIsWeb ? 'web' : 'mobile'
    });
  }

  Future<void> appOpen() async {
    await analytics.logAppOpen();
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
