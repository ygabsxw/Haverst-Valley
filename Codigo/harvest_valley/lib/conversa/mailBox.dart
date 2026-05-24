import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import '../player/human.dart';

class MailBox extends GameDecoration with Sensor {
  MailBox(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('assets/images/test_vermelho.png'),
        position: position,
        size: Vector2.all(32),
      );

  bool _alreadyTalked = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(size: size));
  }

  @override
  void onContact(GameComponent component) {
    if (component is HumanPlayer && !_alreadyTalked) {
      _alreadyTalked = true;

      TalkDialog.show(gameRef.context, [
        Say(text: [const TextSpan(text: "Teste de conversa")]),
        Say(text: [const TextSpan(text: "Passei no bloco vermelho")]),
        Say(text: [const TextSpan(text: "Fim da conversa")]),
      ]).then((_) {
        _alreadyTalked = false;
      });
    }
  }
}
