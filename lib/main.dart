import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

var teste = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'Meta Coleta', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
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
  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (teste == false) {
    teste = true;
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        saveColecterLocationPeriodic();
      }
    });
  }
}

// Future task() async {
//   final position = await getPosition();
//   print(position);
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails('my_foreground', 'your channel name',
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: true,
//           ongoing: true,
//           icon: 'ic_bg_service_small');
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//       889,
//       "Localização atual",
//       "Latitude: ${position.latitude} - Longitude: ${position.longitude}",
//       platformChannelSpecifics,
//       payload: 'item x');
// }

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

Future<Position> getPosition() async {
  LocationPermission permission;
  bool isActive = await Geolocator.isLocationServiceEnabled();
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  Position position = await Geolocator.getCurrentPosition();
  return position;
}

_getFile() async {
  final source = await getApplicationDocumentsDirectory();
  return File("${source.path}/data.json");
}

_loadSavedColecterLocationPeriodic() async {
  try {
    final file = await _getFile();
    return file.readAsString();
  } catch (error) {
    return null;
  }
}

void saveColecterLocationPeriodic() async {
  List<dynamic> positionsLoaded = [];
  _loadSavedColecterLocationPeriodic().then((data) {
    positionsLoaded = json.decode(data);
  });
  final position = await getPosition();
  final positionFormated = {
    "latitude": position.latitude,
    "longitude": position.longitude,
    "timestamp": position.timestamp,
  };
  var file = await _getFile();
  String data = json.encode([...positionsLoaded, position]);
  file.writeAsString(data);
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
            child: Column(
              children: [
                ElevatedButton(
                  child: const Text("Foreground Mode"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsForeground");
                  },
                ),
                ElevatedButton(
                  child: const Text("Background Mode"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsBackground");
                  },
                ),
                ElevatedButton(
                  child: const Text("worker"),
                  onPressed: () async {
                    saveColecterLocationPeriodic();
                  },
                ),
                ElevatedButton(
                  child: const Text("GetLocations"),
                  onPressed: () async {
                    _loadSavedColecterLocationPeriodic().then((data) {
                      setState(() {
                        list = json.decode(data);
                      });
                    });
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
                Text('Quantidade de pontos de localização: ${list.length}'),
                Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = list[index]["longitude"];
                        return ListTile(
                          title: Text("$item"),
                        );
                      },
                    )),
              ],
            ),
          )),
    );
  }
}
