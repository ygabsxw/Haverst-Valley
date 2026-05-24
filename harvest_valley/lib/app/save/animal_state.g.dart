// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimalStatePersistentAdapter extends TypeAdapter<AnimalStatePersistent> {
  @override
  final int typeId = 5;

  @override
  AnimalStatePersistent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimalStatePersistent(
      id: fields[0] as String,
      specie: fields[1] as String,
      currentStateIndex: fields[2] as int,
      productionTimer: fields[3] as double,
      x: fields[4] as double,
      y: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AnimalStatePersistent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.specie)
      ..writeByte(2)
      ..write(obj.currentStateIndex)
      ..writeByte(3)
      ..write(obj.productionTimer)
      ..writeByte(4)
      ..write(obj.x)
      ..writeByte(5)
      ..write(obj.y);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalStatePersistentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
