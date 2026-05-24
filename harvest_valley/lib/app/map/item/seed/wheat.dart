import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/app/save/game_session.dart';

class wheatItem extends GameDecoration with Sensor {
  final String id;

  wheatItem(Vector2 position, this.id)
      : super.withSprite(
          sprite: SpriteManager.itemSprites['wheat_seed']!,
          position: position,
          size: Vector2.all(16),
        );

  @override
  void onContact(GameComponent component) {
      if (component is HumanPlayer) {
        if (component.adicionarItem("wheat_seed", quantidade: 10)) {
          final state = gameSession.currentState!;
          if (!state.collectedItems.contains(id)) {
            state.collectedItems.add(id);
          }
          removeFromParent();
        }
      }
    }
}