import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location {
  static Future<Position> currentUserPosition() async {
    final prefs = await SharedPreferences.getInstance();
    LocationPermission permissionGps;
    bool activeGps = await Geolocator.isLocationServiceEnabled();
    print("Minha localização ${activeGps}");
    await prefs.setBool('isActiveGps', activeGps);
    if (!activeGps) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }
    permissionGps = await Geolocator.checkPermission();
    print("Minha permissão ${permissionGps}");
    // LocationPermission
    await prefs.setString('PemissionsGps', "${permissionGps}");
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
    print("Posição atual = $position");
    return position;
  }

  static Future returnSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final activeGps = prefs.getBool("isActiveGps");
    final permissionGps = prefs.getString("PemissionsGps");
    return {"activeGps": activeGps, "PemissionsGps": permissionGps};
  }

  static makeTodo() async {
    final prefs = await SharedPreferences.getInstance();
    LocationPermission permissionGps;
    bool activeGps = await Geolocator.isLocationServiceEnabled();
    print("Minha localização ${activeGps}");
    await prefs.setBool('isActiveGps', activeGps);
    if (!activeGps) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }
    permissionGps = await Geolocator.checkPermission();
    print("Minha permissão ${permissionGps}");
    await prefs.setString('PemissionsGps', "${permissionGps}");
    if (permissionGps == LocationPermission.denied) {
      permissionGps = await Geolocator.requestPermission();
      if (permissionGps == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }
    if (permissionGps == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }
    if (activeGps == true && permissionGps == LocationPermission.denied) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('my_foreground', 'your channel name',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              ongoing: true,
              icon: 'ic_bg_service_small');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          900,
          "permissões ativas",
          "localização ${activeGps} permissão ${permissionGps} ",
          platformChannelSpecifics,
          payload: 'item x');
    }
  }
}
