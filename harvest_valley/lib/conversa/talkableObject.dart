import 'dart:async';
import 'package:bonfire/bonfire.dart';
import '../player/human.dart';

// obs: não usar essa classe, criada para teste futuro e para deixar salvo
class TalkableObject extends GameDecoration with Sensor {
  final List<Say> conversation;
  bool _alreadyTalked = false;

  TalkableObject({
    required super.position,
    required super.size,
    required super.sprite,
    required this.conversation,
  }) : super.withSprite();

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size, isSolid: false));
    return super.onLoad();
  }

  @override
  void onContact(GameComponent component) {
    if (component is HumanPlayer && !_alreadyTalked) {
      _alreadyTalked = true;
      TalkDialog.show(gameRef.context, conversation).then((_) {
        _alreadyTalked = false;
      });
    }
  }
}
