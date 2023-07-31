import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/services/services/user.dart';
import 'package:vocabhub/utils/firebase_options.dart';

class PushNotificationService extends ServiceBase with ChangeNotifier {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  List<bool> _notifications = [true, true, true];
  String _adminToken = '';
  String adminTokenKey = 'adminTokenKey';
  late SharedPreferences _sharedPreferences;

  String notfiicationsKey = 'notifications';

  static String wordOfTheDayTopic = 'word_of_the_day';

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
    await _sharedPreferences.setStringList(notfiicationsKey, stringList);
    notifyListeners();
  }

  Future<void> getNotificationsEnabled() async {
    final stringList = _sharedPreferences.getStringList(notfiicationsKey);
    if (stringList != null) {
      _notifications = stringList.map((e) => e == 'true').toList();
    }
    notifyListeners();
  }

  PushNotificationService(FirebaseMessaging firebaseMessaging) {
    _firebaseMessaging = firebaseMessaging;
  }

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  // static const AndroidNotificationDetails _androidNotificationDetails = AndroidNotificationDetails(
  //   // channel id
  //   'daily_notification',
  //   "daily_notification",
  //   channelDescription: "This channel is responsible for all the local notifications",
  //   playSound: true,
  //   priority: Priority.high,
  //   importance: Importance.high,
  // );

  // static DarwinNotificationDetails _iOSNotificationDetails = DarwinNotificationDetails();

  // final NotificationDetails notificationDetails = NotificationDetails(
  //   android: _androidNotificationDetails,
  //   iOS: _iOSNotificationDetails,
  // );
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await setupFlutterNotifications();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  Future<void> getAdminToken() async {
    final user = await UserService.findByEmail(email: Constants.FEEDBACK_EMAIL_TO, cache: false);
    _adminToken = user.token;
    // print('admin token: $_adminToken');
  }

  Future<void> selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  String constructEditPayload(String? token, EditHistory history) {
    final type = history.edit_type!.pastTense;
    return json.encode({
      "to": "$token",
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

  String constructEditStatusChangePayload(String? token, EditHistory history, EditState state) {
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

  /// whether the notification is for edit status change
  /// editStatus changes when admin approves or rejects the edit request
  Future<void> sendNotification(EditHistory history, EditState state,
      {bool isEditStatus = false, String? token}) async {
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
          headers: headers,
          body: isEditStatus
              ? constructEditStatusChangePayload("$token", history, state)
              : constructEditPayload("$adminToken", history));
      print("FCM request for device sent! ${resp.body}");
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendEditNotification() async {}

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
          ),
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
          onDidReceiveNotificationResponse: (response) {
        appKey.currentState!.pushNamed(Notifications.route);
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showFlutterNotification(message);
      });
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
