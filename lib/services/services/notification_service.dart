import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vocabhub/services/services/service_base.dart';

class NotificationService extends ServiceBase {
  NotificationService() : super();
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

  static const IOSNotificationDetails _iOSNotificationDetails = IOSNotificationDetails();

  final NotificationDetails notificationDetails = const NotificationDetails(
    android: _androidNotificationDetails,
    iOS: _iOSNotificationDetails,
  );

  @override
  Future<void> initService() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      "Hello",
      "This is a VocabHub notification",
      notificationDetails,
    );
  }

  // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   pushNotificationService = PushNotificationService(_firebaseMessaging);
//   await pushNotificationService!.setupFlutterNotifications();
//   pushNotificationService!.showFlutterNotification(message);
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   print('Handling a background message ${message.messageId}');
// }

  @override
  Future<void> disposeService() async {}
}
