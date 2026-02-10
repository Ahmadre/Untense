import 'package:equatable/equatable.dart';

/// Domain entity representing a single tension entry
class TensionEntry extends Equatable {
  /// Unique identifier
  final String id;

  /// The date this entry belongs to (without time component)
  final DateTime date;

  /// The exact time of this entry
  final DateTime timestamp;

  /// Tension level from 0 to 100
  final double tensionLevel;

  /// Description of what happened at that time
  final String? situation;

  /// How the user feels
  final String? feeling;

  /// List of emotion keys responsible for this tension level
  final List<String> emotions;

  /// Additional notes
  final String? notes;

  /// When this entry was created
  final DateTime createdAt;

  /// When this entry was last updated
  final DateTime updatedAt;

  const TensionEntry({
    required this.id,
    required this.date,
    required this.timestamp,
    required this.tensionLevel,
    this.situation,
    this.feeling,
    this.emotions = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  TensionEntry copyWith({
    String? id,
    DateTime? date,
    DateTime? timestamp,
    double? tensionLevel,
    String? situation,
    String? feeling,
    List<String>? emotions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TensionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
      tensionLevel: tensionLevel ?? this.tensionLevel,
      situation: situation ?? this.situation,
      feeling: feeling ?? this.feeling,
      emotions: emotions ?? this.emotions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    timestamp,
    tensionLevel,
    situation,
    feeling,
    emotions,
    notes,
    createdAt,
    updatedAt,
  ];
}
