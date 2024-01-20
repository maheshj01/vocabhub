import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/utils/logger.dart';
import 'package:vocabhub/utils/utility.dart';

class PushNotificationService extends ServiceBase with ChangeNotifier {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  List<bool> _notifications = [true, true, true];
  String _adminToken = '';
  String adminTokenKey = 'adminTokenKey';
  late SharedPreferences _sharedPreferences;
  final _logger = Logger('PushNotificationService');
  // subscribe to all notifications for the first time
  String initSubscriptionKey = 'initSubscriptionKey';

  // fetches notifications subscription status from shared preferences
  // array of bools
  String notificationsKey = 'notifications';

  bool initSubscribed = false;

  /// topic to subscribe to for word of the day
  static String wordOfTheDayTopic = 'word_of_the_day';

  /// topic to subscribe to for daily reminders
  static String dailyReminderTopic = 'daily_reminder';

  // topic to subscribe to for new word additions to the platform
  static String newWordTopic = 'new_word';

  String get adminToken => _adminToken;

  set adminToken(String value) {
    _adminToken = value;
    _sharedPreferences.setString(adminTokenKey, value);
  }

  String? get fcmToken => _fcmToken;

  /// whether the user is subscribed to notifications
  List<bool> get notifications => _notifications;

  Future<void> subscribeToNotifications(int index, bool value) async {
    _notifications[index] = value;
    final stringList = _notifications.map((e) => e.toString()).toList();
    await _sharedPreferences.setStringList(notificationsKey, stringList);
    notifyListeners();
    switch (index) {
      case 0:
        if (value) {
          await subscribeToTopic(wordOfTheDayTopic);
        } else {
          await unsubscribeFromTopic(wordOfTheDayTopic);
        }
        showToast('You are now ${value ? 'subscribed' : 'unsubscribed'} to word of the day');
        break;
      case 1:
        if (value) {
          await subscribeToTopic(dailyReminderTopic);
        } else {
          await unsubscribeFromTopic(dailyReminderTopic);
        }
        showToast('You are now ${value ? 'subscribed' : 'unsubscribed'} to daily reminders');
        break;
      case 2:
        if (value) {
          await subscribeToTopic(newWordTopic);
        } else {
          await unsubscribeFromTopic(newWordTopic);
        }
        showToast('You are now ${value ? 'subscribed' : 'unsubscribed'} to new words');
        break;
      case 2:
        break;
    }
  }

  /// Fetches notifications subscription status from shared preferences
  Future<void> getNotificationsEnabled() async {
    final stringList = _sharedPreferences.getStringList(notificationsKey);
    if (stringList != null) {
      _notifications = stringList.map((e) => e == 'true').toList();
    }
    notifyListeners();
  }

  PushNotificationService(FirebaseMessaging firebaseMessaging) {
    _firebaseMessaging = firebaseMessaging;
  }

  Future<void> subscribeToTopic(String topic) async {
    _logger.d('subscribing to topic: $topic');
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    _logger.d('unsubscribing from topic: $topic');
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> getAdminToken() async {
    // final user = await UserService.findByEmail(email: Constants.FEEDBACK_EMAIL_TO, cache: false);
    // _adminToken = user.token;
  }

  Future<void> selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  /// whether the notification is for edit status change
  /// editStatus changes when admin approves or rejects the edit request
  Future<void> sendNotification(String body) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=${Constants.FCM_SERVER_KEY}'
    };
    if (_adminToken.isEmpty) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      final resp = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers, body: body);
      _logger.d("FCM request for device sent! ${resp.body}");
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendNotificationToTopic(String topic, String title, String body) async {
    // notifcation to topic
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=${Constants.FCM_SERVER_KEY}'
    };
    if (_adminToken.isEmpty) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      final resp = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: headers, body: Constants.constructTopicPayLoad(topic, title, body));
      _logger.d("FCM request for device sent! ${resp.body}");
    } catch (e) {
      print(e);
    }
  }

  /// Subscribe to all notifications for the first time
  Future<void> initSubscription() async {
    final initSubcribed = _sharedPreferences.getBool(initSubscriptionKey) ?? false;
    if (!initSubcribed) {
      await subscribeToTopic(wordOfTheDayTopic);
      await subscribeToTopic(dailyReminderTopic);
      await subscribeToTopic(newWordTopic);
      await _sharedPreferences.setBool(initSubscriptionKey, true);
    }
  }

  Future<void> checkPermissions() async {
    final NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
    print('User granted permissions: ${settings.authorizationStatus}');
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      final newSettings = await _firebaseMessaging.requestPermission();
      if (newSettings.authorizationStatus != AuthorizationStatus.authorized) {
        print('User declined permissions');
        return;
      }
    }
  }

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  Future<void> initService() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _sharedPreferences = await SharedPreferences.getInstance();
    getNotificationsEnabled();
    await setupFlutterNotifications();
    getAdminToken();
    checkPermissions();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (!kIsWeb) {
      flutterLocalNotificationsPlugin.initialize(
          InitializationSettings(
              android: AndroidInitializationSettings(Constants.LAUNCHER_ICON),
              iOS: DarwinInitializationSettings(
                defaultPresentAlert: true,
                defaultPresentSound: true,
                requestAlertPermission: true,
                requestBadgePermission: true,
                defaultPresentBadge: true,
                requestSoundPermission: true,
              )),
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
          onDidReceiveNotificationResponse: (response) {
        appKey.currentState!.pushNamed(Notifications.route);
      });
      FirebaseMessaging.onMessage.listen(showFlutterNotification);
      await initSubscription();
    }
  }

  void setToken(String? tk) {
    _fcmToken = tk;
  }

  Future<void> setupFlutterNotifications() async {
    if (kIsWeb) {
      _firebaseMessaging.getToken(vapidKey: Constants.FIREBASE_VAPID_KEY).then(setToken);
      final _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
      _tokenStream.listen(setToken);
    } else {
      _fcmToken = await _firebaseMessaging.getToken();
    }
  }

  @override
  Future<void> disposeService() async {}

  Future<void> showFlutterNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'your channel id',
              'your channel name',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
            ),
          ),
          payload: notification.body);
    }
  }

  // Future<void> setupFirebaseNotifications() async {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //     if (notification != null && android != null) {
  //       flutterLocalNotificationsPlugin.show(
  //           notification.hashCode,
  //           notification.title,
  //           notification.body

  //           payload: 'item x');
  //     }
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   });

  //   await _firebaseMessaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  // }
}
