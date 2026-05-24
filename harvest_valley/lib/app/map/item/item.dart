import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/player/human.dart';

class Item extends GameDecoration with Sensor {
  String spriteSrc;
  String type;
  int quantity;

  Item(Vector2 position, this.spriteSrc, this.type, this.quantity)
    : super.withSprite(sprite: Sprite.load(spriteSrc), position: position, size: Vector2.all(12));

  @override
  void onContact(GameComponent component) {
    if (component is HumanPlayer) {
      final collected = component.adicionarItem(type, quantidade: quantity);
      if (collected) {
        removeFromParent(); // remove do mapa
      } else {
        //mostrar mensagem "Inventário cheio" mais a frente
      }
    }
  }
}