import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

Future getLocation() async{
  Position position =  await Geolocator.getCurrentPosition();
  print(position);
}

getLocation2() async{
  Position position =  await Geolocator.getCurrentPosition();
  print(position);
}

void calbackFunc() async {
  Workmanager().executeTask((taskName, inputData) async{
    DartPluginRegistrant.ensureInitialized();
    switch (taskName) {
      case 'getGpsLocationFromCollect':
        await getLocation();
        break;
      case 'gpsTest':
        await getLocation2();
        break;
      default:
    }
    return Future.value(false);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    calbackFunc, 
    isInDebugMode: true
  );
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  void getGps() async {
    var id = DateTime.now().second.toString();
    await Workmanager().registerPeriodicTask(
      id,
      "getGpsLocationFromCollect",
      frequency: Duration(seconds: 15),
    );
  }

  void getGps2() async {
    var id = DateTime.now().second.toString();
    await Workmanager().registerPeriodicTask(
      id,
      "gpsTest",
      frequency: Duration(seconds: 15),
    );
  }

  getPosition() async {
  LocationPermission permission;
  bool isActive = await Geolocator.isLocationServiceEnabled();
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  Position myPosition = await Geolocator.getCurrentPosition();
  print({
    "latitude": myPosition.latitude, 
    "longitude": myPosition.longitude
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Workamanager"),
        ),
        body: Container(
            child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text("Ativar GPS"),
                onPressed: () async {
                  print(getPosition());
                },
              ),
              ElevatedButton(
                child: Text("Ativar worker "),
                onPressed: () async {
                  getGps();
                },
              ),
              ElevatedButton(
                child: Text("Ativar worker 2"),
                onPressed: () async {
                  getGps2();
                },
              ),
            ],
          ),
        )));
  }
}
