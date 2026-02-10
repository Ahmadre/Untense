import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show ThemeMode, TimeOfDay;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untense/data/datasources/hive_datasource.dart';
import 'package:untense/data/models/tension_entry_model.dart';
import 'package:untense/di/service_locator.dart';
import 'package:untense/domain/entities/day_config.dart';
import 'package:untense/domain/entities/tension_entry.dart';
import 'package:untense/domain/repositories/settings_repository.dart';
import 'package:untense/domain/repositories/tension_repository.dart';

/// What to include in an export
enum ExportScope { entriesOnly, settingsOnly, both }

/// Result of an import operation
class ImportResult {
  final int entriesImported;
  final bool settingsImported;
  final String? error;

  const ImportResult({
    this.entriesImported = 0,
    this.settingsImported = false,
    this.error,
  });

  bool get hasError => error != null;
}

/// Service for exporting and importing app data as cross-platform JSON.
class DataExportService {
  static const String _formatVersion = '1';
  static const String _fileExtension = 'json';

  // ======================== EXPORT ========================

  /// Builds the export JSON map based on the scope.
  Future<Map<String, dynamic>> buildExportData(ExportScope scope) async {
    final data = <String, dynamic>{
      'format': 'untense-backup',
      'version': _formatVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
    };

    if (scope == ExportScope.entriesOnly || scope == ExportScope.both) {
      data['entries'] = await _exportEntries();
    }

    if (scope == ExportScope.settingsOnly || scope == ExportScope.both) {
      data['settings'] = await _exportSettings();
    }

    return data;
  }

  /// Exports data as a JSON string and shares/downloads it.
  Future<bool> exportAndShare(ExportScope scope) async {
    try {
      final data = await buildExportData(scope);
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'untense_backup_$timestamp.$_fileExtension';

      if (kIsWeb) {
        // On web, use FilePicker to save
        final bytes = utf8.encode(jsonString);
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Untense Backup',
          fileName: fileName,
          bytes: bytes,
        );
        return result != null;
      } else {
        // On mobile/desktop, use share_plus with XFile
        final bytes = utf8.encode(jsonString);
        final xfile = XFile.fromData(
          bytes,
          name: fileName,
          mimeType: 'application/json',
        );
        final result = await SharePlus.instance.share(
          ShareParams(files: [xfile]),
        );
        return result.status == ShareResultStatus.success ||
            result.status == ShareResultStatus.dismissed;
      }
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _exportEntries() async {
    final dataSource = sl<HiveDataSource>();
    final models = dataSource.entriesBox.values.toList();
    return models.map(_tensionEntryToJson).toList();
  }

  Future<Map<String, dynamic>> _exportSettings() async {
    final repo = sl<SettingsRepository>();
    final config = await repo.loadSettings();
    return _dayConfigToJson(config);
  }

  Map<String, dynamic> _tensionEntryToJson(TensionEntryModel model) {
    return {
      'id': model.id,
      'date': model.date.toUtc().toIso8601String(),
      'timestamp': model.timestamp.toUtc().toIso8601String(),
      'tensionLevel': model.tensionLevel,
      'situation': model.situation,
      'feeling': model.feeling,
      'emotions': model.emotions,
      'notes': model.notes,
      'createdAt': model.createdAt.toUtc().toIso8601String(),
      'updatedAt': model.updatedAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _dayConfigToJson(DayConfig config) {
    return {
      'dayStartHour': config.dayStart.hour,
      'dayStartMinute': config.dayStart.minute,
      'dayEndHour': config.dayEnd.hour,
      'dayEndMinute': config.dayEnd.minute,
      'intervalMinutes': config.intervalMinutes,
      'reminderEnabled': config.reminderEnabled,
      'reminderMinutesBefore': config.reminderMinutesBefore,
      'themeMode': config.themeMode.name,
      'locale': config.locale,
    };
  }

  // ======================== IMPORT ========================

  /// Lets the user pick a JSON file and returns the parsed data.
  /// Returns null if the user cancelled.
  Future<Map<String, dynamic>?> pickAndReadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [_fileExtension],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final bytes = result.files.first.bytes;
      if (bytes == null) return null;

      final jsonString = utf8.decode(bytes);
      final data = json.decode(jsonString);
      if (data is! Map<String, dynamic>) return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Validates that the file is a valid Untense backup.
  bool isValidBackup(Map<String, dynamic> data) {
    return data['format'] == 'untense-backup' && data['version'] != null;
  }

  /// Describes what the backup file contains.
  BackupContents describeBackup(Map<String, dynamic> data) {
    final hasEntries = data.containsKey('entries') && data['entries'] is List;
    final hasSettings = data.containsKey('settings') && data['settings'] is Map;
    final entryCount = hasEntries ? (data['entries'] as List).length : 0;
    final exportedAt = data['exportedAt'] as String?;

    return BackupContents(
      hasEntries: hasEntries,
      hasSettings: hasSettings,
      entryCount: entryCount,
      exportedAt: exportedAt != null ? DateTime.tryParse(exportedAt) : null,
    );
  }

  /// Imports entries from backup data. Existing entries with the same ID
  /// will be overwritten, new entries are added.
  Future<ImportResult> importEntries(Map<String, dynamic> data) async {
    try {
      if (!data.containsKey('entries') || data['entries'] is! List) {
        return const ImportResult(error: 'No entries found in backup.');
      }

      final entriesList = data['entries'] as List;
      final repo = sl<TensionRepository>();
      int count = 0;

      for (final raw in entriesList) {
        if (raw is! Map<String, dynamic>) continue;
        final entry = _tensionEntryFromJson(raw);
        if (entry == null) continue;
        await repo.addEntry(entry); // addEntry does put() → upserts by ID
        count++;
      }

      return ImportResult(entriesImported: count);
    } catch (e) {
      return ImportResult(error: e.toString());
    }
  }

  /// Imports settings from backup data.
  Future<ImportResult> importSettings(Map<String, dynamic> data) async {
    try {
      if (!data.containsKey('settings') || data['settings'] is! Map) {
        return const ImportResult(error: 'No settings found in backup.');
      }

      final raw = data['settings'] as Map<String, dynamic>;
      final config = _dayConfigFromJson(raw);
      final repo = sl<SettingsRepository>();
      await repo.saveSettings(config);

      return const ImportResult(settingsImported: true);
    } catch (e) {
      return ImportResult(error: e.toString());
    }
  }

  /// Imports everything the user selected.
  Future<ImportResult> importAll(
    Map<String, dynamic> data, {
    required bool includeEntries,
    required bool includeSettings,
  }) async {
    int totalEntries = 0;
    bool settingsDone = false;

    if (includeEntries) {
      final r = await importEntries(data);
      if (r.hasError) return r;
      totalEntries = r.entriesImported;
    }

    if (includeSettings) {
      final r = await importSettings(data);
      if (r.hasError) return r;
      settingsDone = r.settingsImported;
    }

    return ImportResult(
      entriesImported: totalEntries,
      settingsImported: settingsDone,
    );
  }

  // ======================== JSON → Entity ========================

  TensionEntry? _tensionEntryFromJson(Map<String, dynamic> json) {
    try {
      return TensionEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String).toLocal(),
        timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
        tensionLevel: (json['tensionLevel'] as num).toDouble(),
        situation: json['situation'] as String?,
        feeling: json['feeling'] as String?,
        emotions: (json['emotions'] as List?)?.cast<String>() ?? [],
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
      );
    } catch (_) {
      return null;
    }
  }

  DayConfig _dayConfigFromJson(Map<String, dynamic> json) {
    return DayConfig(
      dayStart: TimeOfDay(
        hour: json['dayStartHour'] as int? ?? 8,
        minute: json['dayStartMinute'] as int? ?? 0,
      ),
      dayEnd: TimeOfDay(
        hour: json['dayEndHour'] as int? ?? 22,
        minute: json['dayEndMinute'] as int? ?? 0,
      ),
      intervalMinutes: json['intervalMinutes'] as int? ?? 120,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderMinutesBefore: json['reminderMinutesBefore'] as int? ?? 5,
      themeMode: _parseThemeMode(json['themeMode'] as String?),
      locale: json['locale'] as String? ?? 'de-DE',
    );
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Describes the contents of a parsed backup file.
class BackupContents {
  final bool hasEntries;
  final bool hasSettings;
  final int entryCount;
  final DateTime? exportedAt;

  const BackupContents({
    required this.hasEntries,
    required this.hasSettings,
    required this.entryCount,
    this.exportedAt,
  });
}
