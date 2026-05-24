import 'package:hive/hive.dart';

part 'farm_state.g.dart';

@HiveType(typeId: 2) // Certifique-se de que typeId é único
class FarmTileStatePersistent extends HiveObject {
  @HiveField(0)
  final String key; // A chave do tile, ex: "1104.0,384.0"

  @HiveField(1)
  bool molhado;

  @HiveField(2)
  // MUDANÇA IMPORTANTE: Registrar o tempo de rega em minutos de jogo (int)
  int? timeWateredInGameMinutes;

  @HiveField(3)
  String? cropType;

  @HiveField(4)
  int growthStage;

  @HiveField(5)
  double growthProgress;

  @HiveField(6)
  int lastSyncGameMinutes;

  FarmTileStatePersistent({
    required this.key,
    this.molhado = false,
    this.timeWateredInGameMinutes,
    this.cropType,
    this.growthStage = 0,
    this.growthProgress = 0.0,
    this.lastSyncGameMinutes = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'molhado': molhado,
      'timeWateredInGameMinutes': timeWateredInGameMinutes,
      'cropType': cropType,
      'growthStage': growthStage,
      'growthProgress': growthProgress,
      'lastSyncGameMinutes': lastSyncGameMinutes,
    };
  }

  factory FarmTileStatePersistent.fromJson(Map<String, dynamic> json) {
    return FarmTileStatePersistent(
      key: json['key'] as String,
      molhado: json['molhado'] as bool,
      timeWateredInGameMinutes: json['timeWateredInGameMinutes'] as int?,
      cropType: json['cropType'] as String?,
      growthStage: json['growthStage'] as int,
      growthProgress: (json['growthProgress'] as num)
          .toDouble(), // Converte num para double
      lastSyncGameMinutes: json['lastSyncGameMinutes'] as int,
    );
  }
}
