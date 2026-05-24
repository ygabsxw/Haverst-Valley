// lib/items/spring_onion_item.dart
import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/app/save/game_session.dart';

class SpringOnionItem extends GameDecoration with Sensor {
  final String id;

  SpringOnionItem(Vector2 position, this.id)
      : super.withSprite(
          sprite: SpriteManager.itemSprites['springOnion_seed']!,
          position: position,
          size: Vector2.all(16),
        );

  @override
  void onContact(GameComponent component) {
    if (component is HumanPlayer) {
      if (component.adicionarItem('springOnion_seed', quantidade: 5)) {
          final state = gameSession.currentState!;
          if (!state.collectedItems.contains(id)) {
            state.collectedItems.add(id);
          }
        removeFromParent();
      }
    }
  }
}