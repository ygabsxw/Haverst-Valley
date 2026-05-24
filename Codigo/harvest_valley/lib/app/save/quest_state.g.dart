// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestModelAdapter extends TypeAdapter<QuestModel> {
  @override
  final int typeId = 3;

  @override
  QuestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      targetAmount: fields[3] as int,
      currentAmount: fields[4] as int,
      status: fields[5] as QuestStatus,
      rewardText: fields[6] as String,
      targetItem: fields[7] as String?,
      npcName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuestModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.currentAmount)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.rewardText)
      ..writeByte(7)
      ..write(obj.targetItem)
      ..writeByte(8)
      ..write(obj.npcName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestStatusAdapter extends TypeAdapter<QuestStatus> {
  @override
  final int typeId = 4;

  @override
  QuestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestStatus.active;
      case 1:
        return QuestStatus.ready;
      case 2:
        return QuestStatus.finished;
      default:
        return QuestStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, QuestStatus obj) {
    switch (obj) {
      case QuestStatus.active:
        writer.writeByte(0);
        break;
      case QuestStatus.ready:
        writer.writeByte(1);
        break;
      case QuestStatus.finished:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
