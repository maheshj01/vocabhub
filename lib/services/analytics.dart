// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word_model.dart';

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

//   Future<void> logShare(String event) async
//     await analytics.logShare(contentType: event);
//   }

//   Future<void> logViewItem(String event) async {
//     await analytics.logViewItem(itemName: event);
//   }

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
