import 'package:flutter/material.dart';
import 'package:untense/app.dart';
import 'package:untense/core/services/notification_service.dart';
import 'package:untense/data/datasources/hive_datasource.dart';
import 'package:untense/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local database
  await HiveDataSource.instance.initialize();

  // Initialize dependency injection
  await initDependencies();

  // Initialize notification service (mobile only)
  await NotificationService.instance.initialize();

  runApp(const UntenseApp());
}
