import 'package:flutter/material.dart';
import 'package:location_tracker/modules/home/home_view.dart';
import 'package:provider/provider.dart';
import 'package:location_tracker/core/services/location_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomeView(),
    );
  }
}
