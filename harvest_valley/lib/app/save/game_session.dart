import 'package:harvest_valley/FarmManager.dart';

import 'game_state.dart';
import 'game_storage.dart';
import 'package:harvest_valley/player/human.dart';

class GameSession {
  static final GameSession _instance = GameSession._internal();
  factory GameSession() => _instance;
  GameSession._internal();

  GameState? currentState;

  Future<void> save(HumanPlayer player, {String? currentMap}) async {
    if (currentState == null) return;

    currentState!
      ..playerX = player.position.x
      ..playerY = player.position.y
      ..currentMap = currentMap ?? currentState!.currentMap
      ..money = player.dinheiro
      ..inventory = player.toSlotStates()
      ..diasPassados = player.diasPassados
      ..horarioAtual = player.minutoAtualJogo
      ..farmTileStates = FarmManager.instance.toPersistentStates();
      
    await GameStorage.saveGame(currentState!);
  }
}

final gameSession = GameSession();