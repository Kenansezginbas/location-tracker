import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapService {
  final Set<Marker> _markers = {};
  final List<LatLng> _routePoints = [];

  Set<Marker> get markers => _markers;
  List<LatLng> get routePoints => _routePoints;

  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Address not found';
    } catch (e) {
      return 'Error getting address';
    }
  }

  void addMarker(LatLng position, String address) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: InfoWindow(title: address),
    );

    _markers.add(marker);
    _routePoints.add(position);
  }

  void clearRoute() {
    _markers.clear();
    _routePoints.clear();
  }
}
