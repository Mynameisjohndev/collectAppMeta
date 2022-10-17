import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:app_collect_meta/helpers/Location.dart';
import 'package:app_collect_meta/helpers/NotificationConfigs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

var executeTaskCheckLocationAndPermission = false;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (executeTaskCheckLocationAndPermission == false) {
    executeTaskCheckLocationAndPermission = true;
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (service is AndroidServiceInstance) {
        Location.checkLocationAndPermission();
      }
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationConfigs.configureAndroidNotification();
  await Location.initializeService();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

Future stopNotification() async {
  final service = FlutterBackgroundService();
  var isRunning = await service.isRunning();
  service.startService();
}

class _MyAppState extends State<MyApp> {
  String text = "Stop Service";
  List<dynamic> list = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Service App'),
          ),
          body: SingleChildScrollView(
              child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  child: Text("Liberar GPS"),
                  onPressed: () {
                    Location.currentUserPosition();
                  },
                ),
                ElevatedButton(
                  child: Text(text),
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    if (isRunning) {
                      service.invoke("stopService");
                    } else {
                      service.startService();
                    }

                    if (!isRunning) {
                      text = 'Stop Service';
                    } else {
                      text = 'Start Service';
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ))),
    );
  }
}
