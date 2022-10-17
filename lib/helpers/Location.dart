import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Location {
  
  static Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'Meta Coleta',
    description:
        'This channel is used for important notifications.',
    importance: Importance.low, 
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Meta Coleta',
      initialNotificationContent:
          'Seus dados são coletados durante o trajeto da coleta!',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}


  static Future checkLocationAndPermission() async {
    bool activeGps = await Geolocator.isLocationServiceEnabled();
    LocationPermission permissionGps;
    permissionGps = await Geolocator.checkPermission();
    print(activeGps);
    print(permissionGps);
    if (permissionGps == LocationPermission.deniedForever ||permissionGps == LocationPermission.denied) {
      await showNotification(
        "Você negou as permissões de uso do GPS, por favor habilite-as para ativar os recursos de monitoramento do app."
      );
    }
    if (activeGps == false) {
      await showNotification(
        "Você esta com GPS desativado, ative o GPS para ativar os recursos de monitoramento do app.",
      );
    }
  }

  static showNotification(String subtitle) async {
    {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('my_foreground', 'your channel name',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              ongoing: false,
              icon: 'ic_bg_service_small');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          900, "Meta Coleta", subtitle, platformChannelSpecifics,
          payload: 'item x');
    }
  }

  static Future<Position> currentUserPosition() async {
    LocationPermission permissionGps;
    bool activeGps = await Geolocator.isLocationServiceEnabled();
    if (!activeGps) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }
    permissionGps = await Geolocator.checkPermission();
    if (permissionGps == LocationPermission.denied) {
      permissionGps = await Geolocator.requestPermission();
      if (permissionGps == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }
    if (permissionGps == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }
    final position = await Geolocator.getCurrentPosition();
    return position;
  }

  static Future returnSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final activeGps = prefs.getBool("isActiveGps");
    final permissionGps = prefs.getString("PemissionsGps");
    print({"activeGps": activeGps, "PemissionsGps": permissionGps});
    return {"activeGps": activeGps, "PemissionsGps": permissionGps};
  }
}
