// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 0;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      currentMap: fields[0] as String,
      playerX: fields[1] as double,
      playerY: fields[2] as double,
      money: fields[3] as int,
      inventory: (fields[4] as List).cast<InventorySlotState>(),
      collectedItems: (fields[5] as List).cast<String>(),
      interactedNpcs: (fields[6] as List).cast<String>(),
      diasPassados: fields[7] as int,
      horarioAtual: fields[8] as int,
      farmTileStates: (fields[9] as List).cast<FarmTileStatePersistent>(),
      lastUpdated: fields[10] as DateTime,
      reputacao: fields[11] as int,
      vendeuHoje: fields[12] as bool,
      interactedAnimals: (fields[13] as List).cast<String>(),
      animaisNoCurral: (fields[14] as List).cast<String>(),
      activeQuests: (fields[15] as List).cast<QuestModel>(),
      animalStates: (fields[16] as List).cast<AnimalStatePersistent>(),
      reciclouHoje: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.currentMap)
      ..writeByte(1)
      ..write(obj.playerX)
      ..writeByte(2)
      ..write(obj.playerY)
      ..writeByte(3)
      ..write(obj.money)
      ..writeByte(4)
      ..write(obj.inventory)
      ..writeByte(5)
      ..write(obj.collectedItems)
      ..writeByte(6)
      ..write(obj.interactedNpcs)
      ..writeByte(7)
      ..write(obj.diasPassados)
      ..writeByte(8)
      ..write(obj.horarioAtual)
      ..writeByte(9)
      ..write(obj.farmTileStates)
      ..writeByte(10)
      ..write(obj.lastUpdated)
      ..writeByte(11)
      ..write(obj.reputacao)
      ..writeByte(12)
      ..write(obj.vendeuHoje)
      ..writeByte(13)
      ..write(obj.interactedAnimals)
      ..writeByte(14)
      ..write(obj.animaisNoCurral)
      ..writeByte(15)
      ..write(obj.activeQuests)
      ..writeByte(16)
      ..write(obj.animalStates)
      ..writeByte(17)
      ..write(obj.reciclouHoje);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventorySlotStateAdapter extends TypeAdapter<InventorySlotState> {
  @override
  final int typeId = 1;

  @override
  InventorySlotState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventorySlotState(
      tipo: fields[0] as String?,
      quantidade: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, InventorySlotState obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.tipo)
      ..writeByte(1)
      ..write(obj.quantidade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventorySlotStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
