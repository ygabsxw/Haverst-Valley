import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:harvest_valley/SpriteManager.dart';

class WorldItem extends GameDecoration with Sensor {
  final String itemType;
  final int quantity;

  WorldItem(Vector2 position, this.itemType, {this.quantity = 1})
    : super.withSprite(
        // Pega o sprite do item (fruta, etc.)
        sprite: SpriteManager.itemSprites[itemType]!,
        position: position,
        size: Vector2(16, 16) / 1.5,
      );

  @override
  void onContact(GameComponent component) {
    if (component is HumanPlayer) {
      // Tenta adicionar o item ao inventário
      if (component.adicionarItem(itemType, quantidade: quantity)) {
        // Se conseguir, remove o item do chão
        removeFromParent();
      }
    }
  }
}
