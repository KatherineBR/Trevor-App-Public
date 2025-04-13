import 'package:geolocator/geolocator.dart'; // Import geolocator.dart

class LocationService {
  static Future<String> getUserCountry() async {
    // Check Location Permission
    LocationPermission permission = await Geolocator.checkPermission();
    // If permission for location is denied, ask with a pop up if they want to give permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // if they deny, default location to US
      if (permission == LocationPermission.denied) {
        return 'US';
      }
    }
    // if permission is denied forever
    if (permission == LocationPermission.deniedForever) {
      return 'US';
    }

    Position position = await Geolocator.getCurrentPosition();
    // longitude and latitude of Mexico
    if (position.latitude >= 14 && position.latitude <= 33 && position.longitude >= -119 && position.longitude <= -86){
      return 'MX';
    }

    // if anything goes wrong, default location is US
    return 'US';
  }
}


