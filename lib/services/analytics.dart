// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:vocabhub/main.dart';

class Analytics {
//   FirebaseAnalyticsObserver observer;
//   FirebaseAnalytics analytics;

  Future<void> logEvent(String event) async {
    await analytics.logEvent(name: '${event.toLowerCase()}');
  }

//   Future<void> logShare(String event) async {
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
