import 'package:hive_flutter/hive_flutter.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/data/models/tension_entry_model.dart';

/// Hive data source for all local database operations
class HiveDataSource {
  HiveDataSource._();
  static final HiveDataSource _instance = HiveDataSource._();
  static HiveDataSource get instance => _instance;

  late Box<TensionEntryModel> _entriesBox;
  late Box<dynamic> _settingsBox;

  bool _isInitialized = false;

  /// Initializes Hive and opens all necessary boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(AppConstants.tensionEntryAdapterId)) {
      Hive.registerAdapter(TensionEntryModelAdapter());
    }

    // Open boxes
    _entriesBox = await Hive.openBox<TensionEntryModel>(
      AppConstants.tensionEntriesBox,
    );
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);

    _isInitialized = true;
  }

  /// Returns the tension entries box
  Box<TensionEntryModel> get entriesBox {
    _assertInitialized();
    return _entriesBox;
  }

  /// Returns the settings box
  Box<dynamic> get settingsBox {
    _assertInitialized();
    return _settingsBox;
  }

  void _assertInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'HiveDataSource is not initialized. Call initialize() first.',
      );
    }
  }

  /// Closes all Hive boxes
  Future<void> close() async {
    await _entriesBox.close();
    await _settingsBox.close();
  }
}
