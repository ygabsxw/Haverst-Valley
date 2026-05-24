import 'package:harvest_valley/app/save/animal_state.dart';

class AnimalRuntimeState {
  final String id;
  String specie;
  int currentStateIndex;
  double
  productionTimer;
  double x;
  double y;

  AnimalRuntimeState({
    required this.id,
    required this.specie,
    this.currentStateIndex = 0,
    this.productionTimer = 0.0,
    this.x = 0,
    this.y = 0,
  });
}

class AnimalManager {
  AnimalManager._privateConstructor();
  static final AnimalManager instance = AnimalManager._privateConstructor();

  final Map<String, AnimalRuntimeState> _animalStates = {};

  void reset() {
    _animalStates.clear();
  }

  void updateAnimalState(String id, AnimalRuntimeState state) {
    _animalStates[id] = state;
  }

  AnimalRuntimeState? getAnimalState(String id) {
    return _animalStates[id];
  }

  void loadFromStates(List<AnimalStatePersistent> states) {
    _animalStates.clear();

    for (var s in states) {
      final runtime = AnimalRuntimeState(
        id: s.id,
        specie: s.specie,
        currentStateIndex: s.currentStateIndex,
        productionTimer: s.productionTimer,
        x: s.x,
        y: s.y,
      );
      _animalStates[s.id] = runtime;
    }
  }

  List<AnimalStatePersistent> toPersistentStates() {
    return _animalStates.entries.map((entry) {
      return AnimalStatePersistent(
        id: entry.key,
        specie: entry.value.specie,
        currentStateIndex: entry.value.currentStateIndex,
        productionTimer: entry.value.productionTimer,
        x: entry.value.x,
        y: entry.value.y,
      );
    }).toList();
  }

  List<AnimalRuntimeState> getAnimalsToSpawn() {
    return _animalStates.values.toList();
  }
}
