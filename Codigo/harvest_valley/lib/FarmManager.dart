import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/app/save/farm_state.dart';

class FarmTileState {
  bool molhado;
  int? timeWateredInGameMinutes;
  String? cropType;
  int growthStage;
  double growthProgress;
  int lastSyncGameMinutes;
  bool isOccupiedByWheatTop;

  FarmTileState({
    this.molhado = false,
    this.timeWateredInGameMinutes,
    this.cropType,
    this.growthStage = 0,
    this.growthProgress = 0.0,
    this.lastSyncGameMinutes = 0,
    this.isOccupiedByWheatTop = false,
  });
}

class FarmManager {
  static const int dryTimeInGameMinutes = 30;
  static const int growTimeInSeconds = 5;

  FarmManager._privateConstructor();
  static final FarmManager instance = FarmManager._privateConstructor();

  final Map<String, FarmTileState> _tileStates = {};

  void reset() {
    _tileStates.clear();
    print('FarmManager resetado. Todos os estados de tiles foram limpos.');
  }

  void loadFromStates(List<FarmTileStatePersistent> states) {
    _tileStates.clear();
    for (var state in states) {
      // Converte o estado persistente de volta para o estado em memória
      _tileStates[state.key] = FarmTileState(
        molhado: state.molhado,
        // Certifique-se de usar o nome correto aqui
        timeWateredInGameMinutes: state.timeWateredInGameMinutes,
        cropType: state.cropType,
        growthStage: state.growthStage,
        growthProgress: state.growthProgress,
        lastSyncGameMinutes: state.lastSyncGameMinutes,
      );
    }
  }

  List<FarmTileStatePersistent> toPersistentStates() {
    // Salva apenas os tiles que foram alterados (não estão no estado padrão)
    return _tileStates.entries
        .where((entry) => entry.value.molhado || entry.value.cropType != null)
        .map((entry) {
          return FarmTileStatePersistent(
            key: entry.key,
            molhado: entry.value.molhado,
            timeWateredInGameMinutes: entry.value.timeWateredInGameMinutes,
            cropType: entry.value.cropType,
            growthStage: entry.value.growthStage,
            growthProgress: entry.value.growthProgress,
            lastSyncGameMinutes: entry.value.lastSyncGameMinutes,
          );
        })
        .toList();
  }

  FarmTileState getTileState(Vector2 position) {
    String key = _positionToKey(position);

    if (!_tileStates.containsKey(key)) {
      _tileStates[key] = FarmTileState();
    }

    return _tileStates[key]!;
  }

  String _positionToKey(Vector2 position) {
    return "${position.x},${position.y}";
  }
}
