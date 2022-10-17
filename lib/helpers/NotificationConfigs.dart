import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationConfigs {
  static Future<void> configureAndroidNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
    late AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    late InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin
      .initialize(initializationSettings);
  }
}
