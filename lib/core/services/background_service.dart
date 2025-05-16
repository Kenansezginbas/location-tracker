import 'dart:async';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker/core/services/map_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  final MapService _mapService;
  final VoidCallback onMarkersChanged;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;
  static const String _routeKey = 'saved_route';

  BackgroundService(this._mapService, {required this.onMarkersChanged});

  Future<void> startTracking() async {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) async {
      if (_lastPosition == null ||
          Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                position.latitude,
                position.longitude,
              ) >
              100) {
        _lastPosition = position;

        final address = await _mapService.getAddressFromLatLng(
          LatLng(position.latitude, position.longitude),
        );

        _mapService.addMarker(
          LatLng(position.latitude, position.longitude),
          address,
        );
        onMarkersChanged();
        await _saveRoute();
      }
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
  }

  Future<void> _saveRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final routePoints = _mapService.routePoints
        .map((point) => '${point.latitude},${point.longitude}')
        .toList();
    await prefs.setStringList(_routeKey, routePoints);
  }

  Future<void> loadSavedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoute = prefs.getStringList(_routeKey);

    if (savedRoute != null) {
      for (final point in savedRoute) {
        final coords = point.split(',');
        final latLng = LatLng(
          double.parse(coords[0]),
          double.parse(coords[1]),
        );
        final address = await _mapService.getAddressFromLatLng(latLng);
        _mapService.addMarker(latLng, address);
      }
    }
  }

  void clearRoute() {
    _mapService.clearRoute();
    SharedPreferences.getInstance().then((prefs) => prefs.remove(_routeKey));
  }
}
