// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:ui';
import 'package:app_collect_meta/form_create_collect.dart';
import 'package:app_collect_meta/helpers/Location.dart';
import 'package:app_collect_meta/helpers/NotificationConfigs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var executeTaskCheckLocationAndPermission = false;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
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
                TextField(
                  decoration: InputDecoration(hintText: "Usuario"),
                ),
                TextField(
                  decoration: InputDecoration(hintText: "Senha"),
                ),
              ],
            ),
          ))),
    );
  }
}
