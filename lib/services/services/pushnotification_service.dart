import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/services/services/service_base.dart';

class PushNotificationService extends ServiceBase {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  PushNotificationService(FirebaseMessaging firebaseMessaging) {
    _firebaseMessaging = firebaseMessaging;
    setupFlutterNotifications();
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidNotificationDetails = AndroidNotificationDetails(
    // channel id
    'daily_notification',
    "daily_notification",
    channelDescription: "This channel is responsible for all the local notifications",
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
  );

  static DarwinNotificationDetails _iOSNotificationDetails = DarwinNotificationDetails();

  final NotificationDetails notificationDetails = NotificationDetails(
    android: _androidNotificationDetails,
    iOS: _iOSNotificationDetails,
  );

  // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   pushNotificationService = PushNotificationService(_firebaseMessaging);
//   await pushNotificationService!.setupFlutterNotifications();
//   pushNotificationService!.showFlutterNotification(message);
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   print('Handling a background message ${message.messageId}');
// }

  Future<void> sendNotification() async {
    _firebaseMessaging.getToken(vapidKey: Constants.FIREBASE_VAPID_KEY).then((x) async {
      await _firebaseMessaging.sendMessage(
        to: x,
        data: {
          'title': 'VocabHub Test',
          'body': 'This is a VocabHub notification',
        },
        messageType: 'notification',
        // 1 day in seconds = 86400
        ttl: 86400,
      );
    });
  }

  Future<void> showFlutterNotification({RemoteMessage? message}) async {
    final message = RemoteMessage(
      notification: RemoteNotification(
        title: 'VocabHub Test',
        body: 'This is a VocabHub notification',
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
    );
  }

  Future<void> scheduleDailyNotification() async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'VocabHub Daily Streak',
        'Checkout the word of the day, and keep your streak going!',
        RepeatInterval.daily,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
  }

  Future<void> selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  @override
  Future<void> initService() async {
    final InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings(
          '@mipmap/launcher_icon',
        ),
        iOS: null,
        macOS: null);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (x) {
      print('received notification');
    }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    scheduleDailyNotification();
  }

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

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

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_icon');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//             android: initializationSettingsAndroid, iOS: null, macOS: null);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: selectNotification);
  }

  @override
  Future<void> disposeService() async {}

//   Future<void> selectNotification(String? payload) async {
//     if (payload != null) {
//       debugPrint('notification payload: $payload');
//     }
//     // await Navigator.push(
//     //   context,
//     //   MaterialPageRoute<void>(builder: (context) => SecondRoute()),
//     // );
//   }

//   Future<void> showFlutterNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//             'your channel id', 'your channel name', 'your channel description',
//             importance: Importance.max,
//             priority: Priority.high,
//             ticker: 'ticker');
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
//         message.notification!.body, platformChannelSpecifics,
//         payload: 'item x');
//   }

//   Future<void> setupFirebaseNotifications() async {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null) {
//         flutterLocalNotificationsPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             const Notii
//             ),
//             payload: 'item x');
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//     });

//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//   }
}
