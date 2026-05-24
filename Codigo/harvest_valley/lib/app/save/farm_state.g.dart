// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FarmTileStatePersistentAdapter
    extends TypeAdapter<FarmTileStatePersistent> {
  @override
  final int typeId = 2;

  @override
  FarmTileStatePersistent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FarmTileStatePersistent(
      key: fields[0] as String,
      molhado: fields[1] as bool,
      timeWateredInGameMinutes: fields[2] as int?,
      cropType: fields[3] as String?,
      growthStage: fields[4] as int,
      growthProgress: fields[5] as double,
      lastSyncGameMinutes: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FarmTileStatePersistent obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.molhado)
      ..writeByte(2)
      ..write(obj.timeWateredInGameMinutes)
      ..writeByte(3)
      ..write(obj.cropType)
      ..writeByte(4)
      ..write(obj.growthStage)
      ..writeByte(5)
      ..write(obj.growthProgress)
      ..writeByte(6)
      ..write(obj.lastSyncGameMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmTileStatePersistentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
