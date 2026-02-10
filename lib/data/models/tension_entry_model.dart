import 'package:hive/hive.dart';
import 'package:untense/core/constants/app_constants.dart';
import 'package:untense/domain/entities/tension_entry.dart';

/// Hive model for [TensionEntry].
/// Manual TypeAdapter to avoid build_runner dependency.
class TensionEntryModel extends HiveObject {
  String id;
  DateTime date;
  DateTime timestamp;
  double tensionLevel;
  String? situation;
  String? feeling;
  List<String> emotions;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  TensionEntryModel({
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

  /// Converts from domain entity to Hive model
  factory TensionEntryModel.fromEntity(TensionEntry entity) {
    return TensionEntryModel(
      id: entity.id,
      date: entity.date,
      timestamp: entity.timestamp,
      tensionLevel: entity.tensionLevel,
      situation: entity.situation,
      feeling: entity.feeling,
      emotions: List<String>.from(entity.emotions),
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts from Hive model to domain entity
  TensionEntry toEntity() {
    return TensionEntry(
      id: id,
      date: date,
      timestamp: timestamp,
      tensionLevel: tensionLevel,
      situation: situation,
      feeling: feeling,
      emotions: List<String>.from(emotions),
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Manual TypeAdapter for [TensionEntryModel]
class TensionEntryModelAdapter extends TypeAdapter<TensionEntryModel> {
  @override
  final int typeId = AppConstants.tensionEntryAdapterId;

  @override
  TensionEntryModel read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < fieldsCount; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }

    return TensionEntryModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      timestamp: fields[2] as DateTime,
      tensionLevel: fields[3] as double,
      situation: fields[4] as String?,
      feeling: fields[5] as String?,
      emotions: (fields[6] as List?)?.cast<String>() ?? [],
      notes: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TensionEntryModel obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.tensionLevel)
      ..writeByte(4)
      ..write(obj.situation)
      ..writeByte(5)
      ..write(obj.feeling)
      ..writeByte(6)
      ..write(obj.emotions)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }
}
