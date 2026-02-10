import 'package:get_it/get_it.dart';
import 'package:untense/data/datasources/hive_datasource.dart';
import 'package:untense/data/repositories/settings_repository_impl.dart';
import 'package:untense/data/repositories/tension_repository_impl.dart';
import 'package:untense/domain/repositories/settings_repository.dart';
import 'package:untense/domain/repositories/tension_repository.dart';
import 'package:untense/presentation/bloc/settings/settings_bloc.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';

/// Service locator using GetIt for dependency injection.
/// Follows the Dependency Inversion Principle.
final GetIt sl = GetIt.instance;

/// Initializes all dependencies.
/// Must be called once at app startup after Hive is initialized.
Future<void> initDependencies() async {
  // ============== Data Sources ==============
  sl.registerLazySingleton<HiveDataSource>(() => HiveDataSource.instance);

  // ============== Repositories ==============
  sl.registerLazySingleton<TensionRepository>(
    () => TensionRepositoryImpl(dataSource: sl<HiveDataSource>()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(dataSource: sl<HiveDataSource>()),
  );

  // ============== BLoCs ==============
  sl.registerFactory<TensionBloc>(
    () => TensionBloc(tensionRepository: sl<TensionRepository>()),
  );

  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(settingsRepository: sl<SettingsRepository>()),
  );
}
