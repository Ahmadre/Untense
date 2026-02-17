import 'package:equatable/equatable.dart';
import 'package:untense/domain/entities/tension_entry.dart';

/// States for the TensionBloc
abstract class TensionState extends Equatable {
  const TensionState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class TensionInitial extends TensionState {
  const TensionInitial();
}

/// State while loading entries
class TensionLoading extends TensionState {
  const TensionLoading();
}

/// State when entries are loaded successfully
class TensionLoaded extends TensionState {
  /// The entries for the selected date, sorted by timestamp
  final List<TensionEntry> entries;

  /// The currently selected date
  final DateTime selectedDate;

  /// Whether the chart is shown
  final bool isChartVisible;

  /// All dates that have entries (for history navigation)
  final List<DateTime> datesWithEntries;

  /// Monotonically increasing counter that changes on every mutation,
  /// ensuring Equatable always sees a new state after add/update/delete.
  final int revision;

  const TensionLoaded({
    required this.entries,
    required this.selectedDate,
    this.isChartVisible = true,
    this.datesWithEntries = const [],
    this.revision = 0,
  });

  TensionLoaded copyWith({
    List<TensionEntry>? entries,
    DateTime? selectedDate,
    bool? isChartVisible,
    List<DateTime>? datesWithEntries,
    int? revision,
  }) {
    return TensionLoaded(
      entries: entries ?? this.entries,
      selectedDate: selectedDate ?? this.selectedDate,
      isChartVisible: isChartVisible ?? this.isChartVisible,
      datesWithEntries: datesWithEntries ?? this.datesWithEntries,
      revision: revision ?? this.revision,
    );
  }

  /// Average tension level for the loaded entries
  double get averageTension {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.tensionLevel).reduce((a, b) => a + b) /
        entries.length;
  }

  /// Maximum tension level
  double get maxTension {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.tensionLevel).reduce((a, b) => a > b ? a : b);
  }

  /// Minimum tension level
  double get minTension {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.tensionLevel).reduce((a, b) => a < b ? a : b);
  }

  @override
  List<Object?> get props => [
    entries,
    selectedDate,
    isChartVisible,
    datesWithEntries,
    revision,
  ];
}

/// State when an error occurred
class TensionError extends TensionState {
  final String message;

  const TensionError(this.message);

  @override
  List<Object?> get props => [message];
}
