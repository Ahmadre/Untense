import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:untense/app.dart';
import 'package:untense/core/services/notification_service.dart';
import 'package:untense/data/datasources/hive_datasource.dart';
import 'package:untense/di/service_locator.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash visible while initializing
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Hive local database
  await HiveDataSource.instance.initialize();

  // Initialize dependency injection
  await initDependencies();

  // Initialize notification service (mobile only)
  await NotificationService.instance.initialize();

  // Remove native splash — app is ready
  FlutterNativeSplash.remove();

  runApp(const UntenseApp());
}
