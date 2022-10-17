import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'uniqueKey2') {
      ///do the task in Backend for how and when to send notification
      var response = await http.get(Uri.parse('https://reqres.in/api/users/2'));
      Map dataComingFromTheServer = json.decode(response.body);

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('your channel id', 'your channel name',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false);
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0,
          dataComingFromTheServer['data']['first_name'],
          dataComingFromTheServer['data']['email'],
          platformChannelSpecifics,
          payload: 'item x');
    }

  
    await getPosition();
    return Future.value(true);
  });
}

 Future getPosition() async{
    LocationPermission permission;
    bool isActive = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      return permission = await Geolocator.requestPermission();
    }
    Position posicao = await Geolocator.getCurrentPosition();
    print(posicao.latitude);
    print(posicao.longitude);

  }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings(
      '@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  Workmanager().initialize(
      callbackDispatcher);

  Workmanager().registerPeriodicTask(
    "3",
    "uniqueKey3",
    frequency: Duration(seconds: 15),
  );
  runApp(MyApp());
}

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing Notification in Background'),
      ),
    );
  }
}