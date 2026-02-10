import 'package:untense/domain/entities/tension_entry.dart';

/// Abstract repository for tension entry operations.
/// Follows the Dependency Inversion Principle (DIP).
abstract class TensionRepository {
  /// Retrieves all entries for a given date
  Future<List<TensionEntry>> getEntriesByDate(DateTime date);

  /// Retrieves all entries between two dates (inclusive)
  Future<List<TensionEntry>> getEntriesBetween(
    DateTime startDate,
    DateTime endDate,
  );

  /// Retrieves a single entry by its ID
  Future<TensionEntry?> getEntryById(String id);

  /// Adds a new tension entry
  Future<void> addEntry(TensionEntry entry);

  /// Updates an existing tension entry
  Future<void> updateEntry(TensionEntry entry);

  /// Deletes a tension entry by ID
  Future<void> deleteEntry(String id);

  /// Deletes all entries
  Future<void> deleteAllEntries();

  /// Returns all unique dates that have entries
  Future<List<DateTime>> getDatesWithEntries();
}
