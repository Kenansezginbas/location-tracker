import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<bool> getCheckInLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true; 
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

class LocationProvider extends ChangeNotifier {
  final Set<Marker> _markers = {};
  final List<LatLng> _routePoints = [];
  bool _isTracking = false;

  Set<Marker> get markers => _markers;
  List<LatLng> get routePoints => _routePoints;
  bool get isTracking => _isTracking;

  void addMarker(LatLng position, String address) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: InfoWindow(title: address),
    );
    _markers.add(marker);
    _routePoints.add(position);
    notifyListeners();
  }

  void clearRoute() {
    _markers.clear();
    _routePoints.clear();
    notifyListeners();
  }

  void setTracking(bool value) {
    _isTracking = value;
    notifyListeners();
  }
}
