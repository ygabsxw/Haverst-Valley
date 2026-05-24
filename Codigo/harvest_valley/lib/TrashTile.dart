import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/app/save/quest_state.dart';

class TrashTile extends GameObject {
  late final String globalUniqueId;
  SpriteComponent? cropComponent;
  int i = 0;

  TrashTile(Vector2 position, Vector2 size)
    : super(
        sprite: null,
        position: position,
        size: size / 1.5,
        objectPriority: LayerPriority.MAP,
      );
  @override
  Future<void> onLoad() async {
    final mapId = gameSession.currentState?.currentMap;

    if (mapId == null) {
      removeFromParent();
      return;
    }

    globalUniqueId = '$mapId:${position.x}_${position.y}';

    if (gameSession.currentState?.collectedItems.contains(globalUniqueId) ??
        false) {
      removeFromParent();
    } else {
      sprite = SpriteManager.trashItem;
      paint = SpriteManager.greyPaint;
    }

    await super.onLoad();
  }

  String? collectTrash() {
    gameSession.currentState?.collectedItems.add(globalUniqueId);

    if (gameSession.currentState != null) {
      // busca a quest
      final quest = gameSession.currentState!.activeQuests
          .cast<QuestModel?>()
          .firstWhere(
            (q) =>
                q != null &&
                q.id == 'tutorial_lixo' &&
                q.status == QuestStatus.active,
            orElse: () => null,
          );

      // Se encontrou a quest ativa, atualiza
      if (quest != null) {
        quest.addProgress(1);

        // Feedback para o player
        if (quest.status == QuestStatus.ready) {
          ScaffoldMessenger.of(gameRef.context).showSnackBar(
            const SnackBar(
              content: Text(
                "Limpeza Concluída! Fale com o Prefeito.",
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    removeFromParent();

    return 'trash_item';
  }
}
