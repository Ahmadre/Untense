import 'package:equatable/equatable.dart';
import 'package:untense/domain/entities/tension_entry.dart';

/// Events for the TensionBloc
abstract class TensionEvent extends Equatable {
  const TensionEvent();

  @override
  List<Object?> get props => [];
}

/// Load entries for a specific date
class LoadEntriesForDate extends TensionEvent {
  final DateTime date;

  const LoadEntriesForDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Load today's entries
class LoadTodayEntries extends TensionEvent {
  const LoadTodayEntries();
}

/// Add a new tension entry
class AddTensionEntry extends TensionEvent {
  final TensionEntry entry;

  const AddTensionEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Update an existing tension entry
class UpdateTensionEntry extends TensionEvent {
  final TensionEntry entry;

  const UpdateTensionEntry(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Delete a tension entry by ID
class DeleteTensionEntry extends TensionEvent {
  final String entryId;

  const DeleteTensionEntry(this.entryId);

  @override
  List<Object?> get props => [entryId];
}

/// Toggle the chart visibility
class ToggleChartVisibility extends TensionEvent {
  const ToggleChartVisibility();
}

/// Delete all entries
class DeleteAllEntries extends TensionEvent {
  const DeleteAllEntries();
}

/// Load dates that have entries (for history)
class LoadDatesWithEntries extends TensionEvent {
  const LoadDatesWithEntries();
}
