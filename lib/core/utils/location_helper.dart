import 'package:geolocator/geolocator.dart';

class LocationHelper {
  LocationHelper._();

  static Future<bool> ensurePermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      return true;
    }

    final requested = await Geolocator.requestPermission();
    return requested == LocationPermission.always || requested == LocationPermission.whileInUse;
  }

  static Future<Position> currentPosition() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
