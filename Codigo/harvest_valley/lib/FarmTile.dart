// farm_tile.dart
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/FarmManager.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/app/save/quest_state.dart';
import 'package:harvest_valley/data/crops_data.dart';
import 'package:harvest_valley/player/human.dart';

class FarmTile extends GameObject {
  late FarmTileState myState;

  CropConfig? _currentConfig;

  SpriteComponent? cropComponent;
  SpriteComponent? wheatTopComponent;

  FarmTile(Vector2 position, Vector2 size)
    : super(
        sprite: null,
        position: position,
        size: size,
        objectPriority: LayerPriority.MAP,
      );

  @override
  Future<void> onLoad() async {
    myState = FarmManager.instance.getTileState(position);

    if (myState.cropType != null) {
      _currentConfig = CropConfig.get(myState.cropType!);
    }

    _simulatePassedTime();
    _updateSoilSprite();
    _updateCropSprite();

    await super.onLoad();
  }

  void processTimeSkip(int minutesPassed) {
    if (minutesPassed <= 0) return;

    if (myState.molhado && myState.timeWateredInGameMinutes != null) {
      int dryLimit = _currentConfig?.dryTimeGameMin ?? 30;


      final player = gameRef.player as HumanPlayer?;
      if (player == null) return;

      int timeSinceWater =
          player.totalGameMinutes - myState.timeWateredInGameMinutes!;

      double growthMinutes = 0;

      if (timeSinceWater > dryLimit) {


        int timeDriedAbs = myState.timeWateredInGameMinutes! + dryLimit;
        int timeBeforeSleep = player.totalGameMinutes - minutesPassed;

        if (timeDriedAbs > timeBeforeSleep) {
          growthMinutes = (timeDriedAbs - timeBeforeSleep).toDouble();
        } else {
          growthMinutes = 0;
        }

        myState.molhado = false;
        myState.timeWateredInGameMinutes = null;
        print("a terra secou durante a noite.");
      } else {
        growthMinutes = minutesPassed.toDouble();
      }

      if (myState.cropType != null &&
          _currentConfig != null &&
          myState.growthStage < 5) {
        myState.growthProgress += growthMinutes;
        _recalculateGrowthStage();
      }
    }

    // muda o sprite do chao e das plantas
    _updateSoilSprite();
    _updateCropSprite();

    myState.lastSyncGameMinutes =
        (gameRef.player as HumanPlayer).totalGameMinutes;
  }

  void _simulatePassedTime() {
    final player = gameRef.player as HumanPlayer?;
    if (player == null) return;

    int currentGameTime = player.totalGameMinutes;
    int lastSavedTime = myState.lastSyncGameMinutes;

    if (lastSavedTime == 0) {
      myState.lastSyncGameMinutes = currentGameTime;
      return;
    }

    // Calcula quantos minutos de jogo se passaram enquanto player mudou de mapa
    int minutesPassed = currentGameTime - lastSavedTime;

    if (minutesPassed > 0) {
      if (myState.molhado && myState.timeWateredInGameMinutes != null) {
        int dryLimit = _currentConfig?.dryTimeGameMin ?? 30;
        int timeSinceWater =
            currentGameTime - myState.timeWateredInGameMinutes!;

        if (timeSinceWater >= dryLimit) {
          myState.molhado = false;
          myState.timeWateredInGameMinutes = null;
          // A terra secou enquanto você estava fora!
        }
      }

      if (myState.cropType != null &&
          _currentConfig != null &&
          myState.growthStage < 5) {
        // adiciona o tempo passado ao progresso
        double secondsToGrow = minutesPassed.toDouble();

        // Se a terra não estava molhada, não cresce nada
        if (!myState.molhado && myState.timeWateredInGameMinutes == null) {
          secondsToGrow = 0;
        }

        myState.growthProgress += secondsToGrow;
        _recalculateGrowthStage();
      }
    }

    // Atualiza o tempo de sincronia para o atual
    myState.lastSyncGameMinutes = currentGameTime;
  }

  void _recalculateGrowthStage() {
    if (_currentConfig == null) return;

    int totalStagesForDivision = 5;
    int maxVisualStage = 5;

    if (myState.cropType == 'wheat') {
      totalStagesForDivision = 3;
      maxVisualStage = 3;
    }

    double timePerStage =
        _currentConfig!.growthTimeSec / totalStagesForDivision;

    int currentCalcStage = (myState.growthProgress / timePerStage).floor();

    if (currentCalcStage > maxVisualStage) {
      currentCalcStage = maxVisualStage;
    }

    int finalStage = (myState.growthProgress >= _currentConfig!.growthTimeSec)
        ? 5
        : currentCalcStage;

    if (finalStage > myState.growthStage) {
      myState.growthStage = finalStage;
      _updateCropSprite();
      print('Planta cresceu para estágio ${myState.growthStage}');
    }
  }

  void _updateSoilSprite() {
    sprite = myState.molhado ? SpriteManager.wetDirt : SpriteManager.dryDirt;
  }

  void _updateCropSprite() {
    cropComponent?.removeFromParent();
    cropComponent = null;
    wheatTopComponent?.removeFromParent();
    wheatTopComponent = null;

    if (myState.cropType == null) return;

    if (myState.cropType == 'wheat') {
      final sprites = SpriteManager.getWheatSprites(myState.growthStage);

      cropComponent = SpriteComponent(
        sprite: sprites[0],
        size: size,
        position: Vector2(0, 0),
        priority: LayerPriority.MAP + 5,
      );
      add(cropComponent!);

      wheatTopComponent = SpriteComponent(
        sprite: sprites[1], // Topo
        size: size,
        position: position + Vector2(0, -size.y),
        priority: LayerPriority.MAP + 10,
      );
      gameRef.add(wheatTopComponent!);
    } else {
      Sprite? newCropSprite = SpriteManager.getCropSprite(
        myState.cropType!,
        myState.growthStage,
      );

      cropComponent = SpriteComponent(
        sprite: newCropSprite,
        size: size,
        position: Vector2(1, -3),
        priority: LayerPriority.MAP + 5,
      );
      add(cropComponent!);
    }
  }

  bool plantSeed(String seedType) {
    final player = gameRef.player as HumanPlayer?;
    if (player == null) return false;

    if (myState.cropType == null) {
      String cropType = seedType.replaceAll('_seed', '');

      if (CropConfig.data.containsKey(cropType)) {
        myState.cropType = cropType;
        myState.growthStage = 0;
        myState.growthProgress = 0.0;

        // Carrega a configuração específica desta planta
        _currentConfig = CropConfig.get(cropType);

        _updateCropSprite();
        print('Plantação de $cropType iniciada.');
        return true;
      }
    }
    return false;
  }

  Map<String, int>? harvestPlantation() {
    final player = gameRef.player as HumanPlayer?;
    if (player == null) return null;

    if (myState.cropType != null && myState.growthStage >= 5) {
      int quantity = _currentConfig!.getDynamicYield(player.reputacao);

      String itemType = "${myState.cropType}_item";

      player.ganharReputacao(_currentConfig!.reputationGain);
      if (gameSession.currentState != null) {
        try {
          final quest = gameSession.currentState!.activeQuests.firstWhere(
            (q) =>
                q.id == 'capitulo_1_plantio' && q.status == QuestStatus.active,
          );

          if (myState.cropType == 'springOnion') {
            quest.addProgress(1);

            if (quest.status == QuestStatus.ready) {
              ScaffoldMessenger.of(gameRef.context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Objetivo cumprido! Leve a colheita para a Clara.",
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        } catch (e) {
          // Nenhuma quest ativa encontrada ou não era cebolinha. Segue o jogo.
        }
      }
      print(
        'Colhido $quantity x $itemType em $position (Rep: ${player.reputacao})',
      );
      myState.cropType = null;
      myState.growthStage = 0;
      myState.growthProgress = 0.0;
      _currentConfig = null;

      _updateCropSprite();

      return {itemType: quantity};
    }
    return null;
  }

  void waterPlantation() {
    final player = gameRef.player as HumanPlayer;
    final int currentTime = player.totalGameMinutes;

    myState.molhado = true;
    myState.timeWateredInGameMinutes = currentTime;
    _updateSoilSprite();
  }

  void _ensureConfigLoaded() {
    if (myState.cropType != null && _currentConfig == null) {
      _currentConfig = CropConfig.get(myState.cropType!);
    }

    if (myState.cropType == null) {
      _currentConfig = null;
    }
  }

  @override
  void update(double dt) {
    final player = gameRef.player as HumanPlayer?;
    if (player == null) {
      super.update(dt);
      return;
    }

    _ensureConfigLoaded();

    myState.lastSyncGameMinutes = player.totalGameMinutes;

    if (myState.molhado && myState.timeWateredInGameMinutes != null) {
      final int currentTime = player.totalGameMinutes;
      final int minutesPassed = currentTime - myState.timeWateredInGameMinutes!;

      // Pega tempo de secagem da config da planta, ou padrão 30sec se solo vazio
      int dryTime = _currentConfig?.dryTimeGameMin ?? 30;

      if (minutesPassed >= dryTime) {
        myState.molhado = false;
        myState.timeWateredInGameMinutes = null;
        _updateSoilSprite();
        print(
          'Terra secou em $position após $minutesPassed minutos (Meta: $dryTime)',
        );
      }
    }

    if (myState.molhado &&
        myState.cropType != null &&
        myState.growthStage < 5 &&
        _currentConfig != null) {
      myState.growthProgress += dt;

      // Calcula o tempo necessário por estágio (Total / 5 estágios)
      _recalculateGrowthStage();
    }

    super.update(dt);
  }
}
