import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harvest_valley/app/save/animal_state.dart';
import 'package:harvest_valley/app/save/farm_state.dart';
import 'package:harvest_valley/app/save/quest_state.dart';
import 'package:hive/hive.dart';

part 'game_state.g.dart';

@HiveType(typeId: 0)
class GameState extends HiveObject {
  @HiveField(0)
  String currentMap;

  @HiveField(1)
  double playerX;

  @HiveField(2)
  double playerY;

  @HiveField(3)
  int money;

  @HiveField(4)
  List<InventorySlotState> inventory;

  @HiveField(5)
  List<String> collectedItems;

  @HiveField(6)
  List<String> interactedNpcs; 

  @HiveField(7)
  int diasPassados;

  @HiveField(8)
  int horarioAtual;

  @HiveField(9)
  List<FarmTileStatePersistent> farmTileStates;

  @HiveField(10)
  final DateTime lastUpdated;

  @HiveField(11)
  int reputacao;

  @HiveField(12)
  bool vendeuHoje;

  @HiveField(13)
  List<String> interactedAnimals; 

  @HiveField(14)
  List<String> animaisNoCurral;

  @HiveField(15)
  List<QuestModel> activeQuests;

  @HiveField(16)
  List<AnimalStatePersistent> animalStates;

  @HiveField(17)
  bool reciclouHoje;

  GameState({
    required this.currentMap,
    required this.playerX,
    required this.playerY,
    required this.money,
    required this.inventory,
    required this.collectedItems,
    required this.interactedNpcs,
    required this.diasPassados,
    required this.horarioAtual,
    required this.farmTileStates,
    required this.lastUpdated,
    required this.reputacao,
    required this.vendeuHoje,
    required this.interactedAnimals,
    required this.animaisNoCurral,
    required this.activeQuests,
    required this.animalStates,
    required this.reciclouHoje,
  });

  GameState copyWith({
    String? currentMap,
    double? playerX,
    double? playerY,
    int? money,
    List<InventorySlotState>? inventory,
    List<String>? collectedItems,
    List<String>? interactedNpcs,
    int? diasPassados,
    int? horarioAtual,
    List<FarmTileStatePersistent>? farmTileStates,
    DateTime? lastUpdated,
    int? reputacao,
    bool? vendeuHoje,
    List<String>? interactedAnimals,
    List<String>? animaisNoCurral,
    List<QuestModel>? activeQuests,
    List<AnimalStatePersistent>? animalStates,
    bool? reciclouHoje,
  }) {
    return GameState(
      currentMap: currentMap ?? this.currentMap,
      playerX: playerX ?? this.playerX,
      playerY: playerY ?? this.playerY,
      money: money ?? this.money,
      inventory: inventory ?? this.inventory,
      collectedItems: collectedItems ?? this.collectedItems,
      interactedNpcs: interactedNpcs ?? this.interactedNpcs,
      diasPassados: diasPassados ?? this.diasPassados,
      horarioAtual: horarioAtual ?? this.horarioAtual,
      farmTileStates: farmTileStates ?? this.farmTileStates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      reputacao: reputacao ?? this.reputacao,
      vendeuHoje: vendeuHoje ?? this.vendeuHoje,
      interactedAnimals: interactedAnimals ?? this.interactedAnimals,
      animaisNoCurral: animaisNoCurral ?? this.animaisNoCurral,
      activeQuests: activeQuests ?? this.activeQuests,
      animalStates: animalStates ?? this.animalStates,
      reciclouHoje: reciclouHoje ?? this.reciclouHoje
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentMap': currentMap,
      'playerX': playerX,
      'playerY': playerY,
      'money': money,
      'inventory': inventory.map((slot) => slot.toJson()).toList(),
      'collectedItems': collectedItems,
      'interactedNpcs': interactedNpcs,
      'diasPassados': diasPassados,
      'horarioAtual': horarioAtual,
      'farmTileStates': farmTileStates.map((tile) => tile.toJson()).toList(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'reputacao': reputacao,
      'vendeuHoje': vendeuHoje,
      'interactedAnimals': interactedAnimals,
      'animaisNoCurral': animaisNoCurral,
      'activeQuests': activeQuests.map((quest) => quest.toJson()).toList(),
      'animalStates': animalStates.map((animal) => animal.toJson()).toList(),
      'reciclouHoje': reciclouHoje,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      currentMap: json['currentMap'] as String,
      playerX: (json['playerX'] as num).toDouble(),
      playerY: (json['playerY'] as num).toDouble(),
      money: json['money'] as int,
      inventory: (json['inventory'] as List<dynamic>)
          .map(
            (item) => InventorySlotState.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      collectedItems: List<String>.from(
        json['collectedItems'] as List<dynamic>,
      ),
      interactedNpcs: List<String>.from(
        json['interactedNpcs'] as List<dynamic>,
      ),
      diasPassados: json['diasPassados'] as int,
      horarioAtual: json['horarioAtual'] as int,
      farmTileStates: (json['farmTileStates'] as List<dynamic>)
          .map(
            (item) =>
                FarmTileStatePersistent.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      lastUpdated:
          (json['lastUpdated'] as Timestamp? ??
                  Timestamp.fromMillisecondsSinceEpoch(0))
              .toDate(),
      reputacao: json['reputacao'] as int? ?? 0,
      vendeuHoje: json['vendeuHoje'] as bool? ?? false,
      interactedAnimals: List<String>.from(
        json['interactedAnimals'] as List<dynamic>,
      ),
      animaisNoCurral: List<String>.from(
        json['animaisNoCurral'] as List<dynamic>,
      ),
      activeQuests: (json['activeQuests'] as List<dynamic>? ?? [])
          .map((item) => QuestModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      animalStates: (json['animalStates'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                AnimalStatePersistent.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      reciclouHoje: json['reciclouHoje'] as bool? ?? false,
    );
  }
}

@HiveType(typeId: 1)
class InventorySlotState {
  @HiveField(0)
  String? tipo;

  @HiveField(1)
  int quantidade;

  InventorySlotState({this.tipo, this.quantidade = 0});

  Map<String, dynamic> toJson() {
    return {'tipo': tipo, 'quantidade': quantidade};
  }

  factory InventorySlotState.fromJson(Map<String, dynamic> json) {
    return InventorySlotState(
      tipo: json['tipo'] as String?,
      quantidade: json['quantidade'] as int,
    );
  }
}
