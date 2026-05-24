import 'package:hive/hive.dart';

part 'quest_state.g.dart';

@HiveType(typeId: 4)
enum QuestStatus {
  @HiveField(0) // comecou
  active,
  @HiveField(1) // pronta para entregar
  ready,
  @HiveField(2) // concluida
  finished,
}

@HiveType(typeId: 3)
class QuestModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int targetAmount;

  @HiveField(4)
  int currentAmount;

  @HiveField(5)
  QuestStatus status;

  @HiveField(6)
  final String rewardText;

  @HiveField(7)
  final String? targetItem;

  @HiveField(8)
  final String? npcName;

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    this.targetAmount = 1,
    this.currentAmount = 0,
    this.status = QuestStatus.active,
    this.rewardText = "",
    this.targetItem,
    this.npcName,
  });

  // Adiciona progresso e verifica se completou
  void addProgress(int amount) {
    if (status != QuestStatus.active) return;

    currentAmount += amount;
    if (currentAmount >= targetAmount) {
      currentAmount = targetAmount;
      status = QuestStatus.ready; // Pronto para entregar
    }
  }

  // Converte para JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'status': status.index, // Salva o índice do Enum (0, 1 ou 2)
      'rewardText': rewardText,
      'targetItem': targetItem,
      'npcName': npcName,
    };
  }

  // Cria a partir do JSON
  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      status: QuestStatus.values[json['status'] ?? 0],
      rewardText: json['rewardText'],
      targetItem: json['targetItem'],
      npcName: json['npcName'],
    );
  }
}
