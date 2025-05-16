import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_tracker/core/services/location_service.dart';
import 'package:location_tracker/core/services/map_service.dart';
import 'package:location_tracker/core/services/background_service.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final LocationService _locationService = LocationService();
  final MapService _mapService = MapService();
  late final BackgroundService _backgroundService;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _backgroundService = BackgroundService(
      _mapService,
      onMarkersChanged: () => setState(() {}),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).clearRoute();
    });
  }

  Future<void> _startTracking(BuildContext context) async {
    final hasPermission = await _locationService.getCheckInLocation();
    if (!context.mounted) return;
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konum izni verilmedi.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    Provider.of<LocationProvider>(context, listen: false).setTracking(true);
  }

  void _stopTracking(BuildContext context) {
    Provider.of<LocationProvider>(context, listen: false).setTracking(false);
  }

  void _clearRoute(BuildContext context) {
    Provider.of<LocationProvider>(context, listen: false).clearRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Konum Takip'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _clearRoute(context),
                tooltip: 'Rotayı Temizle',
              ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(41.0082, 28.9784), // Istanbul
                  zoom: 12,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: locationProvider.markers,
                polylines: {
                  Polyline(
                    polylineId: PolylineId('route'),
                    color: Colors.blue,
                    width: 4,
                    points: locationProvider.routePoints,
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onTap: (position) async {
                  final address =
                      await _mapService.getAddressFromLatLng(position);
                  locationProvider.addMarker(position, address);
                },
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: locationProvider.isTracking
                          ? () => _stopTracking(context)
                          : () => _startTracking(context),
                      icon: Icon(locationProvider.isTracking
                          ? Icons.stop
                          : Icons.play_arrow),
                      label: Text(locationProvider.isTracking
                          ? 'Takibi Durdur'
                          : 'Takibi Başlat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: locationProvider.isTracking
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
