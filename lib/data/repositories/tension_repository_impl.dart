import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/data/datasources/hive_datasource.dart';
import 'package:untense/data/models/tension_entry_model.dart';
import 'package:untense/domain/entities/tension_entry.dart';
import 'package:untense/domain/repositories/tension_repository.dart';

/// Concrete implementation of [TensionRepository] using Hive
class TensionRepositoryImpl implements TensionRepository {
  final HiveDataSource _dataSource;

  TensionRepositoryImpl({required HiveDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<List<TensionEntry>> getEntriesByDate(DateTime date) async {
    final startOfDay = AppDateTimeUtils.startOfDay(date);
    final endOfDay = AppDateTimeUtils.endOfDay(date);

    final models = _dataSource.entriesBox.values.where((model) {
      return !model.date.isBefore(startOfDay) && !model.date.isAfter(endOfDay);
    }).toList();

    // Sort by timestamp ascending
    models.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TensionEntry>> getEntriesBetween(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = AppDateTimeUtils.startOfDay(startDate);
    final end = AppDateTimeUtils.endOfDay(endDate);

    final models = _dataSource.entriesBox.values.where((model) {
      return !model.date.isBefore(start) && !model.date.isAfter(end);
    }).toList();

    models.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TensionEntry?> getEntryById(String id) async {
    try {
      final model = _dataSource.entriesBox.values.firstWhere((m) => m.id == id);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addEntry(TensionEntry entry) async {
    final model = TensionEntryModel.fromEntity(entry);
    await _dataSource.entriesBox.put(entry.id, model);
  }

  @override
  Future<void> updateEntry(TensionEntry entry) async {
    final model = TensionEntryModel.fromEntity(entry);
    await _dataSource.entriesBox.put(entry.id, model);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _dataSource.entriesBox.delete(id);
  }

  @override
  Future<void> deleteAllEntries() async {
    await _dataSource.entriesBox.clear();
  }

  @override
  Future<List<DateTime>> getDatesWithEntries() async {
    final dates = <DateTime>{};
    for (final model in _dataSource.entriesBox.values) {
      dates.add(AppDateTimeUtils.startOfDay(model.date));
    }
    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));
    return sortedDates;
  }
}
